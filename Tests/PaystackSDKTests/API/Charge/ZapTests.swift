import XCTest
@testable import PaystackCore

final class ZapTests: PSTestCase {

    let apiKey = "testsk_Example"

    var serviceUnderTest: Paystack!

    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceUnderTest = try PaystackBuilder.newInstance
            .setKey(apiKey)
            .build()
    }

    // MARK: - initiateZapMandate

    func testInitiateZapMandateHitsStandardHostNotApiHost() async throws {
        mockServiceExecutor
            .expectURL("https://standard.paystack.co/bank/digitalbankmandate/870/6222375579")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectHeader("Content-Type", "application/x-www-form-urlencoded")
            .andReturn(json: "ZapMandateResponse")

        let request = ZapMandateRequest(id: 870,
                                        transactionId: 6222375579,
                                        walletId: "customer@example.com")
        _ = try await serviceUnderTest.initiateZapMandate(request).async()
    }

    func testInitiateZapMandateDecodesAllFieldsFromResponse() async throws {
        mockServiceExecutor
            .expectURL("https://standard.paystack.co/bank/digitalbankmandate/870/6222375579")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "ZapMandateResponse")

        let request = ZapMandateRequest(id: 870,
                                        transactionId: 6222375579,
                                        walletId: "customer@example.com")
        let result = try await serviceUnderTest.initiateZapMandate(request).async()

        XCTAssertEqual(result.status, "pending")
        XCTAssertEqual(result.message, "Transaction Initiated")
        XCTAssertEqual(result.pusherChannel, "DBMAN_6222375579")
        XCTAssertEqual(result.paymentUrl,
                       "https://joinzap.com/app/merchant-payment/f3k3t3c88ovR6P7CDkKu")
        XCTAssertTrue(result.qrImage.hasPrefix("https://"))
    }

    // MARK: - listenForZapResponse

    func testListenForZapResponseSubscribesToProvidedChannelWithResponseEvent() async throws {
        let channelName = "DBMAN_6222375579"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "PayWithTransferPusherSuccess")

        let result = try await serviceUnderTest
            .listenForZapResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, "success")
    }
}
