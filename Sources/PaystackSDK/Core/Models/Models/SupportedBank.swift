import Foundation

public struct SupportedBank: Decodable, Equatable {
    public let id: Int
    public let code: String
    public let name: String?
    public let slug: String?

    public init(id: Int, code: String, name: String? = nil, slug: String? = nil) {
        self.id = id
        self.code = code
        self.name = name
        self.slug = slug
    }
}
