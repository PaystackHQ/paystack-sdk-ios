import Foundation

/// The result of a payment attempt
public enum TransactionResult {

    /** The customer's payment process is complete.

    Your server should verify the transaction status and amount before providing value.
    A transaction can be confirmed by using either webhooks or the verify transactions endpoint.
    See [Paystack's docs](https://paystack.com/docs/payments/verify-payments/) */
    case completed

    /// The customer canceled the payment attempt.
    case cancelled

    // TODO: Pass a custom error type here later and provide a better description
    /// An unexpected error occurred whilst attempting payment.
    case error(Error)
}
