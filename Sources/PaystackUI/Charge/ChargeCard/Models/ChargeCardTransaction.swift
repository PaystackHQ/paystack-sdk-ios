import Foundation
import PaystackCore

// TODO: Add further fields here once we know what is required
struct ChargeCardTransaction {
    var status: TransactionStatus
    var redirectUrl: String?
    var customerPhone: String?
    var countryCode: String?
}

extension ChargeCardTransaction {

    static func from(_ response: ChargeResponse) -> Self {
        ChargeCardTransaction(status: response.data.status,
                              redirectUrl: response.data.redirectUrl,
                              customerPhone: response.data.customer?.phone,
                              countryCode: response.data.authorization?.countryCode)
    }

}

// MARK: - Previews
extension ChargeCardTransaction {
    static var example: Self {
        .init(status: .success)
    }
}
