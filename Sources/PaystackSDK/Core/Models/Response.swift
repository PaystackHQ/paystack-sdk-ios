import Foundation

public typealias ServiceResponse<T: Decodable> = Service<Response<T>>

public struct Response<T: Decodable>: Decodable {
    public var status: Bool
    public var message: String
    public var data: T
    public var meta: Meta?
}
