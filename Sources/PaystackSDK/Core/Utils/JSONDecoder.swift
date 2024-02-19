import Foundation

extension JSONDecoder {

    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(.paystackFormatter)
        return decoder
    }

}
