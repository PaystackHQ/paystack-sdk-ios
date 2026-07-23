import Foundation

enum CapitecPayState: Equatable {
    case identifierEntry
    case authenticating
    case awaitingApproval(CapitecPayDetails)
    case requerying(CapitecPayDetails)
    case error(ChargeError)
    case fatalError(error: ChargeError)
}
