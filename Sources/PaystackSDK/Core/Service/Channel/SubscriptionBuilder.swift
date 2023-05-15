import Foundation
import PusherSwift

protocol SubscriptionBuilder {
    associatedtype SubscriptionDetails

    func provideSubscriptionDetails(_ details: SubscriptionDetails) -> Self
    func build() throws -> Subscription
}

class PusherSubscriptionBuilder: SubscriptionBuilder {
    typealias SubscriptionDetails = (channelName: String, eventName: String)

    let pusher: Pusher
    var channelName: String?
    var eventName: String?

    init() {
        // TODO: Retrieve from plist or elsewhere
        let myTestKey = "c559a9d0aeb0136973a9"
        let options = PusherClientOptions(
          host: .cluster("eu")
        )
        self.pusher = Pusher(withAppKey: myTestKey, options: options)
    }

    func provideSubscriptionDetails(_ details: SubscriptionDetails) -> Self {
        channelName = details.channelName
        eventName = details.eventName
        return self
    }

    func build() throws -> Subscription {
        guard let channelName = channelName, let eventName = eventName else {
            throw SubscriptionError.subscriptionDetailsNotProvided
        }
        let channel = pusher.subscribe(channelName: channelName)
        bindConnectionEvents(to: channel)
        pusher.connect()
        return PusherSubscription(channel: channel, event: eventName)
    }

    private func bindConnectionEvents(to channel: PusherChannel) {
        channel.bind(eventName: "pusher:subscription_succeeded", eventCallback: { event in
            // TODO: Add proper logging
            print(event.eventName)
        })
        channel.bind(eventName: "pusher:subscription_error", eventCallback: { event in
            // TODO: Add proper logging
            print(event.eventName)
        })
    }
}
