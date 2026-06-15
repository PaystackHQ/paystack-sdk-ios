import Foundation
import PaystackCore

class BankTransferViewModel: ObservableObject {


    var confirmationWindowSeconds: Int = 10 * 60

    static var refundInitiatedFallbackMessage =
        "You sent an incorrect amount. We've started a refund — funds will be returned to the account you sent from within a few business days."

    static var failedFallbackMessage = "Something went wrong"

    let chargeContainer: ChargeContainer
    let repository: BankTransferRepository
    let transactionDetails: VerifyAccessCode
    let config: BankTransferConfig

    @Published
    var state: BankTransferState = .loading()

    @Published
    var confirmationElapsedSeconds: Int = 0

    private var confirmationTimerTask: Task<Void, Never>?
    private var pusherTask: Task<Void, Never>?
    private var requeryTask: Task<Void, Never>?

    init(chargeContainer: ChargeContainer,
         transactionDetails: VerifyAccessCode,
         config: BankTransferConfig,
         repository: BankTransferRepository = BankTransferRepositoryImplementation()) {
        self.chargeContainer = chargeContainer
        self.transactionDetails = transactionDetails
        self.config = config
        self.repository = repository
    }

    deinit {
        confirmationTimerTask?.cancel()
        pusherTask?.cancel()
        requeryTask?.cancel()
    }

    // MARK: - Provisioning

    @MainActor
    func provisionVirtualAccount() async {
        state = .loading(message: "Getting your account details")
        do {
            let details = try await repository.payWithTransfer(
                fulfilLateNotification: config.fulfilLateNotification,
                transactionId: config.transactionId,
                preferredProvider: nil)
            state = .awaitingPayment(details)
            startListeningForPusher(on: details)
        } catch {
            displayTransactionError(ChargeError(error: error))
        }
    }

    // MARK: - User actions

    @MainActor
    func userTappedIveSentTheMoney() async {
        guard case .awaitingPayment(let details) = state else { return }
        transitionToConfirming(details, phase: .waitingForCredit)

        do {
            let result = try await repository
                .checkPendingCharge(with: transactionDetails.accessCode)
            await reactToPollResult(result)
        } catch {
            Logger.error("PWT checkPendingCharge after I've-sent-the-money failed: %@",
                         arguments: error.localizedDescription)
        }
    }

    @MainActor
    func userTappedBackToAccountNumber() {
        guard let details = currentDetails else { return }
        confirmationTimerTask?.cancel()
        confirmationTimerTask = nil
        confirmationElapsedSeconds = 0
        state = .awaitingPayment(details)
    }

    @MainActor
    func userTappedChangePaymentMethod() {
        cancelTimers()
        chargeContainer.restartFromChannelSelection()
    }

    @MainActor
    func userTappedGetHelp() {
        guard case .takingLongerThanExpected(let details) = state else { return }
        state = .delayedConfirmation(details)
    }

    @MainActor
    func userTappedKeepWaiting() {
        guard case .delayedConfirmation(let details) = state else { return }
        state = .takingLongerThanExpected(details)
    }

    @MainActor
    func userTappedCloseFromDelayedConfirmation() {
        cancelTimers()
        chargeContainer.restartFromChannelSelection()
    }

    @MainActor
    func userTappedChooseAnotherPaymentMethodFromRefund() {
        cancelTimers()
        chargeContainer.restartFromChannelSelection()
    }

    @MainActor
    func retryProvisioning() async {
        await provisionVirtualAccount()
    }

    // MARK: - Bank picker

    var availableBankSlugs: [String] {
        config.availableProviders
    }

    var currentBankSlug: String? {
        switch state {
        case .awaitingPayment(let d),
             .confirmingPayment(let d, _),
             .takingLongerThanExpected(let d),
             .delayedConfirmation(let d),
             .refundInitiated(let d, _):
            return d.bankSlug
        case .loading, .error, .fatalError:
            return nil
        }
    }

    @MainActor
    func userSelectedBank(slug: String) async {
        Logger.info("PWT: switching to bank %@", arguments: slug)

        cancelTimers()
        confirmationElapsedSeconds = 0

        let displayName = BankTransferProviderCatalog.displayName(forSlug: slug)
        state = .loading(message: "Switching to \(displayName)…")

        do {
            let details = try await repository.payWithTransfer(
                fulfilLateNotification: config.fulfilLateNotification,
                transactionId: config.transactionId,
                preferredProvider: slug)
  
            state = .awaitingPayment(details)
            startListeningForPusher(on: details)
        } catch {
            Logger.error("PWT: bank switch failed: %@",
                         arguments: error.localizedDescription)
            displayTransactionError(ChargeError(error: error))
        }
    }

    // MARK: - Confirmation countdown

