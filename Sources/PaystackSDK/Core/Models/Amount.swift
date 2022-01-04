import Foundation

public struct Amount: Decodable {
    public var amount: IntegerObject
    public var currency: Currency
}
