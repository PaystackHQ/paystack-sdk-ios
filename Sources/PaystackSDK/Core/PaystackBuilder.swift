import Foundation

public class PaystackBuilder {

    private var apiKey: String?
    private var loggingEnabled = false
    private var displayAudience: DisplayAudience = .customerFacing

    public func setKey(_ apiKey: String) -> Self {
        self.apiKey = apiKey
        return self
    }

    public func enableLogging() -> Self {
        self.loggingEnabled = true
        return self
    }

    /// Sets who the payment UI is shown to. Defaults to ``DisplayAudience/customerFacing`` when not called.
    /// - Parameter audience: The ``DisplayAudience`` the payment flows should be tailored for
    /// - Returns: The builder, so calls can be chained
    public func setDisplayAudience(_ audience: DisplayAudience) -> Self {
        self.displayAudience = audience
        return self
    }

    public func build() throws -> Paystack {
        guard let apiKey = apiKey else {
            throw PaystackError.noAPIKey
        }

        Logger.loggingEnabled = loggingEnabled

        let config = PaystackConfig(apiKey: apiKey, displayAudience: displayAudience)
        return Paystack(config: config)
    }
}

public extension PaystackBuilder {

    static var newInstance: PaystackBuilder {
        return PaystackBuilder()
    }

}
