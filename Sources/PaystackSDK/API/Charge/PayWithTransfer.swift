import Foundation

/// Public Pay-with-Transfer surface. Used by the UI module to provision a
/// virtual bank account and listen for Pusher status updates ; can also be
/// called directly by integrators driving their own UI on top of
/// `PaystackCore`.
public extension Paystack {

    private var service: PayWithTransferService {
        return PayWithTransferServiceImplementation(config: config)
    }

    /// Provisions a one-time virtual bank account for the customer to make
    /// a transfer to. The response's `pusherChannel` should be subscribed
    /// to via ``listenForTransferResponse(onChannel:)`` for real-time
    /// status updates ; the response's `accountExpiresAt` drives the
    /// customer-facing countdown.
    ///
    /// - Parameter request: Required configuration for the virtual account.
    ///   `preferredProvider` is optional — when omitted, the backend picks
    ///   a default (typically `paystack-titan`).
    /// - Returns: A ``Service`` with the ``PayWithTransferResponse`` payload.
    func payWithTransfer(_ request: PayWithTransferRequest)
        -> Service<PayWithTransferResponse> {
        return service.postPayWithTransfer(request)
    }

    /// Listens for Pay-with-Transfer status updates on the Pusher channel
    /// returned by ``payWithTransfer(_:)``. The underlying listener is
    /// single-shot per the existing `PusherSubscriptionListener` contract,
    /// so callers that need to keep listening through transient statuses
    /// must re-subscribe after each event.
    ///
    /// - Parameter channelName: The `pusherChannel` value returned from
    ///   `payWithTransfer` (e.g. `PWT6215047322`).
    /// - Returns: A ``Service`` carrying a ``PayWithTransferPusherResponse``
    ///   on the first event the channel emits.
    func listenForTransferResponse(onChannel channelName: String)
        -> Service<PayWithTransferPusherResponse> {
        let subscription: any Subscription = PusherSubscription(
            channelName: channelName, eventName: "response")
        return Service(subscription)
    }
}
