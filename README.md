# Paystack iOS SDK

## Getting started with the Example app:
We currently have two variations of Example apps.

- A SwiftUI example app integrating the SDK using Cocoapods can be found inside the `Example` folder
- A UIKit example app integrating the SDK using Swift Package Manager can be found inside in the `UIKit Example` folder

To get started with either of these:
- Open the associated project file.
- Inside `ContentView.swift` (SwiftUI Example App) or `ViewController.swift` (UIKit Example app), modify the Paystack object that is being built to include the public key of the integration being used.

```swift
  let paystackObject = try? PaystackBuilder
        .newInstance
        .setKey("PUBLIC KEY GOES HERE")
        .build()
```
- Whenever a transaction has been created on your integration, you will provide the associated access code to the application where designated in the files above. 

You are now able to use the Example app to test live payments on your integration.

## Integrating the SDK into your app:
We have two modules: `PaystackCore` and `PaystackUI`
We recommend those who want to make use of our Payment flows to use both.
However, if you are just looking for just the basic APIs, you only need to import `PaystackCore`

### Swift Package Manager:
To install the SDK using [Swift Package Manager](https://github.com/apple/swift-package-manager) you can follow the [tutorial published by Apple](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) using the URL for the Paystack SDK repo with the current version:

1. In Xcode, select “File” → “Add Packages...”
2. Enter https://github.com/PaystackHQ/paystack-sdk-ios.git

After installing with Swift package Manager into your project import it using
```swift
import PaystackCore
import PaystackUI
```

## Using the PaymentUI payment flow
Our recommended way to use the SDK is to make use of the payment flow we provide. 

### SwiftUI
For SwiftUI, we provide a customizable button that inserts directly into your UI.

```swift
paystackObject?.chargeUIButton(accessCode: "transaction access code",
                onComplete: paymentDone) {
    // Stylize your button 
    Text("Pay")
}

func paymentDone(_ result: TransactionResult) {
    switch (result){
    case .completed(let details):
        print("Transaction completed with reference: \(details.reference)")
    case .cancelled:
        print("Transaction was cancelled")
    case .error(error: let error, reference: let reference):
        print("An error occured: \(error.message) with reference: \(String(describing: reference))")
    }
}
```

### UIKit 
For UIKit, you would create your own button to trigger the flow and provide a reference to the view controller being displayed.

```swift
@IBAction func payButtonTapped(_ sender: Any) {
        paystack?.presentChargeUI(on: self,
                                  accessCode: "transaction access code",
                                  onComplete: paymentDone)
}

func paymentDone(_ result: TransactionResult) {
    switch (result){
    case .completed(let details):
        print("Transaction completed with reference: \(details.reference)")
    case .cancelled:
        print("Transaction was cancelled")
    case .error(error: let error, reference: let reference):
        print("An error occured: \(error.message) with reference: \(String(describing: reference))")
    }
}
```

### Handling the Transaction Result
There are 3 possibly results that can be returned

 - `Completed`: The customer completed the payment process. Verify the transaction status and amount on the server before providing value. See [Paystack's docs](https://paystack.com/docs/payments/verify-payments/)
 - `Cancelled`: The customer cancelled the payment attempt.
 - `Failed`: An error occurred during the payment process. This result contains a `ChargeError`. The `ChargeError` contains a `cause` property which details the actual error received and should be used for error handling and logging.
