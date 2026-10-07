import Foundation

/// Describes who the Paystack payment UI is being shown to.
///
/// Set it once on ``PaystackBuilder`` with ``PaystackBuilder/setDisplayAudience(_:)``.
/// The payment flows use it to decide which UI elements to show. When it isn't set,
/// ``customerFacing`` is used.
///
/// Example Usage:
/// ```swift
/// let paystack = try PaystackBuilder.newInstance
///     .setKey("PUBLIC KEY GOES HERE")
///     .setDisplayAudience(.merchantFacing)
///     .build()
/// ```
public struct DisplayAudience: Hashable {

    let id: String

    init(id: String) {
        self.id = id
    }

    /// The customer is holding the device and paying on it. This is the default.
    public static let customerFacing = DisplayAudience(id: "customer_facing")

    /// The merchant is holding the device and showing the screen to the customer,
    /// for example on a point-of-sale or terminal app.
    public static let merchantFacing = DisplayAudience(id: "merchant_facing")
}
