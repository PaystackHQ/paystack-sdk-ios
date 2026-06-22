import Foundation

/// Public Zap surface. Used by the UI module to initiate a digital bank
/// mandate and listen for Event status updates ; can also be called
/// directly by integrators driving their own UI on top of `PaystackCore`.
public extension Paystack {

    private var zapService: ZapMandateService {
        return ZapMandateServiceImplementation(config: config)
    }

    /// Initiates a Zap digital bank mandate for the given supported-bank
    /// entry + transaction. Returns the deeplink URL, QR image URL, and
    /// the Pusher channel to subscribe to for status updates.
    ///
    /// - Parameter request: Combines the Zap `supported_banks.id`, the
    ///   numeric transaction id from `verify_access_code`, and the
    ///   customer's email (sent as `wallet_id` in the form body).
    /// - Returns: A ``Service`` carrying a ``ZapMandateResponse``.
    func initiateZapMandate(_ request: ZapMandateRequest)
        -> Service<ZapMandateResponse> {
        return zapService.postZapMandate(request)
    }

    /// Listens for Zap status updates on the Pusher channel returned by
    /// ``initiateZapMandate(_:)``. The status taxonomy is shared with
    /// Pay-with-Transfer, so this
    /// helper returns the existing `PayWithTransferPusherResponse` shape.
    ///
    /// The underlying listener is single-shot per the existing
    /// `PusherSubscriptionListener` contract ; callers that need to keep
    /// listening through transient statuses must re-subscribe after each
    /// event.
    ///
    /// - Parameter channelName: The `pusherChannel` value returned from
    ///   `initiateZapMandate` (e.g. `DBMAN_6222375579`).
    /// - Returns: A ``Service`` carrying a ``PayWithTransferPusherResponse``
    ///   on the first event the channel emits.
    func listenForZapResponse(onChannel channelName: String)
        -> Service<PayWithTransferPusherResponse> {
        let subscription: any Subscription = PusherSubscription(
            channelName: channelName, eventName: "response")
        return Service(subscription)
    }
}
