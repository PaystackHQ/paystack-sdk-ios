import Foundation
import SwiftUI
import PaystackCore

@available(iOS 14.0, *)
@available(macOS, unavailable)
public extension Paystack {

    /// Creates a SwiftUI Button to intiate the charge flow using Paystack's UI
    /// - Parameters:
    ///   - accessCode: Access code generated from your backend
    ///   - onComplete: Provide a closure for what should execute once the flow has completed, provides the ``TransactionResult`` of the transaction
    ///   - button: Provide styling for your Button
    /// - Returns: A SwiftUI `Button` that should be placed in your view as an initiation point for the flow
    ///
    /// Example Usage:
    /// ```swift
    /// paystackObject.chargeUIButton(accessCode: "Access_Code",
    ///     onComplete: viewModel.onPaymentComplete) {
    ///     Text("Pay")
    /// }
    ///
    func chargeUIButton<Content: View>(
        accessCode: String,
        onComplete: @escaping (TransactionResult) -> Void,
        @ViewBuilder button: @escaping () -> Content) -> some View {
            initializeSDK()
            return NavigationalButton(
                onComplete: onComplete,
                destination: ChargeView(accessCode: accessCode)) { button() }

        }

    #if os(iOS)
    /// Starts the charge flow on a view controller provided
    /// - Parameters:
    ///   - viewController: The view controller that will be used for presentation. Must not be currently presenting something.
    ///   - accessCode: Access code generated from your backend
    ///   - onComplete: Provide a closure for what should execute once the flow has completed, provides the ``TransactionResult`` of the transaction
    ///
    /// Example Usage:
    /// ```swift
    /// paystackObject.presentChargeUI(on: self, accessCode: "Access_Code",
    ///     onComplete: viewModel.onPaymentComplete)
    func presentChargeUI(
        on viewController: UIViewController,
        accessCode: String,
        onComplete: @escaping (TransactionResult) -> Void) {
            initializeSDK()
            let visibilityContainer = ViewVisibilityContainer(onComplete: onComplete,
                                                              parentViewController: viewController)
            let chargeCardViewController = UIHostingController(
                rootView: ChargeView(accessCode: accessCode)
                    .environmentObject(visibilityContainer))
            viewController.present(chargeCardViewController, animated: true)
        }
    #endif
}

// MARK: Paystack UI Initialization
extension Paystack {

    func initializeSDK() {
        registerFonts()
        PaystackContainer.instance.store(self)
    }

}
