import Foundation

public class Paystack {
    
    public let config: PaystackConfig
    let subscriptionBuilder: PusherSubscriptionBuilder
    
    init(config: PaystackConfig, subscriptionBuilder: PusherSubscriptionBuilder) {
        self.config = config
        self.subscriptionBuilder = subscriptionBuilder
    }
    
}
