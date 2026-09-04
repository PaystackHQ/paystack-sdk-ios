import Foundation
import PaystackCore

// TODO: Add further fields here once we know what is required
struct ChargeCapitecTransaction: Equatable {
    var status: String
}

extension ChargeCapitecTransaction {

    static func from(_ response: CapitecResponse) -> Self {
        ChargeCapitecTransaction(status: response.data.status)
    }

}
