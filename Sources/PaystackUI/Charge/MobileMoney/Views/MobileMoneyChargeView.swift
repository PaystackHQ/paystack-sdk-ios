import SwiftUI

@available(iOS 14.0, *)
struct MobileMoneyChargeView: View {

    @StateObject
    var viewModel: MobileMoneyChargeViewModel
    private let phoneNumberMaximumLength = 15
    @State private var showPhoneNumberError = false

    init(
         chargeCardContainer: ChargeContainer,
         transactionDetails: VerifyAccessCode,
         provider: MobileMoneyChannel) {
        self._viewModel = StateObject(wrappedValue: MobileMoneyChargeViewModel(
            chargeCardContainer: chargeCardContainer,
            transactionDetails: transactionDetails,
            provider: provider))
    }

    var body: some View {
        switch viewModel.transactionState {
        case .loading(let message):
            LoadingView(message: message)
        case .error(let chargeError):
            ErrorView(message: chargeError.message,
                      buttonText: "Try again",
                      buttonAction: viewModel.restartMobileMoneyPayment)
        case .fatalError(let error):
            ErrorView(message: error.message,
                      automaticallyDismissWith: .init(
                        error: error,
                        transactionReference: viewModel.transactionDetails.reference))
        case .processTransaction(let transaction):
            MobileMoneyProcessingView(container: viewModel,
                                      mobileMoneyTransaction: transaction)
        case .countdown:
            VStack(spacing: .triplePadding) {

                Text("Please enter your mobile money number to begin this payment")
                    .font(.body16M)
                    .foregroundColor(.stackBlue)
                    .multilineTextAlignment(.center)

                FormInput(title: "Pay  \(viewModel.transactionDetails.amountCurrency.description)",
                          enabled: viewModel.isValid,
                          action: viewModel.submitPhoneNumber,
                          secondaryAction: viewModel.cancelTransaction) {
                    phoneNumber
                }
            }
            .padding(.doublePadding)
        }
    }

    @ViewBuilder
    var phoneNumber: some FormInputItemView {
        
        TextFieldFormInputView(title: "Phone Number",
                               placeholder: "070 000 0000",
                               text: $viewModel.phoneNumber,
                               keyboardType: .phonePad,
                               maxLength: phoneNumberMaximumLength,
                               inErrorState: $showPhoneNumberError,
                               defaultFocused: true,
                               accessoryView: viewModel.provider.phoneInputAccessory)
        .minLength(10, errorMessage: "Invalid Phone Number")
    }
}
