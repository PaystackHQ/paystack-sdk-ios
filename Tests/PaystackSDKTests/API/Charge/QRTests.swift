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

    func testGenerateQRDefaultsSourceToMobilePos() {
        let request = QRGenerateRequest(
            reference: "T_ref_5900549926",
            channel: "MPASS_OLTI")
        XCTAssertEqual(request.source, "mobile-pos")
    }

    func testListenForQRResponseSubscribesToProvidedChannel() async throws {
        let channelName = "api_mpass_olti_qr_51826223921246"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "QRPusherSuccess")

        let result = try await serviceUnderTest
            .listenForQRResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, .success)
    }

    func testListenForQRResponseDecodesFailedShape() async throws {
        let channelName = "api_mpass_olti_qr_51826223921246"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "QRPusherFailed")

        let result = try await serviceUnderTest
            .listenForQRResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, .failed)
        XCTAssertEqual(result.message, "Wallet declined the payment")
    }
}
