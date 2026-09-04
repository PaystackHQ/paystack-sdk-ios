import Foundation
import PaystackCore

class QRViewModel: ObservableObject {

    static var failedFallbackMessage = "The transaction could not be confirmed"
    static var checkPendingFallbackMessage =
        "We couldn't confirm your payment yet — please try again in a moment"

    let chargeContainer: ChargeContainer
    let repository: QRRepository
    let transactionDetails: VerifyAccessCode
    let config: QRConfig

    @Published
    var state: QRState = .loadingQR

    @Published
    var inlineBanner: String?

    private var pusherTask: Task<Void, Never>?
    private var checkPendingTask: Task<Void, Never>?

    init(chargeContainer: ChargeContainer,
         transactionDetails: VerifyAccessCode,
         config: QRConfig,
         repository: QRRepository = QRRepositoryImplementation()) {
        self.chargeContainer = chargeContainer
        self.transactionDetails = transactionDetails
        self.config = config
        self.repository = repository
    }

    deinit {
        pusherTask?.cancel()
        checkPendingTask?.cancel()
    }

    var variant: QRVariant { config.variant }

    @MainActor
    func onAppear() async {
        guard case .loadingQR = state else { return }
        await generate()
    }

    @MainActor
    func retry() async {
        cancelAllTasks()
        inlineBanner = nil
        state = .loadingQR
        await generate()
    }

    @MainActor
    private func generate() async {
        do {
            let details = try await repository.generate(
                reference: "\(config.transactionId)",
                channelOption: config.channelOption,
                variant: config.variant)
            state = .awaitingScan(details)
            startListeningForPusher(on: details.pusherChannel)
        } catch {
            state = .error(ChargeError(error: error))
        }
    }

    @MainActor
    func userTappedICompletedPayment() {
        guard case .awaitingScan(let details) = state else { return }
        cancelPusherTask()
        inlineBanner = nil
        state = .verifying(details)

        checkPendingTask?.cancel()
        checkPendingTask = Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.repository.checkPending(
                    accessCode: self.transactionDetails.accessCode)
                await self.reactToCheckPendingResult(result, details: details)
            } catch {
                await self.handleCheckPendingFailure(details: details,
                                                    message: nil)
            }
        }
    }

    @MainActor
    func userTappedChangePaymentMethod() {
        cancelAllTasks()
        chargeContainer.restartFromChannelSelection()
    }

    @MainActor
    private func reactToCheckPendingResult(_ result: ChargeCardTransaction,
                                           details: QRDetails) {
        switch result.status {
        case .success:
            cancelAllTasks()
            chargeContainer.processSuccessfulTransaction(details: transactionDetails)
        case .failed:
            cancelAllTasks()
            let message = result.message ?? result.displayText ?? Self.failedFallbackMessage
            state = .error(ChargeError(message: message))
        default:
            handleCheckPendingFailure(details: details, message: nil)
        }
    }

    @MainActor
    private func handleCheckPendingFailure(details: QRDetails, message: String?) {
        inlineBanner = message ?? Self.checkPendingFallbackMessage
        state = .awaitingScan(details)
        startListeningForPusher(on: details.pusherChannel)
    }

    private func startListeningForPusher(on channel: String) {
        pusherTask?.cancel()
        pusherTask = Task { [weak self] in
            await self?.listenLoop(on: channel)
        }
    }

    private func listenLoop(on channel: String) async {
        do {
            let update = try await repository.listenForResponse(onChannel: channel)
            await processTransactionUpdate(update)
        } catch {
            Logger.error("QR Pusher await failed: %@",
                         arguments: error.localizedDescription)
        }
    }

    @MainActor
    func processTransactionUpdate(_ update: ChargeCardTransaction) async {
        switch update.status {
        case .success:
            cancelAllTasks()
            chargeContainer.processSuccessfulTransaction(details: transactionDetails)
        case .failed:
            cancelAllTasks()
            let message = update.message ?? Self.failedFallbackMessage
            state = .error(ChargeError(message: message))
        default:
            Logger.info("QR: non-terminal transaction status %@",
                        arguments: String(describing: update.status))
        }
    }

    private func cancelPusherTask() {
        pusherTask?.cancel()
        pusherTask = nil
    }

    private func cancelAllTasks() {
        cancelPusherTask()
        checkPendingTask?.cancel()
        checkPendingTask = nil
    }
}
