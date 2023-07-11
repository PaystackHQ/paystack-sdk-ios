import SwiftUI

struct ChargeSuccessView: View {

    let amount: AmountCurrency
    let merchant: String

    var body: some View {
        VStack(spacing: 8) {
            Image.successIcon

            Text("Payment Successful")
                .font(.headline)

            Text("You paid \(amount.description) to \(merchant)")
                .font(.body)
                .foregroundColor(.gray)
        }
    }
}

struct ChargeSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        ChargeSuccessView(amount: .init(amount: 100, currency: "USD"),
                          merchant: "Merchant")
    }
}
