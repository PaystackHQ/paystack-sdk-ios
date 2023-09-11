import SwiftUI
import Combine

@available(iOS 14.0, *)
struct CardOTPVIew: View {

    @StateObject
    var viewModel: CardOTPViewModel

    let displayMessage: String

    init(displayMessage: String?,
         chargeCardContainer: ChargeCardContainer) {
        self.displayMessage = displayMessage ?? "Please enter the OTP sent to your mobile number"
        self._viewModel = StateObject(wrappedValue: CardOTPViewModel(
            chargeCardContainer: chargeCardContainer))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: .triplePadding) {
                Image.otpIcon

                Text(displayMessage)
                    .font(.body16M)
                    .foregroundColor(.stackBlue)
                    .multilineTextAlignment(.center)

                FormInput(title: "Authorize",
                          enabled: viewModel.isValid,
                          action: viewModel.submitOTP,
                          secondaryAction: viewModel.cancelTransaction) {
                    otpField
                }
            }
            .padding(.doublePadding)
        }
    }

    @ViewBuilder
    var otpField: some FormInputItemView {
        TextFieldFormInputView(title: "OTP",
                               placeholder: "123456",
                               text: $viewModel.otp,
                               keyboardType: .numberPad,
                               defaultFocused: true)
    }
}

@available(iOS 14.0, *)
struct CardOTPVIew_Previews: PreviewProvider {
    static var previews: some View {
        CardOTPVIew(displayMessage: nil,
                    chargeCardContainer: ChargeCardViewModel(
                        transactionDetails: .example,
                        chargeContainer: ChargeViewModel(accessCode: "access_code")))
    }
}
