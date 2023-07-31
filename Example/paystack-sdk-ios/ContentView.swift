import SwiftUI
import PaystackCore
import PaystackUI
import PusherSwift

struct ContentView: View {
    let paystackObject = try? PaystackBuilder
        .newInstance
        .setKey("testsk_exampleKey")
        .build()

    var body: some View {
        VStack(spacing: 8) {
            Text("Paystack SDK Example App")

            paystackObject?.chargeUIButton(accessCode: "test",
                                           onComplete: paymentDone) {
                    Text("Initiate Payment")
                }
        }
        .padding()
    }

    func paymentDone(_ result: TransactionResult) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
