import Foundation
import Paystack

/// Retrieve part of a payment from a customer.
public struct PartialDebitRequest: Encodable {
    
    /// Authorization Code
    public var authorizationCode: String
    
    /// Specify the currency you want to debit. Allowed values are NGN, GHS,
    /// ZAR or USD.
    public var currency: Currency
    
    /// Amount should be in kobo if currency is `NGN`, pesewas, if currency is `GHS`,
    /// and cents, if currency is `ZAR`
    public var amount: String
    
    /// Customer's email address (attached to the authorization code).
    public var email: String
    
    /// Unique transaction reference. Only `-`, `.`, `=` and alphanumeric characters
    /// allowed.
    public var reference: String?
    
    /// Minimum amount to charge.
    public var atLeast: String?
    
    public init(authorizationCode: String,
                currency: Currency,
                amount: String,
                email: String,
                reference: String? = nil,
                atLeast: String? = nil) {
        self.authorizationCode = authorizationCode
        self.currency = currency
        self.amount = amount
        self.email = email
        self.reference = reference
        self.atLeast = atLeast
    }
}
