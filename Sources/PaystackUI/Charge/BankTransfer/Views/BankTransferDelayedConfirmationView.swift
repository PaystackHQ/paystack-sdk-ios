import SwiftUI

@available(iOS 14.0, *)
struct BankTransferDelayedConfirmationView: View {

    let supportEmail: String
    let onChangePaymentMethod: () -> Void
    let onKeepWaiting: () -> Void

    var body: some View {
        VStack(spacing: .triplePadding) {

            Text("We'll complete this transaction automatically once we confirm your transfer.")
                .font(.body16M)
                .foregroundColor(.stackBlue)
                .multilineTextAlignment(.center)

            Text("If you have any issues with this transfer, please contact us via \(supportEmail) with the following details:")
                .font(.body14R)
                .foregroundColor(.stackBlue)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: .singlePadding) {
                NumberedListRow(index: 1, text: "Recipient Account")
                NumberedListRow(index: 2, text: "Sender Account")
                NumberedListRow(index: 3, text: "Amount Paid")
                NumberedListRow(index: 4, text: "Date of Payment")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, .doublePadding)

            Button("Change payment method", action: onChangePaymentMethod)
                .buttonStyle(SecondaryButtonStyle())

            Button("Keep waiting", action: onKeepWaiting)
                .foregroundColor(.navy02)
                .font(.body14M)
        }
        .padding(.doublePadding)
    }
}

@available(iOS 14.0, *)
private struct NumberedListRow: View {
    let index: Int
    let text: String

    var body: some View {
        HStack(spacing: .singlePadding) {
            Text("\(index).")
                .font(.body14R)
                .foregroundColor(.stackBlue)
            Text(text)
                .font(.body14R)
                .foregroundColor(.stackBlue)
        }
    }
}
