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
    func verifyAccessCodeAndProceedWithCard() async {
        var supportedChannels: [SupportedChannels] = []
        do {
            transactionState = .loading()
            let accessCodeResponse = try await repository.verifyAccessCode(accessCode)
            guard accessCodeResponse.paymentChannels.contains(where: { $0 == .card || $0 == .mobileMoney }) else {
                let message = "Card/MPesa payments are not supported. " +
                "Please reach out to your merchant for further information"
                let cause = "There are currently no payment channels on " +
                "your integration that are supported by the SDK"
                throw ChargeError(displayMessage: message, causeMessage: cause)
            }

            let mobileMoneyChannel = accessCodeResponse.channelOptions?.mobileMoney?.contains(where: { $0.key == SupportedChannels.MPESA.rawValue }) ?? false

            accessCodeResponse.paymentChannels.forEach {
                if $0 == .card {
                    supportedChannels.append(.CARD)
                }
                if $0 == .mobileMoney && accessCodeResponse.channelOptions?.mobileMoney?.contains(where: { $0.key == SupportedChannels.MPESA.rawValue }) ?? false {
                    supportedChannels.append(.MPESA)
                }
            }

            if mobileMoneyChannel {
                transactionState = .channelSelection(
                    transactionInformation: accessCodeResponse, supportedChannels: supportedChannels)
            } else {
                self.transactionDetails = accessCodeResponse
                transactionState = .payment(type: .card(transactionInformation: accessCodeResponse))
            }
        } catch {
            let error = ChargeError(error: error)
            Logger.error("Verify access code failed with error: %@",
                         arguments: error.cause?.localizedDescription ?? "Unknown")
            // TODO: Display a fatal error here in the future instead
            transactionState = .error(error)
        }
    }

}

enum SupportedChannels: String, CaseIterable {
    case CARD = "CARD"
    case MPESA = "MPESA"
    case unsupportedChannel

    var image: Image {
        switch self {
        case .CARD:
            return Image("cardLogo", bundle: .current)
        case .MPESA:
            return Image("kenyaSHLogo", bundle: .current)
        case .unsupportedChannel:
            return   Image(systemName: "exclamationmark.triangle.fill")
        }
    }

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
