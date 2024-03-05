import Foundation

public class URLRequestBuilder {

    var endpoint: String
    var path: String?
    var headers: [String: String] = [:]
    var queryItems: [String: String?] = [:]
    var method: String?
    var body: Data?

    public init(endpoint: String) {
        self.endpoint = endpoint
    }

    public func setPath(_ path: String) -> Self {
        self.path = path
        return self
    }

    public func addHeader(_ name: String, _ value: String) -> Self {
        self.headers[name] = value
        return self
    }

    public func setHeaders(_ headers: [String: String]) -> Self {
        self.headers = headers
        return self
    }

    public func addQueryItem(_ name: String, _ value: String?) -> Self {
        self.queryItems[name] = value
        return self
    }

    public func setQueryItems(_ queryItems: [String: String?]) -> Self {
        self.queryItems = queryItems
        return self
    }

    public func setQueryItems(_ queryItems: [(String, String)]) -> Self {
        self.queryItems = queryItems.reduce(into: [:]) { $0[$1.0] = $1.1 }
        return self
    }

    public func setMethod(_ method: HTTPMethod) -> Self {
        self.method = method.rawValue.uppercased()
        return self
    }

    public func setBody<T: Encodable>(_ body: T) -> Self {
        self.body = try? JSONEncoder.encoder.encode(body)
        return addHeader("Content-Type", "application/json")
    }

    public func setBody(_ body: Data) -> Self {
        self.body = body
        return self
    }

    public func build() throws -> URLRequest {
        guard let method = method else {
            throw URLRequestBuilderError.invalidMethod
        }

        let url = try buildURL()
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method
        request.httpBody = body
        return request
    }

    private func buildURL() throws -> URL {
        var components = URLComponents(string: endpoint)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems.compactMap(buildQueryItem)
        }

        guard let url = components?.url else {
            throw URLRequestBuilderError.invalidUrl
        }

        if let path = path {
            return url.appendingPathComponent(path)
        }

        return url
    }

    private func buildQueryItem(_ name: String, value: String?) -> URLQueryItem? {
        guard let value = value else {
            return nil
        }

        return URLQueryItem(name: name, value: value)
    }
}

public extension URLRequestBuilder {

    func addBearerAuthorization(_ authorization: String) -> Self {
        return addHeader("Authorization", "Bearer \(authorization)")
    }

    func addQueryItem<T: CustomStringConvertible>(_ name: String, _ value: T?) -> Self {
        return addQueryItem(name, value.flatMap(String.init))
    }

}

public extension URLRequestBuilder {

    func asService<T: Decodable>() -> Service<T> {
        return Service(self)
    }

}
