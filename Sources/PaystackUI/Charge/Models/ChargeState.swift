import Foundation

// TODO: Add more states here as we need them
enum ChargeState {
    case loading
    case cardDetails(VerifyAccessCode)
    case error(Error)
}
