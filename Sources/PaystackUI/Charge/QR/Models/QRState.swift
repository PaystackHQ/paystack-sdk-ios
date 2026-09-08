import Foundation

enum QRState: Equatable {
    case loadingQR
    case awaitingScan(QRDetails)
    case verifying(QRDetails)
    case error(ChargeError)
    case fatalError(error: ChargeError)
}
