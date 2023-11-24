import Foundation

// MARK: - MobileMoneyChargeResponse
public struct MobileMoneyChargeResponse: Codable {
    let status: Bool
    let message: String
    let data: MobileMoneyChargeData
}

// MARK: - MobileMoneyChargeData
public struct MobileMoneyChargeData: Codable {
    let transaction, phone, provider, channelName: String
    let display: Display

    enum CodingKeys: String, CodingKey {
        case transaction, phone, provider
        case channelName = "channel_name"
        case display
    }
}

// MARK: - Display
public struct Display: Codable {
    let type, message: String
    let timer: Int
}
