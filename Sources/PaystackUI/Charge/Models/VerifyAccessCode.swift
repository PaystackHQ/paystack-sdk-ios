import PaystackCore

struct VerifyAccessCode: Equatable {
    var amount: Double
    var currency: String
    // TODO: Use enum once we see example responses
    var paymentChannels: [String]
}

extension VerifyAccessCode {

    static func from(_ response: VerifyAccessCodeResponse) -> Self {
        VerifyAccessCode(amount: response.data.amount,
                         currency: response.data.currency,
                         paymentChannels: response.data.channels)
    }

}
