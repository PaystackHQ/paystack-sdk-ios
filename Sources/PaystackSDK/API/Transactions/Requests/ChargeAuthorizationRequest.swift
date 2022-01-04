import Foundation
import Paystack

/// All authorizations marked as reusable can be charged with this endpoint whenever you need to
/// receive payments.
public struct ChargeAuthorizationRequest: Encodable {
    
    /// Amount should be in kobo if currency is `NGN`, pesewas, if currency is `GHS`, and cents,
    /// if currency is `ZAR`
    public var amount: Int
    
    /// Customer's email address.
    public var email: String
    
    /// Valid authorization code to charge.
    public var authorizationCode: String
    
    /// Unique transaction reference. Only `-`, `.`, `=` and alphanumeric characters allowed.
    public var reference: String?
    
    /// Currency in which amount should be charged. Allowed values are: NGN, GHS, ZAR or USD
    public var currency: Currency?
    
    /// Stringified JSON object. Add a `custom_fields` attribute which has an array of objects
    /// if you would like the fields to be added to your transaction when displayed on the dashboard.
    /// Sample: `{"custom_fields":[{"display_name":"Cart ID",
    /// `"variable_name": "cart_id","value": "8393"}]}`
    public var metadata: Metadata?
    
    /// Send us 'card' or 'bank' or 'card','bank' as an array to specify what options to show the user
    /// paying.
    public var channels: [Channel]?
    
    /// The code for the subaccount that owns the payment. e.g. `ACCT_8f4s1eq7ml6rlzj`
    public var subaccount: String?
    
    /// A flat fee to charge the subaccount for this transaction (in kobo if currency is `NGN`, pesewas,
    /// if currency is `GHS`, and cents, if currency is `ZAR`). This overrides the split percentage set
    /// when the subaccount was created. Ideally, you will need to use this if you are splitting in flat rates
    /// (since subaccount creation only allows for percentage split). e.g. `7000` for a 70 naira flat fee.
    public var transactionCharge: Int?
    
    /// Who bears Paystack charges? `account` or `subaccount` (defaults to `account`).
    public var bearer: Bearer?
    
    /// If you are making a scheduled charge call, it is a good idea to queue them so the processing
    /// system does not get overloaded causing transaction processing errors. Send `queue:true`
    /// to take advantage of our queued charging.
    public var queue: Bool?
    
    public init(amount: Int,
                email: String,
                authorizationCode: String,
                reference: String? = nil,
                currency: Currency? = nil,
                metadata: Metadata? = nil,
                channels: [Channel]? = nil,
                subaccount: String? = nil,
                transactionCharge: Int? = nil,
                bearer: Bearer? = nil,
                queue: Bool? = nil) {
        self.amount = amount
        self.email = email
        self.authorizationCode = authorizationCode
        self.reference = reference
        self.currency = currency
        self.metadata = metadata
        self.channels = channels
        self.subaccount = subaccount
        self.transactionCharge = transactionCharge
        self.bearer = bearer
        self.queue = queue
    }
}
