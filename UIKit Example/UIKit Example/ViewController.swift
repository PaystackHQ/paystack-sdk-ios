import UIKit
import PaystackCore
import PaystackUI

class ViewController: UIViewController {

    let paystack = try? PaystackBuilder
        .newInstance
        .setKey("PUBLIC_KEY")
        .build()

    let paymentAccessCodee = "ACCESS_CODE"

    @IBAction func launchPaymentTapped(_ sender: Any) {
        paystack?.presentChargeUI(on: self,
                                  accessCode: paymentAccessCodee,
                                  onComplete: paymentCompleted)
    }

    func paymentCompleted(_ result: TransactionResult) {
        print("Payment completed. Result: \(result)")
    }

}
