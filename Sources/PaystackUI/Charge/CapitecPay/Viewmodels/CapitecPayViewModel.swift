import Foundation
import PaystackCore
#if canImport(UIKit)
import UIKit
#endif

class CapitecPayViewModel: ObservableObject {

    static var requeryPollIntervalSeconds: Int = 10
    static var requeryMaxIterations: Int = 18

    static var failedFallbackMessage = "The transaction could not be confirmed"
    static var authenticateFailedMessage = "We couldn't start your Capitec Pay payment"

    let chargeContainer: ChargeContainer
    let repository: CapitecPayRepository
    let transactionDetails: VerifyAccessCode
    let config: CapitecPayConfig

    @Published
    var state: CapitecPayState = .identifierEntry

    @Published
    var identifier: CapitecPayIdentifier = .cellphone

    @Published
    var value: String = ""

    @Published
    var remainingSeconds: Int = 0

    private var approvalCountdownTask: Task<Void, Never>?
    private var pusherTask: Task<Void, Never>?
    private var requeryLoopTask: Task<Void, Never>?
    private var immediateRequeryTask: Task<Void, Never>?

    init(chargeContainer: ChargeContainer,
         transactionDetails: VerifyAccessCode,
         config: CapitecPayConfig,
         repository: CapitecPayRepository = CapitecPayRepositoryImplementation()) {
        self.chargeContainer = chargeContainer
        self.transactionDetails = transactionDetails
        self.config = config
        self.repository = repository
    }

    deinit {
        approvalCountdownTask?.cancel()
        pusherTask?.cancel()
        requeryLoopTask?.cancel()
        immediateRequeryTask?.cancel()
    }

    var isValid: Bool {
        switch identifier {
        case .cellphone:
            return SouthAfricanPhoneValidator.isValid(value)
        case .idNumber:
            return SouthAfricanIDValidator.isValid(value)
        case .accountNumber:
            return !value.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    @MainActor
    func submitIdentifier() async {
        guard isValid else { return }
        state = .authenticating
        do {
            let details = try await repository.authenticate(
                identifier: identifier,
                value: value,
                transactionId: config.transactionId,
                //deviceId: deviceFingerprint(),
                deviceId: "E403F2353A734C9A871BD0276BF92312",
                publicEncryptionKey: config.publicEncryptionKey)
            state = .awaitingApproval(details)
            remainingSeconds = details.timeToLive
            startApprovalCountdown()
            startListeningForPusher(on: details)
        } catch {
            displayTransactionError(ChargeError(error: error))
        }
    }

    @MainActor
    func userTappedIveApprovedThePayment() {
        immediateRequeryTask?.cancel()
        immediateRequeryTask = Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.repository.requery(
                    transactionReference: self.transactionDetails.reference)
                await self.reactToPollResult(result)
            } catch {
                Logger.error("Capitec Pay immediate requery failed: %@",
                             arguments: error.localizedDescription)
            }
        }
    }

    @MainActor
    func userTappedChangePaymentMethod() {
        cancelAllTasks()
        chargeContainer.restartFromChannelSelection()
    }

    @MainActor
    func displayTransactionError(_ error: ChargeError) {
        Logger.error("Displaying Capitec Pay error: %@",
                     arguments: error.localizedDescription)
        cancelAllTasks()
        state = .error(error)
    }

    private func deviceFingerprint() -> String {
        #if canImport(UIKit)
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
        #else
        return ""
        #endif
    }

    private func startApprovalCountdown() {
        approvalCountdownTask?.cancel()
        let window = remainingSeconds
        guard window > 0 else { return }
        approvalCountdownTask = Task { [weak self] in
            for _ in 0..<window {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard let self, !Task.isCancelled else { return }
                await MainActor.run {
                    self.remainingSeconds = max(self.remainingSeconds - 1, 0)
                }
            }
            guard let self, !Task.isCancelled else { return }
            await MainActor.run {
                if case .awaitingApproval(let details) = self.state {
                    self.state = .requerying(details)
                    self.startRequeryLoop()
                }
            }
        }
    }

    private func startListeningForPusher(on details: CapitecPayDetails) {
        pusherTask?.cancel()
        let channel = details.pusherChannel
        pusherTask = Task { [weak self] in
            await self?.listenLoop(on: channel)
        }
    }

    private func listenLoop(on channel: String) async {
        do {
            let update = try await repository
                .listenForCapitecPayResponse(onChannel: channel)
            await processTransactionUpdate(update)
        } catch {
            Logger.error("Capitec Pay Pusher await failed: %@",
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
            Logger.info("Capitec Pay: non-terminal transaction status %@",
                        arguments: String(describing: update.status))
        }
    }

    private func startRequeryLoop() {
        requeryLoopTask?.cancel()
        requeryLoopTask = Task { [weak self] in
            guard let self else { return }
            let maxIterations = Self.requeryMaxIterations
            let intervalNs = UInt64(Self.requeryPollIntervalSeconds) * 1_000_000_000
            for _ in 0..<maxIterations {
                try? await Task.sleep(nanoseconds: intervalNs)
                guard !Task.isCancelled else { return }
                do {
                    let result = try await self.repository.requery(
                        transactionReference: self.transactionDetails.reference)
                    let resolved = await self.reactToPollResult(result)
                    if resolved { return }
                } catch {
                    Logger.error("Capitec Pay requery iteration failed: %@",
                                 arguments: error.localizedDescription)
                }
            }
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.cancelAllTasks()
                self.state = .fatalError(
                    error: ChargeError(message: Self.failedFallbackMessage))
            }
        }
    }

    @MainActor
    @discardableResult
    private func reactToPollResult(_ result: ChargeCardTransaction) -> Bool {
        switch result.status {
        case .success:
            cancelAllTasks()
            chargeContainer.processSuccessfulTransaction(details: transactionDetails)
            return true
        case .failed:
            cancelAllTasks()
            let message = result.message ?? result.displayText ?? Self.failedFallbackMessage
            state = .error(ChargeError(message: message))
            return true
        default:
            return false
        }
    }

    private func cancelAllTasks() {
        approvalCountdownTask?.cancel()
        approvalCountdownTask = nil
        pusherTask?.cancel()
        pusherTask = nil
        requeryLoopTask?.cancel()
        requeryLoopTask = nil
        immediateRequeryTask?.cancel()
        immediateRequeryTask = nil
    }
}
