import Foundation

public protocol PaystackService: URLRequestBuilderHelper {
    var config: PaystackConfig { get set }
    var parentPath: String { get }
    var baseURL: String { get }
}

public extension PaystackService {

    var baseURL: String {
        return "https://api.paystack.co"
    }

    var endpoint: String {
         return "\(baseURL)/\(parentPath)"
    }

    var bearerToken: String {
        return config.apiKey
    }

    var paystackUserAgentVersion: String {
        return config.version
    }

}
