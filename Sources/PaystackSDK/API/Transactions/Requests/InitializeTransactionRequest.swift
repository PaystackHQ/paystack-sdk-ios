import Foundation
import Paystack

/// Initialize a transaction from your app
public struct InitializeTransactionRequest: Encodable {
    
    /// Amount should be in kobo if currency is `NGN`, pesewas, if currency is `GHS`, and cents,
    /// if currency is `ZAR`
    public var amount: Int
    
    /// Customer's email address
    public var email: String
    
    /// The transaction currency (NGN, GHS, ZAR or USD). Defaults to your integration currency.
    public var currency: Currency?
    
    /// Unique transaction reference. Only `-`, `.`, `=` and alphanumeric characters allowed.
    public var reference: String?
    
    /// Fully qualified url, e.g. https://example.com/ . Use this to override the callback url
    /// provided on the dashboard for this transaction.
    public var callbackURL: String?
    
    /// If transaction is to create a subscription to a predefined plan, provide plan code here. This
    /// would invalidate the value provided in `amount`.
    public var plan: String?
    
    /// Number of times to charge customer during subscription to plan.
    public var invoiceLimit: Int?
    
    /// Stringified JSON object of custom data. Kindly check the
    /// Metadata (https://paystack.com/docs/payments/metadata) page for more
    /// information.
    public var metadata: Metadata?
    
    /// An array of payment channels to control what channels you want to make available to the
    /// user to make a payment with. Available channels include:
    /// `['card', 'bank', 'ussd', 'qr', 'mobile_money', 'bank_transfer']`
    public var channels: Channel?
    
    /// The split code of the transaction split. e.g. `SPL_98WF13Eb3w`.
    public var splitCode: String?
    
    /// The code for the subaccount that owns the payment. e.g. `ACCT_8f4s1eq7ml6rlzj`.
    public var subaccount: String?
    
    /// A flat fee to charge the subaccount for this transaction (). This overrides the split percentage
    /// set when the subaccount was created. Ideally, you will need to use this if you are splitting in
    /// flat rates (since subaccount creation only allows for percentage split). e.g. `7000` for a 70
    /// naira flat fee.
    public var transactionCharge: Int?
    
    /// Who bears Paystack charges? `account` or `subaccount` (defaults to `account`).
    public var bearer: Bearer?
    
    public init(amount: Int,
                email: String,
                currency: Currency? = nil,
                reference: String? = nil,
                callbackURL: String? = nil,
                plan: String? = nil,
                invoiceLimit: Int? = nil,
                metadata: Metadata? = nil,
                channels: Channel? = nil,
                splitCode: String? = nil,
                subaccount: String? = nil,
                transactionCharge: Int? = nil,
                bearer: Bearer? = nil) {
        self.amount = amount
        self.email = email
        self.currency = currency
        self.reference = reference
        self.callbackURL = callbackURL
        self.plan = plan
        self.invoiceLimit = invoiceLimit
        self.metadata = metadata
        self.channels = channels
        self.splitCode = splitCode
        self.subaccount = subaccount
        self.transactionCharge = transactionCharge
        self.bearer = bearer
    }
}
