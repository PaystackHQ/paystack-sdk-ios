# Paystack iOS SDK

Accept payments in your iOS app with Paystack. The SDK gives you a ready-made payment flow that takes the customer from choosing a payment method to a completed payment.

## Requirements

| | |
|---|---|
| iOS | **14.0+** for the payment flow. The package can be added to apps that target iOS 13, but the payment flow is only available on iOS 14 and later. |
| macOS | Not supported |
| Swift | 5.7+ (Xcode 14+) |

## Installation

We recommend installing the SDK with [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app):

1. In Xcode, select **File → Add Package Dependencies…**
2. Enter `https://github.com/PaystackHQ/paystack-sdk-ios.git`
3. Add both the `PaystackCore` and `PaystackUI` libraries to your app target.

> **CocoaPods:** the SDK isn't published to CocoaPods trunk. It can only be used as a local pod, by pointing your `Podfile` at a local copy of this repo. CocoaPods support will be discontinued from **2 December 2026**, so please use Swift Package Manager.

Then import both where you start a payment:
```swift
import PaystackCore
import PaystackUI
```

## Setting up Paystack

Build a `Paystack` object with your integration's **public key**. Never put your secret key in an app.

```swift
let paystack = try? PaystackBuilder
    .newInstance
    .setKey("pk_live_xxxxxxxx")
    .build()
```

Optional builder settings:

| Method | What it does | Default |
|---|---|---|
| `setDisplayAudience(_:)` | Tailors the payment UI to who is holding the device. See [Display audience](#display-audience) | `.customerFacing` |
| `enableLogging()` | Prints SDK logs to the console. Useful while integrating; leave it off in production | Off |

```swift
let paystack = try? PaystackBuilder
    .newInstance
    .setKey("pk_live_xxxxxxxx")
    .setDisplayAudience(.merchantFacing)
    .enableLogging()
    .build()
```

## Accepting a payment

1. Initialize a transaction **on your server** with the [Initialize Transaction API](https://paystack.com/docs/api/transaction/#initialize) and send the returned `access_code` to your app.
2. Start the payment flow with that access code.
3. When the flow finishes, **verify the transaction on your server** before giving value.

### SwiftUI
`chargeUIButton` returns a button you can style. Tapping it opens the payment flow.

```swift
paystack?.chargeUIButton(accessCode: "transaction access code",
                         onComplete: paymentDone) {
    Text("Pay")
}
```

### UIKit
Call `presentChargeUI` from your own button. The flow is presented on the view controller you pass in, which must not already be presenting something.

```swift
@IBAction func payButtonTapped(_ sender: Any) {
    paystack?.presentChargeUI(on: self,
                              accessCode: "transaction access code",
                              onComplete: paymentDone)
}
```

### Handling the transaction result
Both entry points call `onComplete` with a `TransactionResult`:

```swift
func paymentDone(_ result: TransactionResult) {
    switch result {
    case .completed(let details):
        print("Transaction completed with reference: \(details.reference)")
    case .cancelled:
        print("Transaction was cancelled")
    case .error(let error, let reference):
        print("An error occurred: \(error.message), reference: \(String(describing: reference))")
    }
}
```

| Result | Meaning |
|---|---|
| `.completed(ChargeCompletionDetails)` | The customer finished the payment process. **Verify the transaction status and amount on your server** before giving value, using webhooks or the [Verify Transaction API](https://paystack.com/docs/payments/verify-payments/). |
| `.cancelled` | The customer closed the payment flow. |
| `.error(error: ChargeError, reference: String?)` | Something went wrong. `error.message` is safe to show the customer; `error.cause` holds the underlying error for your logs. |

## Supported payment methods

The SDK shows the payment methods that are **enabled on your integration**, that **suit the transaction's currency**, and that the **SDK supports**. If only one method qualifies, the flow opens it straight away. Otherwise the customer chooses from a list.

| Country | Currency | Payment methods in the SDK |
|---|---|---|
| Nigeria | NGN | Card, Bank Transfer (Pay with Transfer), Zap |
| Ghana | GHS | Card, Mobile Money: MTN, AirtelTigo, Telecel |
| Kenya | KES | Card, Mobile Money: M-Pesa, Airtel Money, Pesalink (bank transfer) |
| Côte d'Ivoire | XOF | Card |
| South Africa | ZAR | Card, Capitec Pay, Scan to Pay, SnapScan |

Other channels you may have enabled on your integration (for example Apple Pay) aren't available in the SDK yet and won't be shown. If none of your enabled channels is supported, the customer sees a message asking them to contact you.

## Display audience

Some payment methods work differently depending on who is holding the device:

- **`.customerFacing`** (default): the customer is paying on their own phone, for example in your shopping app.
- **`.merchantFacing`**: the merchant holds the device and shows the screen to the customer, for example in a point-of-sale or terminal app.

Set it once on the builder (see [Setting up Paystack](#setting-up-paystack)). It applies to every payment started from that `Paystack` object, in both SwiftUI and UIKit.

| Payment method | Customer-facing | Merchant-facing |
|---|---|---|
| Zap | "Open Zap" button that opens the Zap app | QR code for the customer to scan with Zap |
| Scan to Pay | The payment code with a copy button, and **See Scan to Pay apps**, which lists supported banking and wallet apps and opens the chosen one | QR code for the customer to scan |
| Bank Transfer / Pesalink | Account details with copy buttons | Account details without copy buttons |
| All other methods | Unchanged | Unchanged |

If your app doesn't call `setDisplayAudience(_:)`, nothing changes: the UI is customer-facing.

**Scan to Pay app links:** the SDK opens banking apps with links. You don't need to add anything to your app's `Info.plist`. If the customer doesn't have the chosen app installed, the SDK tells them so.

## Appearance

The payment UI supports light and dark mode and follows the device's appearance setting.

## Testing

Use your integration's **test** public key and an access code from a test transaction. The payment UI shows a **TEST** badge while you're in test mode.

For test cards and other test details, see Paystack's [test payments guide](https://paystack.com/docs/payments/test-payments/).

## Example apps

The repo includes two example apps:

- **`Example/`**: a SwiftUI app.
- **`UIKit Example/`**: a UIKit app.

To run one:
1. Open its project. For `Example/`, run `pod install` in that folder first and open the `.xcworkspace`.
2. In `ContentView.swift` (SwiftUI) or `ViewController.swift` (UIKit), set your public key on the `PaystackBuilder`.
3. Initialize a transaction on your integration and paste its access code where indicated.

The example apps make real payments when you use a live key.
