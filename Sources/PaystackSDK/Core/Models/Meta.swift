import Foundation

public struct Meta: Decodable {
    public var total: Int
    public var skipped: Int
    public var perPage: IntegerObject
    public var page: Int
    public var pageCount: Int
}
