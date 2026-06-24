import Foundation
import SwiftUI
import PaystackCore

class ChargeViewModel: ObservableObject {

    let accessCode: String
    let repository: ChargeRepository

    @Published
    var transactionState: ChargeState = .loading()

    var transactionDetails: VerifyAccessCode?

    init(accessCode: String,
         repository: ChargeRepository = ChargeRepositoryImplementation()) {
        self.accessCode = accessCode
        self.repository = repository
    }

    @MainActor
    func verifyAccessCodeAndProceed() async {
        do {
            transactionState = .loading()
            let response = try await repository.verifyAccessCode(accessCode)
            let supported = resolveSupportedChannels(from: response)

            guard !supported.isEmpty else {
                let message = "No supported payment methods. " +
                "Please reach out to your merchant for further information"
                let cause = "No payment channels on this integration " +
                "are supported by the SDK"
                throw ChargeError(displayMessage: message, causeMessage: cause)
            }

            transactionDetails = response
            transactionState = nextState(for: supported, response: response)
        } catch {
            let error = ChargeError(error: error)
            Logger.error("Verify access code failed with error: %@",
                         arguments: error.cause?.localizedDescription ?? "Unknown")
            transactionState = .error(error)
        }
    }

    private func resolveSupportedChannels(from response: VerifyAccessCode) -> [SupportedChannel] {
        var result: [SupportedChannel] = []

        if response.paymentChannels.contains(.card) {
            result.append(.card)
        }

        if response.paymentChannels.contains(.mobileMoney),
           let providers = response.channelOptions?.mobileMoney, !providers.isEmpty {
            let allowed = filtered(providers)
            result.append(contentsOf: allowed.map { .mobileMoney($0) })
        }

        if response.paymentChannels.contains(.bankTransfer),
           let transactionId = response.transactionId {
            let config = BankTransferConfig(
                fulfilLateNotification: response
                    .merchantChannelSettings?.bankTransfer?.fulfilLateNotification ?? false,
                transactionId: transactionId,
                availableProviders: response.channelOptions?.bankTransfer ?? [])
            result.append(.bankTransfer(config))
        }

        if response.paymentChannels.contains(.bank),
           let banks = response.supportedBanks,
           let zap = banks.first(where: { Self.promotedSupportedBankCodes.contains($0.code) }),
           let transactionId = response.transactionId {
            let config = ZapConfig(supportedBankId: zap.id,
                                   transactionId: transactionId,
                                   walletEmail: response.email)
            result.append(.zap(config))
        }

        return result
    }

    private func filtered(_ providers: [MobileMoneyChannel]) -> [MobileMoneyChannel] {
        guard let allowlist = Self.supportedMobileMoneyProviders else {
            return providers
        }
        return providers.filter { allowlist.contains($0.key.uppercased()) }
    }

    private func nextState(for channels: [SupportedChannel],
                           response: VerifyAccessCode) -> ChargeState {
        if channels.count == 1, case .card = channels[0] {
            return .payment(type: .card(transactionInformation: response))
        }

        if !channels.contains(.card),
           channels.count == 1,
           case .mobileMoney(let provider) = channels[0] {
            return .payment(type: .mobileMoney(transactionInformation: response,
                                               provider: provider))
        }

        if !channels.contains(.card),
           channels.count == 1,
           case .bankTransfer(let config) = channels[0] {
            return .payment(type: .bankTransfer(transactionInformation: response,
                                                config: config))
        }

        if !channels.contains(.card),
           channels.count == 1,
           case .zap(let config) = channels[0] {
            return .payment(type: .zap(transactionInformation: response,
                                       config: config))
        }

        return .channelSelection(transactionInformation: response,
                                 supportedChannels: channels)
    }

}

extension ChargeViewModel {

    static var supportedMobileMoneyProviders: Set<String>? = [
        "MPESA", "ATL_KE", "MTN", "ATL", "VOD", "WAVE_CI", "ORANGE_CI", "MTN_CI"
    ]

    static var promotedSupportedBankCodes: Set<String> = ["00zap"]
}

extension ChargeViewModel: ChargeContainer {

    func processSuccessfulTransaction(details: VerifyAccessCode) {
        transactionState = .success(amount: details.amountCurrency,
                                    merchant: details.merchantName,
                                    details: .init(reference: details.reference))
    }

    func restartFromChannelSelection() {
        guard let details = transactionDetails else {
            Logger.error("restartFromChannelSelection called without cached transaction details")
            transactionState = .error(.generic)
            return
        }
        let supported = resolveSupportedChannels(from: details)
        transactionState = .channelSelection(transactionInformation: details,
                                             supportedChannels: supported)
    }

}

extension ChargeViewModel {

    var centerView: Bool {
        switch transactionState {
        case .success:
            return true
        default:
            return false
        }
    }

    var displayCloseButtonConfirmation: Bool {
        switch transactionState {
        case .success:
            return false
        default:
            return true
        }
    }

    var inTestMode: Bool {
        transactionDetails?.domain == .test
    }
}
