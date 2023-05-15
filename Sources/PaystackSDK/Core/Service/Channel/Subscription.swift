import Foundation
import PusherSwift

public protocol Subscription {
    /// Listens to an event that has been registered and returns a `String` representation of data if successful
    func startListeningForEvent(_ subscriptionResponse: @escaping (Result<String, SubscriptionError>) -> Void)
}

struct PusherSubscription: Subscription {
    let channel: PusherChannel
    let event: String

    init(channel: PusherChannel, event: String) {
        self.channel = channel
        self.event = event
    }

    func startListeningForEvent(_ subscriptionResponse: @escaping (Result<String, SubscriptionError>) -> Void) {
        channel.bind(eventName: event, eventCallback: {
            guard let stringData = $0.data else {
                subscriptionResponse(.failure(.noData))
                return
            }
            subscriptionResponse(.success(stringData))
        })

    }
}
