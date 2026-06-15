import SwiftUI

@available(iOS 14.0, *)
struct BankTransferRefundInitiatedView: View {

    let message: String
    let transactionReference: String
    let onChooseAnotherPaymentMethod: () -> Void

    @EnvironmentObject
    var visibilityContainer: ViewVisibilityContainer

    var body: some View {
        VStack(spacing: .triplePadding) {

            Image.errorIcon

            Text("Refund initiated")
                .font(.heading2)
                .foregroundColor(.stackBlue)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.body14R)
                .foregroundColor(.navy02)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .singlePadding)

            Button("Choose another payment method",
                   action: onChooseAnotherPaymentMethod)
                .buttonStyle(PrimaryButtonStyle(showLoading: false))

            Button("Close", action: dismissWithError)
                .foregroundColor(.navy02)
                .font(.body14M)
        }
        .padding(.doublePadding)
    }

    private func dismissWithError() {
        let chargeError = ChargeError(message: message)
        visibilityContainer.completeAndDismiss(
            with: .error(error: chargeError, reference: transactionReference))
    }
}

@available(iOS 14.0, *)
struct BankTransferRefundInitiatedView_Previews: PreviewProvider {
    static var previews: some View {
        BankTransferRefundInitiatedView(
            message: "You sent an incorrect amount. We've started a refund — funds will be returned to the account you sent from within a few business days.",
            transactionReference: "T6215047322I100043S0g703",
            onChooseAnotherPaymentMethod: {})
            .environmentObject(ViewVisibilityContainer(onComplete: { _ in }))
    }
}
