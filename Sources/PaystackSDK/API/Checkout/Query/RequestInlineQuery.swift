import Foundation

public enum RequestInlineQuery {
    case email(String)
    case hasTLSFallback(Bool)
    case currency(String)
    case metadata(String)
    case device(String)
    case id(String)
    case lastname(String)
    case ref(String)
    case mode(String)
    case firstname(String)
    case amount(Int)
    case key(String)
}

extension RequestInlineQuery: Queryable {
    
    public var keyPair: (String, String) {
        switch self {
        case .email(let email):
            return ("email", email)
        case .hasTLSFallback(let hasTLSFallback):
            return ("hasTLSFallback", String(describing: hasTLSFallback))
        case .currency(let currency):
            return ("currency", currency)
        case .metadata(let metadata):
            return ("metadata", metadata)
        case .device(let device):
            return ("device", device)
        case .id(let id):
            return ("id", id)
        case .lastname(let lastname):
            return ("lastname", lastname)
        case .ref(let ref):
            return ("ref", ref)
        case .mode(let mode):
            return ("mode", mode)
        case .firstname(let firstname):
            return ("firstname", firstname)
        case .amount(let amount):
            return ("amount", String(describing: amount))
        case .key(let key):
            return ("key", key)
        }
    }
    
}
