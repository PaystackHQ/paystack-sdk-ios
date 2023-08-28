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
        case .cardDetails(let amount):
            CardDetailsView(amountDetails: amount,
                            chargeCardContainer: viewModel)

        case .testModeCardSelection(let amount):
            TestModeCardSelectionView(amountDetails: amount,
                                      chargeCardContainer: viewModel)

        case .pin:
            CardPinView(chargeCardContainer: viewModel)

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
            ErrorView(message: error.message,
                      buttonText: viewModel.inTestMode ?
                      "Retry with test details" : "Try another card",
                      buttonAction: viewModel.inTestMode ?
                      viewModel.switchToTestModeCardSelection : viewModel.restartCardPayment)
        }
    }

}
