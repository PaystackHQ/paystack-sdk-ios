import Foundation

struct PusherSubscription: Subscription {

    typealias SubscriptionDetails = (channelName: String, eventName: String)

    let channelName: String
    let eventName: String

    var subscriptionDetails: (channelName: String, eventName: String) {
        (channelName, eventName)
    }

    init(channelName: String, eventName: String) {
        self.channelName = channelName
        self.eventName = eventName
    }
}
