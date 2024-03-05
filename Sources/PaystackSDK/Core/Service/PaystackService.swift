import Foundation

public protocol PaystackService: URLRequestBuilderHelper {
    var config: PaystackConfig { get set }
    var parentPath: String { get }
}

public extension PaystackService {

    var endpoint: String {
        return "https://api.paystack.co/\(parentPath)"
    }

    var bearerToken: String {
        return config.apiKey
    }

    var paystackUserAgentVersion: String {
        return config.version
    }

}
