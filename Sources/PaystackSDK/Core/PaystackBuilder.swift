import Foundation

public class PaystackBuilder {

    var apiKey: String?
    var loggingEnabled = false

    public func setKey(_ apiKey: String) -> Self {
        self.apiKey = apiKey
        return self
    }

    public func enableLogging() -> Self {
        self.loggingEnabled = true
        return self
    }

    public func build() throws -> Paystack {
        guard let apiKey = apiKey else {
            throw PaystackError.noAPIKey
        }

        Log.loggingEnabled = loggingEnabled

        let config = PaystackConfig(apiKey: apiKey)
        return Paystack(config: config)
    }
}

public extension PaystackBuilder {

    static var newInstance: PaystackBuilder {
        return PaystackBuilder()
    }

}
