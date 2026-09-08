import Foundation

/// The event published on the Capitec Pay Pusher channel
/// (`CAPITECPAY_{transactionId}`, event `response`).
///
/// Capitec Pay does **not** use the flat ``Charge3DSResponse`` shape shared by
/// card 3-D Secure, mobile money, Zap, QR and bank transfer. The top-level
/// `status` is a `Bool` and the transaction status is nested under `data`:
///
/// ```json
/// {
///     "status": true,
///     "type": "success",
///     "code": "ok",
///     "data": { "status": "success" },
///     "message": "Charge successful"
/// }
/// ```
///
/// A failure is signalled by `status: false`. Everything below `status` is
/// optional — the backend does not guarantee `data` on every event — so a
/// partial envelope still decodes rather than throwing and dropping the
/// single-shot subscription on the floor.
public struct CapitecPusherResponse: Decodable, Equatable {
    /// `true` for a successful charge, `false` for a terminal failure.
    public var status: Bool
    public var type: String?
    public var code: String?
    public var message: String?
    /// Absent on some events — never force-unwrap.
    public var data: CapitecPusherResponseData?

    public init(status: Bool,
                type: String? = nil,
                code: String? = nil,
                message: String? = nil,
                data: CapitecPusherResponseData? = nil) {
        self.status = status
        self.type = type
        self.code = code
        self.message = message
        self.data = data
    }
}

public struct CapitecPusherResponseData: Decodable, Equatable {
    /// `"success"` / `"failed"` — the transaction status proper.
    public var status: String?

    public init(status: String? = nil) {
        self.status = status
    }
}
