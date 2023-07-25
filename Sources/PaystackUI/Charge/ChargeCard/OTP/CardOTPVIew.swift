import SwiftUI
import Combine

@available(iOS 14.0, *)
// TODO: Replace constants and colors from design system
struct CardOTPVIew: View {

    @StateObject
    var viewModel: CardOTPViewModel

    private let timer = Timer.publish(every: 1, on: .main, in: .common)

    init(phoneNumber: String,
         chargeCardContainer: ChargeCardContainer) {
        self._viewModel = StateObject(wrappedValue: CardOTPViewModel(
            phoneNumber: phoneNumber,
            chargeCardContainer: chargeCardContainer))
    }

    var body: some View {
        ScrollView {
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
    }

    @ViewBuilder
    var resendOTPSection: some View {
        if viewModel.otpResendAttempts < 2 {
            if viewModel.secondsBeforeResendOTP > 0 {
                Text("Resend OTP in ").foregroundColor(.gray) +
                Text(viewModel.secondsBeforeResendOTP.formatSecondsAsMinutesAndSeconds())
                    .foregroundColor(.green)
            } else {
                Button("Resend OTP", action: resendOTP)
                    .foregroundColor(.green)
            }
        } else {
            otpResendAttemptLimitView
        }
    }

    var otpResendAttemptLimitView: some View {
        Text("We are having trouble sending the OTP. Kindly wait a " +
             "few more minutes or cancel the transaction.")
        .multilineTextAlignment(.center)
        .foregroundColor(.gray)
        .font(.caption)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func resendOTP() {
        viewModel.resendOTP()
        viewModel.subscription = timer.autoconnect()
            .sink { _ in
                viewModel.decreaseOTPCountdownTime()
            }
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
