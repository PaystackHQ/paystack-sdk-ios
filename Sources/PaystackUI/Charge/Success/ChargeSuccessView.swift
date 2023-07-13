import SwiftUI

// TODO: Replace constants from Design System
@available(iOS 14.0, *)
struct ChargeSuccessView: View {

    let amount: AmountCurrency
    let merchant: String

    @EnvironmentObject
    var visibilityContainer: ViewVisibilityContainer

    var body: some View {
        VStack(spacing: 8) {
            Image.successIcon

            Text("Payment Successful")
                .font(.headline)

            Text("You paid \(amount.description) to \(merchant)")
                .font(.body)
                .foregroundColor(.gray)
        }
        .task(dismissAutomatically)
    }

    func dismissAutomatically() async {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        visibilityContainer.completeAndDismiss(with: .success)
    }
}

@available(iOS 14.0, *)
struct ChargeSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        ChargeSuccessView(amount: .init(amount: 100, currency: "USD"),
                          merchant: "Merchant")
    }
}
