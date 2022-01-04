import Foundation

public enum Service<T: Decodable> {
    case request(URLRequest)
    case error(Error)
}

extension Service {
    
    init(_ builder: URLRequestBuilder) {
        do {
            self = .request(try builder.build())
        } catch {
            self = .error(error)
        }
    }
    
}
