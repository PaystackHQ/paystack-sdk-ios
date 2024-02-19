import Foundation

// MARK: - MobileMoneyChargeResponse
public struct MobileMoneyChargeResponse: Codable {
    public let status: Bool
    public let message: String
    public let data: MobileMoneyChargeData
}

// MARK: - MobileMoneyChargeData
public struct MobileMoneyChargeData: Codable {
    public let transaction: String
    public let phone: String
    public let provider: String
    public let channelName: String
    public let display: Display

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
    public let type: String
    public let message: String
    public let timer: Int
}
