import Foundation
import PaystackCore

class ZapViewModel: ObservableObject {

    static var mandateWindowSeconds: Int = 5 * 60
    public static var showsOpenZapButton = true

    static var failedFallbackMessage = "Something went wrong"
    static var sessionExpiredCopy =
        "Your Zap payment session has timed out. Tap below to try again."

    let chargeContainer: ChargeContainer
    let repository: ZapRepository
    let transactionDetails: VerifyAccessCode
    let config: ZapConfig

    @Published
    var state: ZapState = .loading()
    
    @Published
    var remainingSeconds: Int = ZapViewModel.mandateWindowSeconds

    private var mandateTimerTask: Task<Void, Never>?
    private var pusherTask: Task<Void, Never>?

    init(chargeContainer: ChargeContainer,
         transactionDetails: VerifyAccessCode,
         config: ZapConfig,
         repository: ZapRepository = ZapRepositoryImplementation()) {
        self.chargeContainer = chargeContainer
        self.transactionDetails = transactionDetails
        self.config = config
        self.repository = repository
    }

    deinit {
        mandateTimerTask?.cancel()
        pusherTask?.cancel()
    }

    @MainActor
    func initiateMandate() async {
        state = .loading(message: "Setting up your Zap payment")
        do {
            let response = try await repository.initiateZapMandate(
                supportedBankId: config.supportedBankId,
                transactionId: config.transactionId,
                walletEmail: config.walletEmail)
            guard let details = ZapDetails.from(response,
                                                mandateWindowSeconds: Self.mandateWindowSeconds) else {
                state = .error(ChargeError(
                    message: "Zap mandate response missing or malformed URLs"))
                return
            }
            state = .awaitingPayment(details)
            startMandateCountdown()
            startListeningForPusher(on: details)
        } catch {
            displayTransactionError(ChargeError(error: error))
        }
    }

    @MainActor
    func retryAfterExpiry() async {
        remainingSeconds = Self.mandateWindowSeconds
        await initiateMandate()
    }

    @MainActor
    func userTappedChangePaymentMethod() {
        cancelTimers()
        chargeContainer.restartFromChannelSelection()
    }

    private func startMandateCountdown() {
        mandateTimerTask?.cancel()
        let window = Self.mandateWindowSeconds
        remainingSeconds = window
        guard window > 0 else { return }

        mandateTimerTask = Task { [weak self] in
            for _ in 0..<window {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard let self, !Task.isCancelled else { return }
                await MainActor.run {
                    self.remainingSeconds = max(self.remainingSeconds - 1, 0)
                }
            }
            guard let self, !Task.isCancelled else { return }
            await MainActor.run {
                if case .awaitingPayment = self.state {
                    self.state = .sessionExpired
                    self.cancelTimers()
                }
            }
        }
    }

    // MARK: - Pusher listen loop

    private func startListeningForPusher(on details: ZapDetails) {
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
                    .listenForZapResponse(onChannel: channel)
                await processTransactionUpdate(update)
                if update.status.isTerminal { return }
            } catch {
                Logger.error("Zap Pusher iteration failed: %@",
                             arguments: error.localizedDescription)
                return
            }
        }
    }

    @MainActor
    func processTransactionUpdate(_ update: BankTransferTransactionUpdate) async {
        switch update.status {

        case .success:
            cancelTimers()
            chargeContainer.processSuccessfulTransaction(details: transactionDetails)

        case .failed:
            cancelTimers()
            let message = update.message ?? Self.failedFallbackMessage
            state = .error(ChargeError(message: message))

        default:
            Logger.info("Zap: unexpected Pusher status %@",
                        arguments: String(describing: update.status))
        }
    }

    private func cancelTimers() {
        mandateTimerTask?.cancel()
        mandateTimerTask = nil
        pusherTask?.cancel()
        pusherTask = nil
    }

    @MainActor
    func displayTransactionError(_ error: ChargeError) {
        Logger.error("Displaying Zap error: %@", arguments: error.localizedDescription)
        cancelTimers()
        state = .error(error)
    }
}
