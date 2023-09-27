import SwiftUI

@available(iOS 14.0, *)
struct ChargeCardView: View {

    @StateObject
    var viewModel: ChargeCardViewModel

    init(transactionDetails: VerifyAccessCode, chargeContainer: ChargeContainer) {
        self._viewModel = StateObject(
            wrappedValue: ChargeCardViewModel(transactionDetails: transactionDetails,
                                              chargeContainer: chargeContainer))
    }

    var body: some View {
        switch viewModel.chargeCardState {
        case .loading(let message):
            LoadingView(message: message)

        case .cardDetails(let amount, let encryptionKey):
            CardDetailsView(amountDetails: amount,
                            encryptionKey: encryptionKey,
                            chargeCardContainer: viewModel)

        case .testModeCardSelection(let amount, let encryptionKey):
            TestModeCardSelectionView(amountDetails: amount,
                                      encryptionKey: encryptionKey,
                                      chargeCardContainer: viewModel)

        case .pin(let encryptionKey):
            CardPinView(encryptionKey: encryptionKey,
                        chargeCardContainer: viewModel)

        case .phoneNumber(let displayMessage):
            CardPhoneView(displayMessage: displayMessage,
                          chargeCardContainer: viewModel)

        case .otp(let displayMessage):
            CardOTPVIew(displayMessage: displayMessage,
                        chargeCardContainer: viewModel)

        case .address(let states, let displayMessage):
            CardAddressView(states: states,
                            displayMessage: displayMessage,
                            chargeCardContainer: viewModel)

        case .birthday(let displayMessage):
            CardBirthdayView(displayMessage: displayMessage,
                             chargeCardContainer: viewModel)

        case .redirect(let urlString, let transactionId):
            CardRedirectView(urlString: urlString,
                             transactionId: transactionId,
                             chargeCardContainer: viewModel)

        case .error(let error):
            errorView(message: error.message)

        case .fatalError(let error):
            ErrorView(message: error.message,
                      automaticallyDismissWith: .init(
                        error: error,
                        transactionReference: viewModel.transactionDetails.reference))

        case .failed(let message):
            errorView(message: message ?? "Declined")
        }
    }

    func errorView(message: String) -> some View {
        ErrorView(message: message,
                  buttonText: viewModel.inTestMode ?
                  "Retry with test details" : "Try another card",
                  buttonAction: viewModel.inTestMode ?
                  viewModel.switchToTestModeCardSelection : viewModel.restartCardPayment)
    }

}
