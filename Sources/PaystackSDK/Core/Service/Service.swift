import Foundation

public enum Service<T: Decodable> {
    case request(URLRequest)
    case subscription(Subscription)
    case error(Error)
}

extension Service {

    init(_ builder: URLRequestBuilder) {
        do {
            self = .request(try builder.build())
        } catch {
            self = .error(error)
        }
    }

    init(_ subscriptionBuilder: any SubscriptionBuilder) {
        do {
            self = .subscription(try subscriptionBuilder.build())
        } catch {
            self = .error(error)
        }
    }
}
