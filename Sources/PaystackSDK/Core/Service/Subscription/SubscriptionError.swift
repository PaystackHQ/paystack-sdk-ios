import Foundation

public enum SubscriptionError: Error, Equatable {
    case invalidSubscription
    case noData
    case other(String)
}
