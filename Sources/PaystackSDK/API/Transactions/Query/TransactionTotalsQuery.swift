import Foundation
import Paystack

/// Query params for transaction totals service call
public enum TransactionTotalsQuery {
    
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
}

extension TransactionTotalsQuery: Queryable {
    
    public var keyPair: (String, String) {
        switch self {
        case .perPage(let perPage):
            return ("perPage", "\(perPage)")
        case .page(let page):
            return ("page", "\(page)")
        case .from(let from):
            return ("from", "\(from.paystackFormat)")
        case .to(let to):
            return ("to", "\(to.paystackFormat)")
        }
    }
    
}
