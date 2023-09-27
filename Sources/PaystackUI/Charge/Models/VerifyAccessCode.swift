import Foundation
import PaystackCore

struct VerifyAccessCode: Equatable {
    var amount: Decimal
    var currency: String
    var accessCode: String
    var paymentChannels: [Channel]
    var domain: Domain
    var merchantName: String
    var publicEncryptionKey: String
    var reference: String
    var transactionId: Int?

    var amountCurrency: AmountCurrency {
        AmountCurrency(amount: amount, currency: currency)
    }
}

extension VerifyAccessCode {

    static func from(_ response: VerifyAccessCodeResponse) -> Self {
        VerifyAccessCode(amount: response.data.amount,
                         currency: response.data.currency,
                         accessCode: response.data.accessCode,
                         paymentChannels: response.data.channels.filter { $0 != .unsupportedChannel },
                         domain: response.data.domain,
                         merchantName: response.data.merchantName,
                         publicEncryptionKey: response.data.publicEncryptionKey,
                         reference: response.data.reference,
                         transactionId: response.data.id)
    }

}

// MARK: - Previews
extension VerifyAccessCode {
    static var example: Self {
        .init(amount: 10000,
              currency: "USD",
              accessCode: "test_access",
              paymentChannels: [.card],
              domain: .test,
              merchantName: "Test Merchant",
              publicEncryptionKey: "test_encryption_key",
              reference: "test_reference")
    }
}
