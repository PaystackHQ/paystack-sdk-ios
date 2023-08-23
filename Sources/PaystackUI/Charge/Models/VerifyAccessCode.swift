import Foundation
import PaystackCore

struct VerifyAccessCode: Equatable {
    var amount: Decimal
    var currency: String
    var accessCode: String
    // TODO: Use enum once we see example responses
    var paymentChannels: [String]
    var domain: Domain

    var amountCurrency: AmountCurrency {
        AmountCurrency(amount: amount, currency: currency)
    }
}

extension VerifyAccessCode {

    static func from(_ response: VerifyAccessCodeResponse) -> Self {
        VerifyAccessCode(amount: response.data.amount,
                         currency: response.data.currency,
                         accessCode: response.data.accessCode,
                         paymentChannels: response.data.channels,
                         domain: response.data.domain)
    }

}

// MARK: - Previews
extension VerifyAccessCode {
    static var example: Self {
        .init(amount: 10000,
              currency: "USD",
              accessCode: "test_access",
              paymentChannels: [],
              domain: .test)
    }
}
