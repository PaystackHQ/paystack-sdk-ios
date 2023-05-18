import Foundation

public protocol Subscription {
    associatedtype SubscriptionDetails

    var subscriptionDetails: SubscriptionDetails { get }
}
