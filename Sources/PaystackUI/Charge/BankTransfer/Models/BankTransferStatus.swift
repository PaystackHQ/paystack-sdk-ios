import Foundation

enum BankTransferStatus: Equatable {
    case success

    case creditRequestPending

    case creditRequestReceived

    case creditRequestRejected

    case incorrectAmountSent

    case pending

    case requery

    case failed

    case unknown(String)

    init(rawStatus: String, message: String?) {
        switch rawStatus {
        case "success":
            self = .success
        case "transfer-credit-request-pending":
            self = .creditRequestPending
        case "transfer-credit-request-received":
            self = .creditRequestReceived
        case "transfer-credit-request-rejected":
            self = .creditRequestRejected
        case "incorrect-amount-sent":
            self = .incorrectAmountSent
        case "pending":
            self = .pending
        case "requery":
            self = .requery
        case "failed":
            self = .failed
        default:
            self = .unknown(rawStatus)
        }
    }

    var isTerminal: Bool {
        switch self {
        case .success, .creditRequestRejected, .incorrectAmountSent, .failed:
            return true
        case .creditRequestPending, .creditRequestReceived,
             .pending, .requery, .unknown:
            return false
        }
    }
}
