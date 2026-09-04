import XCTest
@testable import PaystackCore
@testable import PaystackUI

final class QRRepositoryImplementationTests: PSTestCase {

    let apiKey = "testsk_Example"
    var serviceUnderTest: QRRepositoryImplementation!
    var paystack: Paystack!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paystack = try PaystackBuilder.newInstance.setKey(apiKey).build()
        PaystackContainer.instance.store(paystack)
        serviceUnderTest = QRRepositoryImplementation()
    }

    func testGenerateHitsCorrectURLAndMethodAndHeaders() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/offline/qr/generate")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "QRGenerateResponse")

        _ = try await serviceUnderTest.generate(
            reference: "5900549926",
            channelOption: "MPASS_OLTI",
            variant: .scanToPay)
    }

    func testGenerateMapsResponseIntoScanToPayDetailsWithQRReference() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/offline/qr/generate")
            .expectMethod(.post)
            .andReturn(json: "QRGenerateResponse")

        let result = try await serviceUnderTest.generate(
            reference: "5900549926",
            channelOption: "MPASS_OLTI",
            variant: .scanToPay)

        XCTAssertEqual(result.qrReference, "1490884538")
        XCTAssertEqual(result.pusherChannel, "api_mpass_olti_qr_51826223921246")
    }

    func testGenerateMapsResponseIntoSnapScanDetailsWithoutQRReference() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/offline/qr/generate")
            .expectMethod(.post)
            .andReturn(json: "QRGenerateResponse")

        let result = try await serviceUnderTest.generate(
            reference: "5900549926",
            channelOption: "MPASS_OLTI",
            variant: .snapScan)

        XCTAssertNil(result.qrReference)
        XCTAssertEqual(result.pusherChannel, "api_mpass_olti_qr_51826223921246")
    }

    func testListenForResponseSubscribesToProvidedChannel() async throws {
        let channel = "api_mpass_olti_qr_51826223921246"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channel, eventName: "response"))
            .andReturnString(fromJson: "QRPusherSuccess")

        let result = try await serviceUnderTest
            .listenForResponse(onChannel: channel)

        XCTAssertEqual(result.status, .success)
    }

    func testCheckPendingHitsSharedSDKEndpointNotAQRSpecificOne() async throws {
        let accessCode = "test_access_code"
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/charge/\(accessCode)")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "ChargeAuthenticationResponse")

        _ = try await serviceUnderTest.checkPending(accessCode: accessCode)
    }

    func testCheckPendingMapsResponseIntoChargeCardTransaction() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/charge/test_access_code")
            .expectMethod(.get)
            .andReturn(json: "ChargeAuthenticationResponse")

        let result = try await serviceUnderTest
            .checkPending(accessCode: "test_access_code")

        XCTAssertEqual(result.status, .success)
    }
}
