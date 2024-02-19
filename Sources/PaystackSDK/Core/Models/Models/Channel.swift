//
// Channel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

public enum Channel: String, Codable {
    case card = "card"
    case bank = "bank"
    case ussd = "ussd"
    case mobileMoney = "mobile_money"
    case qr = "qr"
    case bankTransfer = "bank_transfer"
    case unsupportedChannel

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)
        self = Channel(rawValue: rawString) ?? .unsupportedChannel
    }
}
