import Foundation

public struct QRPusherResponse: Decodable, Equatable {
    public var status: Bool
    public var message: String?
    public var response: String?
    public var reference: String?
    public var transactionReference: String?
    public var transaction: String?
    public var redirectUrl: String?
    public var page: QRPusherPage?

    enum CodingKeys: String, CodingKey {
        case status, message, response, reference, page
        case transaction = "trans"
        case transactionReference = "trxref"
        case redirectUrl = "redirecturl"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(Bool.self, forKey: .status)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        response = try container.decodeIfPresent(String.self, forKey: .response)
        reference = try container.decodeIfPresent(String.self, forKey: .reference)
        transactionReference = try container.decodeIfPresent(
            String.self, forKey: .transactionReference)
        transaction = Self.decodeFlexibleString(from: container, forKey: .transaction)
        redirectUrl = try container.decodeIfPresent(String.self, forKey: .redirectUrl)
        page = try container.decodeIfPresent(QRPusherPage.self, forKey: .page)
    }

    public init(status: Bool,
                message: String? = nil,
                response: String? = nil,
                reference: String? = nil,
                transactionReference: String? = nil,
                transaction: String? = nil,
                redirectUrl: String? = nil,
                page: QRPusherPage? = nil) {
        self.status = status
        self.message = message
        self.response = response
        self.reference = reference
        self.transactionReference = transactionReference
        self.transaction = transaction
        self.redirectUrl = redirectUrl
        self.page = page
    }

    private static func decodeFlexibleString(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys) -> String? {
        if let value = try? container.decodeIfPresent(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeIfPresent(Int64.self, forKey: key) {
            return String(value)
        }
        return nil
    }
}

public struct QRPusherPage: Decodable, Equatable {
    public var redirectUrl: String?
    public var successMessage: String?

    public init(redirectUrl: String? = nil, successMessage: String? = nil) {
        self.redirectUrl = redirectUrl
        self.successMessage = successMessage
    }
}
