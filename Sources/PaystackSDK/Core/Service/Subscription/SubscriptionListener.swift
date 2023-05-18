import Foundation

protocol SubscriptionListener {
    func listen(to subscription: any Subscription,
                completion: @escaping (Result<String, SubscriptionError>) -> Void)
}
