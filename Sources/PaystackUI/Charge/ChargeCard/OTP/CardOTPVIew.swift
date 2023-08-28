import SwiftUI
import Combine

@available(iOS 14.0, *)
struct CardOTPVIew: View {

    @StateObject
    var viewModel: CardOTPViewModel

    init(phoneNumber: String,
         chargeCardContainer: ChargeCardContainer) {
        self._viewModel = StateObject(wrappedValue: CardOTPViewModel(
            phoneNumber: phoneNumber,
            chargeCardContainer: chargeCardContainer))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: .triplePadding) {
                Image.otpIcon

                Text("Please enter the OTP sent to \(viewModel.phoneNumber)")
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
        CardOTPVIew(phoneNumber: "+234801****5678",
                    chargeCardContainer: ChargeCardViewModel(
                        transactionDetails: .example,
                        chargeContainer: ChargeViewModel(accessCode: "access_code")))
    }
}
