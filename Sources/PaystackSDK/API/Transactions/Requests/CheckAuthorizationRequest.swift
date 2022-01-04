import Foundation
import Paystack

/// All Mastercard and Visa authorizations can be checked with this endpoint to know if they have
/// funds for the payment you seek.
public struct CheckAuthorizationRequest: Encodable {
    
    /// Amount should be in kobo if currency is `NGN`, pesewas, if currency is `GHS`, and cents,
    /// if currency is `ZAR`
    public var amount: Int
    
    /// Customer's email address.
    public var email: String
    
    /// Valid authorization code to charge.
    public var authorizationCode: String
    
    /// Currency in which amount should be charged. Allowed values are: NGN, GHS, ZAR or USD
    public var currency: Currency?
    
    public init(amount: Int,
                email: String,
                authorizationCode: String,
                currency: Currency? = nil) {
        self.amount = amount
        self.email = email
        self.authorizationCode = authorizationCode
        self.currency = currency
    }
}
