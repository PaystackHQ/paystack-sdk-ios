import Foundation

class SubscriptionListenerProvider {

    static var listener: SubscriptionListener = PusherSubscriptionListener()

    static func listen(to subscription: any Subscription,
                       completion: @escaping (Result<String, SubscriptionError>) -> Void) {
        listener.listen(to: subscription, completion: completion)
    }

    static func set(listener: SubscriptionListener) {
        self.listener = listener
    }

    static func reset() {
        self.listener = PusherSubscriptionListener()
    }

}
