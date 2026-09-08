import Foundation

/// Public QR-payment surface. Used by the UI module to generate a hosted
/// QR image for a transaction (Scan to Pay / Snap Scan et al) and to
/// subscribe for Pusher status events. Can also be called directly by
/// integrators driving their own UI on top of `PaystackCore`.
public extension Paystack {

    private var qrService: QRService {
        return QRServiceImplementation(config: config)
    }

    /// Generates a QR code for a transaction against
    /// `POST /offline/qr/generate`. The `channel` field on
    /// ``QRGenerateRequest`` is the provider code returned in
    /// `VerifyAccessCode.channelOptions.qrCode` (for example
    /// `"MPASS_OLTI"` for Ukheshe-served flows in ZA) — the SDK does not
    /// hard-code that value so the same call works for future markets
    /// that expose different provider codes.
    ///
    /// - Parameter request: The generate payload — source, transaction
    ///   reference, and provider channel code.
    /// - Returns: A ``Service`` carrying a ``QRGenerateResponse`` whose
    ///   `data.url` is a signed S3 URL for the QR image and whose
    ///   `data.channel` is the Pusher channel to subscribe on.
    func generateQR(_ request: QRGenerateRequest)
        -> Service<QRGenerateResponse> {
        return qrService.postGenerate(request)
    }

    /// Listens for QR-payment status updates on the Pusher channel
    /// returned by ``generateQR(_:)`` — the same channel serves Scan to Pay
    /// and SnapScan.
    ///
    /// The QR channel publishes its own envelope rather than the flat
    /// ``Charge3DSResponse`` shape used by card 3-D Secure, mobile money,
    /// Zap and bank transfer: the top-level `status` is a `Bool`, `trans`
    /// is a JSON number, and the redirect key is spelled `redirecturl`.
    /// See ``QRPusherResponse``.
    ///
    /// The underlying listener is single-shot per the existing
    /// `PusherSubscriptionListener` contract — one event resolves the
    /// listener.
    ///
    /// - Parameter channelName: The `data.channel` value returned by
    ///   ``generateQR(_:)`` (for example
    ///   `"api_mpass_olti_qr_51826223921246"`).
    /// - Returns: A ``Service`` carrying a ``QRPusherResponse`` on the
    ///   first event the channel emits.
    func listenForQRResponse(onChannel channelName: String)
        -> Service<QRPusherResponse> {
        let subscription: any Subscription = PusherSubscription(
            channelName: channelName, eventName: "response")
        return Service(subscription)
    }
}
