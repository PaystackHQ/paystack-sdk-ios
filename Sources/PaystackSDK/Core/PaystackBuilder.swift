import Foundation

public class PaystackBuilder {
    
    var apiKey: String?
    
    public func setKey(_ apiKey: String) -> Self {
        self.apiKey = apiKey
        return self
    }
    
    public func build() throws -> Paystack {
        guard let apiKey = apiKey else {
            throw PaystackError.noAPIKey
        }

        let subscriptionBuilder = PusherSubscriptionBuilder()
        let config = PaystackConfig(apiKey: apiKey)
        return Paystack(config: config, subscriptionBuilder: subscriptionBuilder)
    }
}

public extension PaystackBuilder {
    
    static var newInstance: PaystackBuilder {
        return PaystackBuilder()
    }
    
}
