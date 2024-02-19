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

    func paymentDone(_ result: TransactionResult) {

        switch result {
        case .completed(let chargeDetails):
            print("Success: Transaction reference : \(chargeDetails.reference)")
        case .cancelled:
            print("Transaction was cancelled.")
        case .error(error: let error, reference: let reference):
            print("An error occured with \(reference!) : \(error.message)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
