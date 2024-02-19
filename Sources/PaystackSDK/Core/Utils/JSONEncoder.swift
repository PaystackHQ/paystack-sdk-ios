import Foundation

extension JSONEncoder {

    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(.paystackFormatter)
        return encoder
    }

}
