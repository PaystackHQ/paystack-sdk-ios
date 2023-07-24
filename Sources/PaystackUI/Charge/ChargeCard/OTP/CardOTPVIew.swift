import SwiftUI
import Combine

@available(iOS 14.0, *)
// TODO: Replace constants and colors from design system
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
        VStack(spacing: 24) {
            Image.otpIcon

            Text("Please enter the OTP sent to \(viewModel.phoneNumber)")
                .font(.headline)
                .multilineTextAlignment(.center)

            FormInput(title: "Authorize",
                      enabled: viewModel.isValid,
                      action: viewModel.submitOTP,
                      cancelAction: viewModel.cancelTransaction,
                      supplementaryContent: resendOTPSection) {
                otpField
            }
        }
        .padding(16)
    }

    @ViewBuilder
    var resendOTPSection: some View {
        // TODO: Will flesh out in the next PR
        Button("Resend OTP", action: resendOTP)
                        .foregroundColor(.green)
    }

    private func resendOTP() {
        // TODO: Will add resend logic in next PR
    }

    @ViewBuilder
    var otpField: some FormInputItemView {
        TextFieldFormInputView(title: "OTP",
                               placeholder: "123456",
                               text: $viewModel.otp,
                               keyboardType: .numberPad)
    }
}

@available(iOS 14.0, *)
struct CardOTPVIew_Previews: PreviewProvider {
    static var previews: some View {
        CardOTPVIew(phoneNumber: "+234801****5678",
                    chargeCardContainer: ChargeCardViewModel(
            amountDetails: .init(amount: 100000, currency: "USD")))
    }
}
