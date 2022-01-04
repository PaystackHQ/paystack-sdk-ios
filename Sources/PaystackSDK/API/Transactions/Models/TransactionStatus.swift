import Foundation

public enum TransactionStatus: String, Decodable {
    case success
    case failed
    case abandoned
    case reversed
}
