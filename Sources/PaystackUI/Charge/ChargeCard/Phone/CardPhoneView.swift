import SwiftUI

@available(iOS 14.0, *)
struct CardPhoneView: View {

    @StateObject
    var viewModel: CardPhoneViewModel

    private let phoneNumberMaximumLength = 15

    @State
    private var showPhoneNumberError = false

    init(chargeCardContainer: ChargeCardContainer) {
        self._viewModel = StateObject(wrappedValue: CardPhoneViewModel(
            chargeCardContainer: chargeCardContainer))
    }

    var body: some View {
        VStack(spacing: .triplePadding) {
            Image.otpIcon

            Text("Please enter your mobile phone number (at least 10 digits)")
                .font(.body16M)
                .foregroundColor(.stackBlue)
                .multilineTextAlignment(.center)

            FormInput(title: "Send OTP",
                      enabled: viewModel.isValid,
                      action: viewModel.submitPhoneNumber,
                      secondaryAction: viewModel.cancelTransaction) {
                phoneNumber
            }
        }
        .padding(.doublePadding)
    }

    @ViewBuilder
    var phoneNumber: some FormInputItemView {
        TextFieldFormInputView(title: "Phone Number",
                               placeholder: "08012345678",
                               text: $viewModel.phoneNumber,
                               keyboardType: .phonePad,
                               maxLength: phoneNumberMaximumLength,
                               inErrorState: $showPhoneNumberError,
                               defaultFocused: true)
        .minLength(10, errorMessage: "Invalid Phone Number")
    }
}

@available(iOS 14.0, *)
struct CardPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        CardPhoneView(chargeCardContainer: ChargeCardViewModel(
            transactionDetails: .example))
    }
}
