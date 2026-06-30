import XCTest
@testable import PaystackCore
@testable import PaystackUI

final class ZapRepositoryImplementationTests: PSTestCase {

    let apiKey = "testsk_Example"
    var serviceUnderTest: ZapRepositoryImplementation!
    var paystack: Paystack!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paystack = try PaystackBuilder.newInstance.setKey(apiKey).build()
        PaystackContainer.instance.store(paystack)
        serviceUnderTest = ZapRepositoryImplementation()
    }

    // MARK: - initiateZapMandate

    /// End-to-end: builds the right URL on the Zap host, posts a
    /// form-urlencoded body, decodes the response into `ZapMandateResponse`.
    func testInitiateZapMandateSubmitsRequestUsingPaystackObjectAndMapsCorrectlyToModel() async throws {
        mockServiceExecutor
            .expectURL("https://standard.paystack.co/bank/digitalbankmandate/870/6222375579")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectHeader("Content-Type", "application/x-www-form-urlencoded")
            .andReturn(json: "ZapMandateResponse")

        let result = try await serviceUnderTest.initiateZapMandate(
            supportedBankId: 870,
            transactionId: 6222375579,
            walletEmail: "customer@example.com")

        XCTAssertEqual(result, .jsonExample)
    }

    /// Regression for the `baseURL` override on `ZapMandateServiceImplementation`.
    /// If the override regresses to the default `api.paystack.co`, this
    /// expected URL stops matching and the test fails.
    func testInitiateZapMandateHitsStandardHostNotApiHost() async throws {
        mockServiceExecutor
            .expectURL("https://standard.paystack.co/bank/digitalbankmandate/870/6222375579")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "ZapMandateResponse")

        _ = try await serviceUnderTest.initiateZapMandate(
            supportedBankId: 870,
            transactionId: 6222375579,
            walletEmail: "customer@example.com")
    }

    /// Regression for the new `postForm(_:_:)` helper. If the service
    /// regresses to JSON `post`, the Content-Type expectation fails.
    func testInitiateZapMandateUsesFormUrlencodedContentType() async throws {
        mockServiceExecutor
            .expectURL("https://standard.paystack.co/bank/digitalbankmandate/870/6222375579")
            .expectMethod(.post)
            .expectHeader("Content-Type", "application/x-www-form-urlencoded")
            .andReturn(json: "ZapMandateResponse")

        _ = try await serviceUnderTest.initiateZapMandate(
            supportedBankId: 870,
            transactionId: 6222375579,
            walletEmail: "customer@example.com")
    }

    func testInitiateZapMandateDecodesAllFieldsFromResponse() async throws {
        mockServiceExecutor
            .expectURL("https://standard.paystack.co/bank/digitalbankmandate/870/6222375579")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "ZapMandateResponse")

        let result = try await serviceUnderTest.initiateZapMandate(
            supportedBankId: 870,
            transactionId: 6222375579,
            walletEmail: "customer@example.com")

        XCTAssertEqual(result.status, "pending")
        XCTAssertEqual(result.message, "Transaction Initiated")
        XCTAssertEqual(result.pusherChannel, "DBMAN_6222375579")
        XCTAssertEqual(result.paymentUrl,
                       "https://joinzap.com/app/merchant-payment/f3k3t3c88ovR6P7CDkKu")
        XCTAssertTrue(result.qrImage.hasPrefix("https://"))
    }

    /// Each call should encode the `(supportedBankId, transactionId)` pair
    /// into the path — a different pair produces a different URL.
    func testInitiateZapMandateEmbedsSupportedBankIdAndTransactionIdInPath() async throws {
        mockServiceExecutor
            .expectURL("https://standard.paystack.co/bank/digitalbankmandate/42/9999")
            .expectMethod(.post)
            .andReturn(json: "ZapMandateResponse")

        _ = try await serviceUnderTest.initiateZapMandate(
            supportedBankId: 42,
            transactionId: 9999,
            walletEmail: "x@example.com")
    }

    // MARK: - listenForZapResponse

    /// Subscribes to the Pusher channel with the same `eventName: "response"`
    /// contract as Pay-with-Transfer, and the success payload maps cleanly
    /// to a `BankTransferTransactionUpdate` (shared wire format).
    func testListenForZapResponseSubscribesToProvidedChannelAndMapsSuccess() async throws {
        let channel = "DBMAN_6222375579"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channel, eventName: "response"))
            .andReturnString(fromJson: "PayWithTransferPusherSuccess")

        let result = try await serviceUnderTest.listenForZapResponse(onChannel: channel)

        XCTAssertEqual(result.status, .success)
        XCTAssertEqual(result.message, "Payment Successful")
        XCTAssertEqual(result.transactionId, "3818017015")
        XCTAssertEqual(result.reference, "T3818017015I615243Sujjxh")
    }

    /// `failed` is the second of the two statuses Zap is documented to
    /// emit (the other being `success`). Reuses the existing PWT
    /// "failed-shape" fixture since Zap shares the wire format.
    func testListenForZapResponseMapsFailedStatusFromSharedWireFormat() async throws {
        let channel = "DBMAN_6222375579"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channel, eventName: "response"))
            .andReturnString(fromJson: "PayWithTransferPusherIncorrectAmount")

        let result = try await serviceUnderTest.listenForZapResponse(onChannel: channel)

        XCTAssertEqual(result.status, .failed)
        XCTAssertEqual(result.message, "incorrect amount sent")
    }

    /// The channel name is passed through verbatim — the SDK doesn't
    /// rewrite the `DBMAN_*` prefix or anything else. Mirror the PWT
    /// repository's equivalent test so any future regression where the
    /// channel name is mutated would fail loudly.
    func testListenForZapResponsePassesChannelNameThroughVerbatim() async throws {
        let channel = "DBMAN_arbitrary_123"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channel, eventName: "response"))
            .andReturnString(fromJson: "PayWithTransferPusherSuccess")

        _ = try await serviceUnderTest.listenForZapResponse(onChannel: channel)
    }
}

// MARK: - Fixtures

private extension ZapMandateResponse {
    static var jsonExample: ZapMandateResponse {
        ZapMandateResponse(
            status: "pending",
            message: "Transaction Initiated",
            pusherChannel: "DBMAN_6222375579",
            paymentUrl: "https://joinzap.com/app/merchant-payment/f3k3t3c88ovR6P7CDkKu",
            qrImage: "https://paystack-production-zap-eu-west-1.s3.eu-west-1.amazonaws.com/merchant-payments/qr/f3k3t3c88ovR6P7CDkKu/qr_f3k3t3c88ovR6P7CDkKu.png")
    }
}
