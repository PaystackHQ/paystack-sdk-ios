import Foundation
import PaystackCore

// TODO: Add further fields here once we know what is required
struct ChargeCardTransaction: Equatable {
    var status: TransactionStatus
    var url: String?
    var displayText: String?
    var message: String?
    var countryCode: String?
}

extension ChargeCardTransaction {

    static func from(_ response: ChargeResponse) -> Self {
        ChargeCardTransaction(status: response.data.status,
                              url: response.data.url,
                              displayText: response.data.displayText,
                              message: response.data.message,
                              countryCode: response.data.authorization?.countryCode)
    }

    static func from(_ response: Charge3DSResponse) -> Self {
        let status: TransactionStatus = response.status == .success ? .success : .failed
        return ChargeCardTransaction(status: status)
    }

}

// MARK: - Previews
extension ChargeCardTransaction {
    static var example: Self {
        .init(status: .success)
    }
}
