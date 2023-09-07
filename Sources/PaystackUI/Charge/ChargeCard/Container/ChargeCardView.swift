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

        case .phoneNumber:
            CardPhoneView(chargeCardContainer: viewModel)

        case .otp(let phoneNumber):
            CardOTPVIew(phoneNumber: phoneNumber,
                        chargeCardContainer: viewModel)

        case .address(let states):
            CardAddressView(states: states,
                            chargeCardContainer: viewModel)

        case .birthday:
            CardBirthdayView(chargeCardContainer: viewModel)

        case .error(let error):
            errorView(message: error.message)

        case .failed:
            errorView(message: "Declined")
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
