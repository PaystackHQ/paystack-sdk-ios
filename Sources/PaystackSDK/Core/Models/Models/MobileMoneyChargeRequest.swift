import Foundation

// MARK: - MobileMoneyChargeRequest
public struct MobileMoneyChargeRequest: Codable {
    let channelName: String
    let phone: String
    let transaction: String
    let provider: String
}
