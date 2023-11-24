import Foundation

// MARK: - MobileMoneyChargeResponse
public struct MobileMoneyChargeResponse: Codable {
    let status: Bool
    let message: String
    let data: MobileMoneyChargeData
}

// MARK: - MobileMoneyChargeData
public struct MobileMoneyChargeData: Codable {
    let transaction: String
    let phone: String
    let provider: String
    let channelName: String
    let display: Display

    enum CodingKeys: String, CodingKey {
        case transaction
        case phone
        case provider
        case channelName
        case display
    }
}

// MARK: - Display
public struct Display: Codable {
    let type: String
    let message: String
    let timer: Int
}
