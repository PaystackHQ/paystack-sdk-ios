import SwiftUI
import PaystackCore
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 14.0, *)
struct ZapPaymentView: View {

    let details: ZapDetails
    let remainingSeconds: Int
    let onChangePaymentMethod: () -> Void

    let showsOpenZapButton: Bool

    private var formattedRemaining: String {
        let minutes = max(0, remainingSeconds) / 60
        let seconds = max(0, remainingSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var countdownValueColor: Color {
        remainingSeconds <= 60 ? .warning02 : .stackGreen
    }

    var body: some View {
        ScrollView {
            VStack(spacing: .triplePadding) {

                zapHeader

                Text("Open Zap or scan this QR code to complete this payment")
                    .font(.body16M)
                    .foregroundColor(.stackBlue)
                    .multilineTextAlignment(.center)

                qrCodeBlock

                expiresInRow

                actionButtons
            }
            .padding(.doublePadding)
        }
    }

    // MARK: - Subviews

    private var zapHeader: some View {

        Image("zapLogo", bundle: .current)
            .resizable()
            .scaledToFit()
            .frame(height: 32)
    }

    private var qrCodeBlock: some View {
        QRCodeImage(url: details.qrImageURL)
            .frame(width: 220, height: 220)
            .padding(.singlePadding)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color.navy05, lineWidth: 1))
    }

    private var expiresInRow: some View {
        HStack(spacing: 4) {
            Text("Expires in")
                .font(.body14M)
                .foregroundColor(.navy03)
            Text(formattedRemaining)
                .font(.body14M)
                .foregroundColor(countdownValueColor)
                .animation(.easeInOut(duration: 0.2), value: countdownValueColor)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: .singlePadding) {
            if showsOpenZapButton {
                Button("Open Zap", action: openZap)
                    .buttonStyle(PrimaryButtonStyle(showLoading: false))
            }

            Button("Change payment method", action: onChangePaymentMethod)
                .foregroundColor(.navy02)
                .font(.body14M)
                .padding(.top, .singlePadding)
        }
    }

    // MARK: - Actions

    private func openZap() {
        #if canImport(UIKit)
        UIApplication.shared.open(details.paymentURL,
                                  options: [:], completionHandler: nil)
        #endif
    }
}

@available(iOS 14.0, *)
struct ZapPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZapPaymentView(details: .example,
                           remainingSeconds: 254,
                           onChangePaymentMethod: {},
                           showsOpenZapButton: true)
                .previewDisplayName("Default — Open Zap + Change payment method")

            ZapPaymentView(details: .example,
                           remainingSeconds: 254,
                           onChangePaymentMethod: {},
                           showsOpenZapButton: false)
                .previewDisplayName("QR-only (terminal mode)")

            ZapPaymentView(details: .example,
                           remainingSeconds: 42,
                           onChangePaymentMethod: {},
                           showsOpenZapButton: true)
                .previewDisplayName("Final 60s — countdown warning colour")
        }
    }
}
