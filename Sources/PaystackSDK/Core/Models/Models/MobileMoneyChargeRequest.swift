import Foundation

// MARK: - MobileMoneyChargeRequest
struct MobileMoneyChargeRequest: Codable {
    let channelName: String
    let amount: Int
    let email: String
    let phone: String
    let transaction: String
    let provider: String
}
