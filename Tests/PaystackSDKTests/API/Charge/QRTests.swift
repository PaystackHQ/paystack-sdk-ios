import XCTest
@testable import PaystackCore

final class QRTests: PSTestCase {

    let apiKey = "testsk_Example"

    var serviceUnderTest: Paystack!

    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceUnderTest = try PaystackBuilder.newInstance
            .setKey(apiKey)
            .build()
    }

    func testGenerateQRHitsCorrectURLAndMethodAndHeaders() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/offline/qr/generate")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectHeader("Content-Type", "application/json")
            .andReturn(json: "QRGenerateResponse")

        let request = QRGenerateRequest(
            reference: "T_ref_5900549926",
            channel: "MPASS_OLTI")
        _ = try await serviceUnderTest.generateQR(request).async()
    }

    func testGenerateQRDecodesAllFieldsFromResponse() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/offline/qr/generate")
            .expectMethod(.post)
            .andReturn(json: "QRGenerateResponse")

        let request = QRGenerateRequest(
            reference: "T_ref_5900549926",
            channel: "MPASS_OLTI")
        let result = try await serviceUnderTest.generateQR(request).async()

        XCTAssertEqual(result.status, true)
        XCTAssertEqual(result.message, "QR successfully generated")
        XCTAssertEqual(result.data.errors, false)
        XCTAssertEqual(result.data.qrCode, "1490884538")
        XCTAssertEqual(result.data.status, "success")
        XCTAssertEqual(result.data.channel, "api_mpass_olti_qr_51826223921246")
        XCTAssertTrue(result.data.url.hasPrefix("https://s3.eu-west-1.amazonaws.com/"))
    }

    func testGenerateQRDefaultsSourceToCheckout() {
        let request = QRGenerateRequest(
            reference: "T_ref_5900549926",
            channel: "MPASS_OLTI")
        XCTAssertEqual(request.source, "checkout")
    }

    // MARK: - Pusher envelope (Scan to Pay / SnapScan)

    func testListenForQRResponseSubscribesToProvidedChannel() async throws {
        let channelName = "api_mpass_olti_qr_51826223921246"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "QRPusherSuccess")

        let result = try await serviceUnderTest
            .listenForQRResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, true)
        XCTAssertEqual(result.message, "Payment Successful")
        XCTAssertEqual(result.response, "Approved")
        XCTAssertEqual(result.reference, "T195096317254637")
        XCTAssertEqual(result.transactionReference, "T195096317254637")
    }

    /// `trans` arrives as a JSON number on this channel — the field that
    /// broke the previous `Charge3DSResponse` decode.
    func testListenForQRResponseDecodesNumericTransAsString() async throws {
        let channelName = "api_mpass_olti_qr_51826223921246"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "QRPusherSuccess")

        let result = try await serviceUnderTest
            .listenForQRResponse(onChannel: channelName).async()

        XCTAssertEqual(result.transaction, "6537606334")
    }

    func testListenForQRResponseDecodesStringTransToo() async throws {
        let channelName = "api_mpass_olti_qr_51826223921246"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "QRPusherTransAsString")

        let result = try await serviceUnderTest
            .listenForQRResponse(onChannel: channelName).async()

        XCTAssertEqual(result.transaction, "6537606334")
        XCTAssertEqual(result.status, true)
    }

    /// `redirecturl` is all lowercase on the wire, so `.convertFromSnakeCase`
    /// never maps it — it needs the explicit coding key.
    func testListenForQRResponseDecodesLowercaseRedirecturlKey() async throws {
        let channelName = "api_mpass_olti_qr_51826223921246"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "QRPusherSuccess")

        let result = try await serviceUnderTest
            .listenForQRResponse(onChannel: channelName).async()

        XCTAssertEqual(
            result.redirectUrl,
            "https://rian.co.za/ptest/callback.php?trxref=T195096317254637&reference=T195096317254637")
    }

    func testListenForQRResponseDecodesPageWithNullMembers() async throws {
        let channelName = "api_mpass_olti_qr_51826223921246"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "QRPusherSuccess")

        let result = try await serviceUnderTest
            .listenForQRResponse(onChannel: channelName).async()

        XCTAssertEqual(result.page, QRPusherPage(redirectUrl: nil, successMessage: nil))
    }

    func testListenForQRResponseDecodesFailedShape() async throws {
        let channelName = "api_mpass_olti_qr_51826223921246"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "QRPusherFailed")

        let result = try await serviceUnderTest
            .listenForQRResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, false)
        XCTAssertEqual(result.message, "Wallet declined the payment")
        XCTAssertEqual(result.response, "Declined")
    }

    func testListenForQRResponseDecodesMinimalEnvelope() async throws {
        let channelName = "api_mpass_olti_qr_51826223921246"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString("{ \"status\": true }")

        let result = try await serviceUnderTest
            .listenForQRResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, true)
        XCTAssertNil(result.message)
        XCTAssertNil(result.transaction)
        XCTAssertNil(result.redirectUrl)
        XCTAssertNil(result.page)
    }
}
