import Foundation
import PusherSwift
import PaystackPusherWrapper
struct PusherSubscriptionListener: SubscriptionListener {

    let pusher: Pusher

    init() {
        let options = PusherClientOptions(
          host: .cluster("eu")
        )
        self.pusher = Pusher(withAppKey: PaystackPusherConfig.apiKey, options: options)
    }

    static private var apiKey: String {
        guard let secretsUrl = Bundle.current.url(forResource: "secrets",
                                                  withExtension: "plist"),
              let data = try? Data(contentsOf: secretsUrl),
              let plist = try? PropertyListSerialization.propertyList(
                from: data, format: nil) as? [String: String],
                let apiKey = plist["PUSHER_API_KEY"] else {
            Logger.error("API key not provided to pusher instance")
            return ""
        }
        return apiKey
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
        Logger.info("Pusher subscription initiated to %@", arguments: channel.name)
        channel.bind(eventName: "pusher:subscription_succeeded", eventCallback: { _ in
            Logger.info("Pusher subscription succeeded to %@", arguments: channel.name)
        })
        channel.bind(eventName: "pusher:subscription_error", eventCallback: { _ in
            Logger.error("Pusher subscription failed to %@", arguments: channel.name)
        })
    }

    private func listenForData(
        on channel: PusherChannel, forEvent eventName: String,
        subscriptionResponse: @escaping (Result<String, SubscriptionError>) -> Void
    ) {

        channel.bind(eventName: eventName, eventCallback: {
            guard let stringData = $0.data else {
                subscriptionResponse(.failure(.noData))
                pusher.unsubscribe($0.channelName ?? "")
                pusher.disconnect()
                return
            }
            subscriptionResponse(.success(stringData))
            pusher.unsubscribe($0.channelName ?? "")
            pusher.disconnect()
        })

    }

}
