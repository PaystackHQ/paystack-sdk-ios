import Foundation
import PaystackCore

/// The normalised terminal-status view of a Capitec Pay transaction.
///
/// Both resolution paths — the Pusher event and the requery endpoint — map
/// onto this type, so `CapitecPayViewModel` has a single place where a
/// terminal status is interpreted.
struct ChargeCapitecTransaction: Equatable {
    /// Lowercased transaction status, e.g. `"success"` / `"failed"`.
    /// Empty when the payload carried nothing terminal.
    var status: String
    /// Server-supplied message, used as the failure reason when present.
    var message: String?
}

extension ChargeCapitecTransaction {

    static func from(_ response: CapitecResponse) -> Self {
        ChargeCapitecTransaction(status: normalise(response.data.status),
                                 message: response.message)
    }

    /// Maps the Capitec Pay Pusher envelope.
    ///
    /// - `status: false` is a terminal failure regardless of what `data` holds.
    /// - Otherwise the transaction status comes from `data.status`.
    /// - `data` is not guaranteed: with `status: true` and no `data` there is
    ///   nothing terminal to act on, so this maps to an empty status and the
    ///   requery loop resolves the transaction instead.
    static func from(_ response: CapitecPusherResponse) -> Self {
        guard response.status else {
            return ChargeCapitecTransaction(status: CapitecTransactionStatus.failed,
                                            message: response.message)
        }
        return ChargeCapitecTransaction(status: normalise(response.data?.status),
                                        message: response.message)
    }

    private static func normalise(_ status: String?) -> String {
        guard let status else { return "" }
        return status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

/// The terminal status values `CapitecPayViewModel` acts on.
enum CapitecTransactionStatus {
    static let success = "success"
    static let failed = "failed"
}
