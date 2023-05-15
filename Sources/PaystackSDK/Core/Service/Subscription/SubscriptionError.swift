import Foundation

public enum SubscriptionError: Error {
    case invalidSubscription
    case noData
    case other(String)
}
