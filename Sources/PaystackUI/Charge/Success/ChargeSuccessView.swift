import SwiftUI

@available(iOS 14.0, *)
struct ChargeSuccessView: View {

    let amount: AmountCurrency
    let merchant: String
    let completionDetails: ChargeCompletionDetails

    @EnvironmentObject
    var visibilityContainer: ViewVisibilityContainer

    var body: some View {
        VStack(spacing: .singlePadding) {
            Image.successIcon

            Text("Payment Successful")
                .font(.heading3)
                .foregroundColor(.stackBlue)

            Text("You paid \(amount.description) to \(merchant)")
                .font(.body16R)
                .foregroundColor(.navy03)
        }
        .task(dismissAutomatically)
    }

    func dismissAutomatically() async {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        visibilityContainer.completeAndDismiss(with: .completed(completionDetails))
    }
}

@available(iOS 14.0, *)
struct ChargeSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        ChargeSuccessView(amount: .init(amount: 10000, currency: "USD"),
                          merchant: "Merchant",
                          completionDetails: .init(reference: "testReference"))
    }
}
