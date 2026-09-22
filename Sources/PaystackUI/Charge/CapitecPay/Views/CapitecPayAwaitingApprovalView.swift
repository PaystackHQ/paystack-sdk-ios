import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 14.0, *)
struct CapitecPayAwaitingApprovalView: View {

    let remainingSeconds: Int
    let isRequerying: Bool
    let onIveApprovedThePayment: () -> Void
    let onChangePaymentMethod: () -> Void

    private var formattedRemaining: String {
        let minutes = max(0, remainingSeconds) / 60
        let seconds = max(0, remainingSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var countdownValueColor: Color {
        remainingSeconds <= 60 ? .contentWarning : .accentPrimary
    }

    var body: some View {
        ScrollView {
            VStack(spacing: .triplePadding) {

                Text("Complete your payment")
                    .font(.heading2)
                    .foregroundColor(.contentPrimary)
                    .multilineTextAlignment(.center)

                stepsCard

                progressSection

                Button("I've approved the payment", action: onIveApprovedThePayment)
                    .buttonStyle(SecondaryButtonStyle())

                Button("Change payment method", action: onChangePaymentMethod)
                    .foregroundColor(.contentSecondary)
                    .font(.body14M)
                    .padding(.top, .singlePadding)
            }
            .padding(.doublePadding)
        }
    }

    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: .singlePadding) {
            step("Open your ", bold: "Capitec app")
            step("Tap on ", bold: "Transact", trailing: " in the bottom navigation")
            step("Tap on ", bold: "Capitec Pay")
            step("Tap on ", bold: "Pay", trailing: " to approve the payment")
        }
        .padding(.horizontal,.doublePadding)
        .padding(.vertical,.singlePadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surfaceTertiary)
        .cornerRadius(.cornerRadius)
    }

    @ViewBuilder
    private func step(_ prefix: String, bold: String, trailing: String = "") -> some View {
        HStack(alignment: .center, spacing: .singlePadding) {
            Circle()
                .fill(Color.accentPrimary)
                .frame(width: 6, height: 6)
            (Text(prefix).font(.body14R)
             + Text(bold).font(.body14M)
             + Text(trailing).font(.body14R))
                .foregroundColor(.contentPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var progressSection: some View {
        if isRequerying {
            VStack(spacing: .singlePadding) {
                ProgressView()
                    .progressViewStyle(.circular)
                Text("Confirming payment…")
                    .font(.body14M)
                    .foregroundColor(.contentSecondary)
            }
            .padding(.vertical, .singlePadding)
        } else {
            VStack(spacing: .singlePadding) {
                HStack(spacing: 4) {
                    Text("Approve payment in")
                        .foregroundColor(.contentTertiary)
                    Text(formattedRemaining)
                        .foregroundColor(countdownValueColor)
                        .animation(.easeInOut(duration: 0.2), value: countdownValueColor)
                }
                .font(.body14M)
            }
            .padding(.vertical, .singlePadding)
        }
    }
}

@available(iOS 14.0, *)
struct CapitecPayAwaitingApprovalView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CapitecPayAwaitingApprovalView(
                remainingSeconds: 96,
                isRequerying: false,
                onIveApprovedThePayment: {},
                onChangePaymentMethod: {})
                .previewDisplayName("Countdown")

            CapitecPayAwaitingApprovalView(
                remainingSeconds: 42,
                isRequerying: false,
                onIveApprovedThePayment: {},
                onChangePaymentMethod: {})
                .previewDisplayName("Final 60s")

            CapitecPayAwaitingApprovalView(
                remainingSeconds: 0,
                isRequerying: true,
                onIveApprovedThePayment: {},
                onChangePaymentMethod: {})
                .previewDisplayName("Requerying")
        }
    }
}
