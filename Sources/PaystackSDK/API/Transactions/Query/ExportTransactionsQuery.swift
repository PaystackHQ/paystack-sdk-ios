import Foundation
import Paystack

/// Query params for the export transactions service call.
public enum ExportTransactionsQuery {
    
    /// Specify how many records you want to retrieve per page. If not specify
    /// we use a default value of 50.
    case perPage(Int)
    
    /// Specify exactly what page you want to retrieve. If not specify we use a
    /// default value of 1.
    case page(Int)
    
    /// A timestamp from which to start listing transaction e.g.
    /// `2016-09-24T00:00:05.000Z`, `2016-09-21`
    case from(Date)
    
    /// A timestamp at which to stop listing transaction e.g.
    /// `2016-09-24T00:00:05.000Z`, `2016-09-21`
    case to(Date)
    
    /// Specify an ID for the customer whose transactions you want to retrieve.
    case customer(Int)
    
    /// Filter transactions by status ('failed', 'success', 'abandoned')
    case status(TransactionStatus)
    
    /// Specify the transaction currency to export. Allowed values are: in kobo
    /// if currency is `NGN`, pesewas, if currency is `GHS`, and cents, if
    /// currency is `ZAR`
    case currency(Currency)
    
    /// Filter transactions by amount. Specify the amount, in kobo if currency is
    /// `NGN`, pesewas, if currency is `GHS`, and cents, if currency is `ZAR`.
    case amount(Int)
    
    /// Set to `true` to export only settled transactions. `false` for pending
    /// transactions. Leave undefined to export all transactions.
    case settled(Bool)
    
    /// An ID for the settlement whose transactions we should export.
    case settlement(Int)
    
    /// Specify a payment page's id to export only transactions conducted on
    /// said page.
    case paymentPage(Int)
}

extension ExportTransactionsQuery: Queryable {
    
    public var keyPair: (String, String) {
        switch self {
        case .perPage(let perPage):
            return ("perPage", "\(perPage)")
        case .page(let page):
            return ("page", "\(page)")
        case .from(let from):
            return ("from", from.paystackFormat)
        case .to(let to):
            return ("to", to.paystackFormat)
        case .customer(let customer):
            return ("customer", "\(customer)")
        case .status(let status):
            return ("status", status.rawValue)
        case .currency(let currency):
            return ("currency", currency.rawValue)
        case .amount(let amount):
            return ("amount", "\(amount)")
        case .settled(let settled):
            return ("settled", "\(settled)")
        case .settlement(let settlement):
            return ("settlement", "\(settlement)")
        case .paymentPage(let paymentPage):
            return ("payment_page", "\(paymentPage)")
        }
    }
    
}
