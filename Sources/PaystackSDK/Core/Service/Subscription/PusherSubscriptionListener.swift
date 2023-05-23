import Foundation
import PusherSwift

struct PusherSubscriptionListener: SubscriptionListener {

    let pusher: Pusher

    init() {
        // TODO: Store and retrieve from PLIST
        let myTestKey = "MY_TEST_KEY"
        let options = PusherClientOptions(
          host: .cluster("eu")
        )
        self.pusher = Pusher(withAppKey: myTestKey, options: options)
    }

    func listen(to subscription: any Subscription,
                completion: @escaping (Result<String, SubscriptionError>) -> Void) {
        guard let subscription = subscription as? PusherSubscription else {
            completion(.failure(.invalidSubscription))
            return
        }
        let (channelName, eventName) = subscription.subscriptionDetails
        let channel = pusher.subscribe(channelName: channelName)
        bindConnectionEvents(to: channel)
        pusher.connect()

        listenForData(on: channel, forEvent: eventName, subscriptionResponse: completion)
    }

    private func bindConnectionEvents(to channel: PusherChannel) {
        Log.info("Pusher subscription initiated to %@", arguments: channel.name)
        channel.bind(eventName: "pusher:subscription_succeeded", eventCallback: { _ in
            Log.info("Pusher subscription succeeded to %@", arguments: channel.name)
        })
        channel.bind(eventName: "pusher:subscription_error", eventCallback: { _ in
            Log.error("Pusher subscription failed to %@", arguments: channel.name)
        })
    }

    private func listenForData(
        on channel: PusherChannel, forEvent eventName: String,
        subscriptionResponse: @escaping (Result<String, SubscriptionError>) -> Void
    ) {

        channel.bind(eventName: eventName, eventCallback: {
            guard let stringData = $0.data else {
                subscriptionResponse(.failure(.noData))
                return
            }
            subscriptionResponse(.success(stringData))
        })

    }

}
