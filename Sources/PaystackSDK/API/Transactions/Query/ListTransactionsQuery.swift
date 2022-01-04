import Foundation
import Paystack

/// Query params for the list of transactions service call.
public enum ListTransactionQuery {

    /// Specify how many records you want to retrieve per page. If not specify
    /// we use a default value of 50.
    case perPage(Int)
    
    /// Specify exactly what page you want to retrieve. If not specify we use a
    /// default value of 1.
    case page(Int)
    
    /// Specify an ID for the customer whose transactions you want to retrieve.
    case customer(Int)
    
    /// Filter transactions by status ('failed', 'success', 'abandoned').
    case status(TransactionStatus)
    
    /// A timestamp from which to start listing transaction e.g.
    /// `2016-09-24T00:00:05.000Z, 2016-09-21`
    case from(Date)
    
    /// A timestamp at which to stop listing transaction e.g.
    /// `2016-09-24T00:00:05.000Z, 2016-09-21`
    case to(Date)
    
    /// Filter transactions by amount. Specify the amount (in kobo if currency is `NGN`,
    /// pesewas, if currency is `GHS`, and cents, if currency is `ZAR`)
    case amount(Int)
}

extension ListTransactionQuery: Queryable {
    
    public var keyPair: (String, String) {
        switch self {
        case .perPage(let perPage):
            return ("perPage", "\(perPage)")
        case .page(let page):
            return ("page", "\(page)")
        case .customer(let customer):
            return ("customer", "\(customer)")
        case .status(let status):
            return ("status", status.rawValue)
        case .from(let from):
            return ("from", from.paystackFormat)
        case .to(let to):
            return ("to", to.paystackFormat)
        case .amount(let amount):
            return ("amount", "\(amount)")
        }
    }
    
}