    private func startConfirmationCountdown() {
        confirmationTimerTask?.cancel()
        confirmationElapsedSeconds = 0
        let window = confirmationWindowSeconds
        guard window > 0 else { return }

        confirmationTimerTask = Task { [weak self] in
            for _ in 0..<window {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard let self, !Task.isCancelled else { return }
                await MainActor.run {
                    self.confirmationElapsedSeconds = min(
                        self.confirmationElapsedSeconds + 1, window)
                }
            }
      
            guard let self, !Task.isCancelled else { return }
            await MainActor.run {
                if case .confirmingPayment(let details, _) = self.state {
                    self.state = .takingLongerThanExpected(details)
                }
            }
        }
    }

    // MARK: - Pusher listen loop

    private func startListeningForPusher(on details: BankTransferDetails) {
        pusherTask?.cancel()
        let channel = details.pusherChannel
        pusherTask = Task { [weak self] in
            await self?.listenLoop(on: channel)
        }
    }

    private func listenLoop(on channel: String) async {
        while !Task.isCancelled {
            do {
                let update = try await repository
                    .listenForTransferResponse(onChannel: channel)
                await processTransferUpdate(update)
                if update.status.isTerminal { return }
            } catch {
                Logger.error("PWT Pusher iteration failed: %@",
                             arguments: error.localizedDescription)
                return
            }
        }
    }

    @MainActor
    func processTransferUpdate(_ update: BankTransferTransactionUpdate) async {
        switch update.status {

        case .success:
            cancelTimers()
            chargeContainer.processSuccessfulTransaction(details: transactionDetails)

        case .creditRequestPending, .pending:
            guard let details = currentDetails else {
                Logger.info("PWT: %@ received with no current details ; skipping",
                            arguments: String(describing: update.status))
                return
            }
            transitionToConfirming(details, phase: .waitingForCredit)

        case .creditRequestReceived:
            guard let details = currentDetails else {
                Logger.info("PWT: credit-request-received received with no current details ; skipping")
                return
            }
            transitionToConfirming(details, phase: .transferOnTheWay)

        case .creditRequestRejected, .incorrectAmountSent:
            cancelTimers()
            guard let details = currentDetails else {
                state = .error(ChargeError(
                    message: update.message ?? Self.refundInitiatedFallbackMessage))
                return
            }
            let message = update.message ?? Self.refundInitiatedFallbackMessage
            state = .refundInitiated(details, message: message)

        case .requery:
            spawnRequeryTask()

        case .failed:
            cancelTimers()
            let message = update.message ?? Self.failedFallbackMessage
            state = .error(ChargeError(message: message))

        case .unknown(let raw):
            Logger.error("Unexpected PWT status: %@", arguments: raw)
        }
    }

    // MARK: - State transition helpers
    @MainActor
    private func transitionToConfirming(_ details: BankTransferDetails,
                                        phase incoming: ConfirmingPhase) {
        if case .confirmingPayment(_, .transferOnTheWay) = state,
           incoming == .waitingForCredit {
            Logger.info("PWT: ignoring waitingForCredit while already transferOnTheWay")
            return
        }
        state = .confirmingPayment(details, phase: incoming)
        if confirmationTimerTask == nil {
            startConfirmationCountdown()
        }
    }

    @MainActor
    private func spawnRequeryTask() {
        requeryTask?.cancel()
        requeryTask = Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.repository
                    .checkPendingCharge(with: self.transactionDetails.accessCode)
                await self.reactToPollResult(result)
            } catch {
                Logger.error("PWT requery poll failed: %@",
                             arguments: error.localizedDescription)
            }
        }
    }

    // MARK: - Helpers

    private func reactToPollResult(_ result: ChargeCardTransaction) async {
        switch result.status {
        case .success:
            cancelTimers()
            chargeContainer.processSuccessfulTransaction(details: transactionDetails)
        case .timeout, .pending, .failed:
            break
        default:
            break
        }
    }

    private var currentDetails: BankTransferDetails? {
        switch state {
        case .awaitingPayment(let details):
            return details
        case .confirmingPayment(let details, _):
            return details
        case .takingLongerThanExpected(let details):
            return details
        case .delayedConfirmation(let details):
            return details
        case .refundInitiated(let details, _):
            return details
        case .loading, .error, .fatalError:
            return nil
        }
    }

    private func cancelTimers() {
        confirmationTimerTask?.cancel()
        confirmationTimerTask = nil
        pusherTask?.cancel()
        pusherTask = nil
        requeryTask?.cancel()
        requeryTask = nil
    }

    @MainActor
    func displayTransactionError(_ error: ChargeError) {
        Logger.error("Displaying PWT error: %@", arguments: error.localizedDescription)
        cancelTimers()
        state = .error(error)
    }
}
