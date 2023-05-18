import Foundation

public enum Service<T: Decodable> {
    case request(URLRequest)
    case subscription(any Subscription)
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

    init(_ subscription: any Subscription) {
        self = .subscription(subscription)
    }
}
