import XCTest
@testable import PaystackCore
@testable import PaystackUI

final class CapitecPayRepositoryImplementationTests: PSTestCase {

    let apiKey = "testsk_Example"
    var serviceUnderTest: CapitecPayRepositoryImplementation!
    var paystack: Paystack!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paystack = try PaystackBuilder.newInstance.setKey(apiKey).build()
        PaystackContainer.instance.store(paystack)
        serviceUnderTest = CapitecPayRepositoryImplementation(
            cryptography: FakeCryptography())
    }

    func testAuthenticateHitsCorrectURLAndMethodAndHeaders() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/capitec-pay/authenticate")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "CapitecPayAuthenticateResponse")

        _ = try await serviceUnderTest.authenticate(
            identifier: .cellphone,
            value: "0609603632",
            transactionId: 5900549926,
            deviceId: "device-id",
            publicEncryptionKey: "test_key")
    }

    func testAuthenticateMapsResponseIntoCapitecPayDetails() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/capitec-pay/authenticate")
            .expectMethod(.post)
            .andReturn(json: "CapitecPayAuthenticateResponse")

        let result = try await serviceUnderTest.authenticate(
            identifier: .cellphone,
            value: "0609603632",
            transactionId: 5900549926,
            deviceId: "device-id",
            publicEncryptionKey: "test_key")

        XCTAssertEqual(result.timeToLive, 120)
        XCTAssertEqual(result.pusherChannel, "CAPITECPAY_5900549926")
    }

    func testRequeryHitsCorrectURLWithTransactionReferenceInPath() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/capitec-pay/requery/T_ref_5900549926")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "ChargeAuthenticationResponse")

        _ = try await serviceUnderTest.requery(
            transactionReference: "T_ref_5900549926")
    }

    func testRequeryMapsResponseIntoChargeCardTransaction() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/capitec-pay/requery/T_ref_5900549926")
            .expectMethod(.post)
            .andReturn(json: "ChargeAuthenticationResponse")

        let result = try await serviceUnderTest.requery(
            transactionReference: "T_ref_5900549926")

        XCTAssertEqual(result.status, .success)
    }

    func testListenForCapitecPayResponseSubscribesToProvidedChannel() async throws {
        let channel = "CAPITECPAY_5900549926"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channel, eventName: "response"))
            .andReturnString(fromJson: "CapitecPayPusherSuccess")

        let result = try await serviceUnderTest
            .listenForCapitecPayResponse(onChannel: channel)

        XCTAssertEqual(result.status, .success)
    }
}

private struct FakeCryptography: CryptographyProtocol {
    func encryptPKCS1(text: String, publicKey: String) throws -> String {
        return "fake-encrypted:\(text)"
    }
}
