import Foundation
import UIKit

struct PaystackUserAgent: Encodable {
    var lang: String = "swift"
    var bindingsVersion: String
}

extension URLRequestBuilder {
    
    func addPaystackUserAgent(_ version: String) -> Self {
        let agent = PaystackUserAgent(bindingsVersion: version)
        guard let data = try? JSONEncoder.encoder.encode(agent),
              let agentString = String(data: data, encoding: .utf8) else {
            return self
        }
        
        return addHeader("X-Paystack-User-Agent", agentString)
    }
    
    func addDeviceIdentifier() -> Self {
        addHeader("x-device-identifier", "sdk_ios_" + (UIDevice.current.identifierForVendor?.uuidString ?? ""))
    }
    
}
