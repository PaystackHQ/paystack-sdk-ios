import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 14.0, *)
struct QRDisplayView: View {

    let variant: QRVariant
    let details: QRDetails
    let amount: AmountCurrency
    let inlineBanner: String?
    let onICompletedPayment: () -> Void
    let onChangePaymentMethod: () -> Void

    @Environment(\.displayAudience)
    private var displayAudience

    @State private var showCopiedToast = false
    @State private var showsAppPicker = false

    var body: some View {
        Group {
            if showsAppPicker, let qrCode = deeplinkQRCode {
                ScanToPayAppPickerView(qrCode: qrCode,
                                       onBack: { showsAppPicker = false })
            } else {
                paymentDetails
            }
        }
        .copiedToast(isPresented: $showCopiedToast)
    }

    private var paymentDetails: some View {
        ScrollView {
            VStack(spacing: .triplePadding) {

                headerLogo

                Text(instructionText)
                    .font(.body16M)
                    .foregroundColor(.contentPrimary)
                    .multilineTextAlignment(.center)

                if showsQRCode {
                    qrCodeBlock
                }

                Text(amount.description)
                    .font(.body16M)
                    .foregroundColor(.contentPrimary)

                if showsQRNumber, let qrCode = deeplinkQRCode {
                    qrReferenceRow(reference: qrCode)
                }

                if let banner = inlineBanner {
                    inlineBannerView(banner)
                }

                actionButtons
            }
            .padding(.doublePadding)
        }
    }

    private var deeplinkQRCode: String? {
        guard variant.supportsAppDeeplinks,
              let qrCode = details.qrReference,
              !qrCode.isEmpty else { return nil }
        return qrCode
    }

    private var deeplinksAvailable: Bool {
        deeplinkQRCode != nil
    }

    private var instructionText: String {
        deeplinksAvailable ? displayAudience.text(.scanToPayInstruction) : variant.instructionCopy
    }

    private var showsQRCode: Bool {
        !deeplinksAvailable || displayAudience.shows(.scanToPayQRCode)
    }

    private var showsQRNumber: Bool {
        deeplinksAvailable && displayAudience.shows(.scanToPayQRNumber)
    }

    private var showsSeeAppsButton: Bool {
        deeplinksAvailable && displayAudience.shows(.scanToPaySeeAppsButton)
    }

    private var headerLogo: some View {
        Image(variant.logoAsset, bundle: .current)
            .resizable()
            .scaledToFit()
            .frame(height: 32)
    }

    private var qrCodeBlock: some View {
        QRCodeImage(url: details.qrImageURL)
            .frame(width: 180, height: 180)
            .padding(.singlePadding)
            .background(Color.qrPlate)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color.borderPrimary, lineWidth: 1))
    }

    private func qrReferenceRow(reference: String) -> some View {
        Button(action: { copy(reference) }) {
            HStack(spacing: .singlePadding) {
                Text(reference)
                    .font(.body16M)
                    .foregroundColor(.contentPrimary)
                Image(systemName: "doc.on.doc")
                    .foregroundColor(.contentSecondary)
                    .imageScale(.medium)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func inlineBannerView(_ text: String) -> some View {
        Text(text)
            .font(.body14M)
            .foregroundColor(.contentWarning)
            .multilineTextAlignment(.center)
            .padding(.singlePadding)
            .frame(maxWidth: .infinity)
            .background(Color.warningSurface)
            .cornerRadius(.cornerRadius)
    }

    private var actionButtons: some View {
        VStack(spacing: .singlePadding) {
            if showsSeeAppsButton {
                Button("See Scan to Pay apps", action: { showsAppPicker = true })
                    .buttonStyle(PrimaryButtonStyle(showLoading: false))

                Button("I've completed payment", action: onICompletedPayment)
                    .buttonStyle(SecondaryButtonStyle())
            } else {
                Button("I've completed payment", action: onICompletedPayment)
                    .buttonStyle(PrimaryButtonStyle(showLoading: false))
            }

            Button("Change payment method", action: onChangePaymentMethod)
                .foregroundColor(.contentSecondary)
                .font(.body14M)
                .padding(.top, .singlePadding)
        }
    }

    private func copy(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #endif
        withAnimation(.easeInOut(duration: 0.2)) {
            showCopiedToast = true
        }
    }
}

@available(iOS 14.0, *)
struct QRDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            QRDisplayView(
                variant: .scanToPay,
                details: .scanToPayExample,
                amount: AmountCurrency(amount: 4500, currency: "ZAR"),
                inlineBanner: nil,
                onICompletedPayment: {},
                onChangePaymentMethod: {})
                .environment(\.displayAudience, .customerFacing)
                .previewDisplayName("Scan to Pay — customer-facing (number + apps)")

            QRDisplayView(
                variant: .scanToPay,
                details: .scanToPayExample,
                amount: AmountCurrency(amount: 4500, currency: "ZAR"),
                inlineBanner: nil,
                onICompletedPayment: {},
                onChangePaymentMethod: {})
                .environment(\.displayAudience, .merchantFacing)
                .previewDisplayName("Scan to Pay — merchant-facing (QR only)")

            QRDisplayView(
                variant: .snapScan,
                details: .snapScanExample,
                amount: AmountCurrency(amount: 4500, currency: "ZAR"),
                inlineBanner: nil,
                onICompletedPayment: {},
                onChangePaymentMethod: {})
                .previewDisplayName("Snap Scan — awaiting scan")

            QRDisplayView(
                variant: .scanToPay,
                details: .scanToPayExample,
                amount: AmountCurrency(amount: 4500, currency: "ZAR"),
                inlineBanner: "We couldn't confirm your payment yet — please try again in a moment",
                onICompletedPayment: {},
                onChangePaymentMethod: {})
                .previewDisplayName("Scan to Pay — with inline banner (post-pending)")
        }
    }
}
