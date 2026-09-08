import Foundation

/// Public Capitec Pay surface. Used by the UI module to authenticate a
/// Capitec Pay transaction, poll for its status via the Capitec-specific
/// requery endpoint, and subscribe for Pusher events. Can also be called
/// directly by integrators driving their own UI on top of `PaystackCore`.
public extension Paystack {

    private var capitecPayService: CapitecPayService {
        return CapitecPayServiceImplementation(config: config)
    }

    /// Authenticates a Capitec Pay transaction against
    /// `POST /capitec-pay/authenticate`. The `clientdata` field on
    /// ``CapitecPayAuthenticateRequest`` must already be RSA-encrypted
    /// using the merchant's public encryption key from
    /// ``VerifyAccessCode``.
    ///
    /// - Parameter request: The authenticate payload — pre-encrypted
    ///   client data, transaction id, and device fingerprint.
    /// - Returns: A ``Service`` carrying a ``CapitecPayAuthenticateResponse``
    ///   with the `timeToLive` window the SDK counts down against.
    func authenticateCapitecPay(_ request: CapitecPayAuthenticateRequest)
        -> Service<CapitecPayAuthenticateResponse> {
        return capitecPayService.postAuthenticate(request)
    }

    /// Polls the Capitec Pay requery endpoint
    /// (`POST /capitec-pay/requery/{transactionReference}`) for the
    /// current transaction status. The response follows the standard
    /// charge shape — same decoding path as ``checkPendingCharge(forAccessCode:)``.
    ///
    /// - Parameter transactionReference: The `reference` returned from
    ///   `verify_access_code`.
    /// - Returns: A ``Service`` carrying a ``CapitecResponse``.
    func requeryCapitecPay(transactionReference: String)
        -> Service<CapitecResponse> {
        return capitecPayService.postRequery(transactionReference: transactionReference)
    }

    /// Listens for Capitec Pay status updates on the Pusher channel
    /// returned by ``authenticateCapitecPay(_:)``.
    ///
    /// Capitec Pay publishes its own envelope rather than the flat
    /// ``Charge3DSResponse`` shape used by card 3-D Secure, mobile money,
    /// Zap, QR and bank transfer — the top-level `status` is a `Bool` and
    /// the transaction status is nested at `data.status`. See
    /// ``CapitecPusherResponse``.
    ///
    /// The underlying listener is single-shot per the existing
    /// `PusherSubscriptionListener` contract — one event resolves the
    /// listener. Non-terminal events are therefore not expected here; the
    /// requery loop is what resolves anything this channel does not.
    ///
    /// - Parameter channelName: The `CAPITECPAY_{transactionId}` channel
    ///   for this transaction.
    /// - Returns: A ``Service`` carrying a ``CapitecPusherResponse`` on the
    ///   first event the channel emits.
    func listenForCapitecPayResponse(onChannel channelName: String)
        -> Service<CapitecPusherResponse> {
        let subscription: any Subscription = PusherSubscription(
            channelName: channelName, eventName: "response")
        return Service(subscription)
    }
}
