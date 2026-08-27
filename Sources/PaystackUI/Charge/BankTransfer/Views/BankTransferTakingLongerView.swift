import SwiftUI

@available(iOS 14.0, *)
struct BankTransferTakingLongerView: View {

    let details: BankTransferDetails
    let onGetHelp: () -> Void
    let onBackToAccountNumber: () -> Void
    let onChangePaymentMethod: () -> Void

    var body: some View {
        VStack(spacing: .triplePadding) {

            Text("It's taking longer than expected to confirm your transfer. "
                 + "You don't have to wait here till we confirm it.")
                .font(.body16M)
                .foregroundColor(.contentPrimary)
                .multilineTextAlignment(.center)

            timeline

            Button("Get help", action: onGetHelp)
                .buttonStyle(PrimaryButtonStyle(showLoading: false))

            Button("Back to account number", action: onBackToAccountNumber)
                .foregroundColor(.contentSecondary)
                .font(.body14M)

            Button("Change payment method", action: onChangePaymentMethod)
                .foregroundColor(.contentSecondary)
                .font(.body14M)
        }
        .padding(.doublePadding)
    }

    private var timeline: some View {
        HStack(spacing: 0) {
            TimelineNode(label: "Sent", state: .complete)
            Rectangle()
                .fill(Color.trackInactive)
                .frame(height: 1)
                .padding(.horizontal, .singlePadding)
            TimelineNode(label: "Received", state: .pending)
        }
        .padding(.horizontal, .triplePadding)
    }
}
