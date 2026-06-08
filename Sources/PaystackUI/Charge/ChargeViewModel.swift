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
            // TODO: Display a fatal error here in the future instead
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

        return .channelSelection(transactionInformation: response,
                                 supportedChannels: channels)
    }

}

// MARK: - Mobile money provider allowlist
extension ChargeViewModel {

    /// Mobile money provider keys (`MobileMoneyChannel.key`, uppercased) that
    /// the SDK is allowed to route to. The API may return providers we don't
    /// yet have logos, copy, or phone formatters for — listing them here is
    /// what opts them into the UI.
    ///
    /// Set to `nil` to accept every provider the API returns (no filtering).
    /// Add a new key here when you've added its logo to `SupportedChannel.image`
    /// and its country code / phone formatter to the relevant helpers.
    static var supportedMobileMoneyProviders: Set<String>? = [
        "MPESA", "ATL_KE", "MTN", "ATL", "VOD"
    ]
}

// MARK: - Charge Container
extension ChargeViewModel: ChargeContainer {

    func processSuccessfulTransaction(details: VerifyAccessCode) {
        transactionState = .success(amount: details.amountCurrency,
                                    merchant: details.merchantName,
                                    details: .init(reference: details.reference))
    }

}

// MARK: UI State Management
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
