import Foundation

public protocol URLRequestBuilderHelper {
    var endpoint: String { get }
    var bearerToken: String { get }
    var paystackUserAgentVersion: String { get }

    func get() -> URLRequestBuilder
    func get(_ path: String) -> URLRequestBuilder
    func post<T: Encodable>(_ path: String, _ body: T) -> URLRequestBuilder
    func put<T: Encodable>(_ path: String, _ body: T) -> URLRequestBuilder
}

public extension URLRequestBuilderHelper {

    func get() -> URLRequestBuilder {
        return builder
            .setMethod(.get)
    }

    func get(_ path: String) -> URLRequestBuilder {
        return get()
            .setPath(path)
    }

    func post<T: Encodable>(_ path: String, _ body: T) -> URLRequestBuilder {
        return builder
            .setMethod(.post)
            .setPath(path)
            .setBody(body)
    }

    func put<T: Encodable>(_ path: String, _ body: T) -> URLRequestBuilder {
        return builder
            .setMethod(.put)
            .setPath(path)
            .setBody(body)
    }

    private var builder: URLRequestBuilder {
        return URLRequestBuilder(endpoint: endpoint)
            .addBearerAuthorization(bearerToken)
            .addPaystackUserAgent(paystackUserAgentVersion)
            .addDeviceIdentifier()
            .addLoggingHeaders()
    }

}
