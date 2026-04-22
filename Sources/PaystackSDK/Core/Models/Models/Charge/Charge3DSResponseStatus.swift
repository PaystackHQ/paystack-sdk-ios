import Foundation

public enum Charge3DSResponseStatus: String, Decodable {
    case success
    case failed
    case zeroFailed = "0"
}
