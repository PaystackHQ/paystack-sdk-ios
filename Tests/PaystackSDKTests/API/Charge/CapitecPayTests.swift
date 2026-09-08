import XCTest
@testable import PaystackCore

final class CapitecPayTests: PSTestCase {

    let apiKey = "testsk_Example"

    var serviceUnderTest: Paystack!

    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceUnderTest = try PaystackBuilder.newInstance
            .setKey(apiKey)
            .build()
    }

    func testAuthenticateCapitecPayHitsCorrectURLAndMethodAndHeaders() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/capitec-pay/authenticate")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectHeader("Content-Type", "application/json")
            .andReturn(json: "CapitecPayAuthenticateResponse")

        let request = CapitecPayAuthenticateRequest(
            clientdata: "encrypted-blob",
            trans: "5900549926",
            device: "312d74aad3c2b37d5029755bffd50d2f")
        _ = try await serviceUnderTest.authenticateCapitecPay(request).async()
    }

    func testAuthenticateCapitecPayDecodesAllFieldsFromResponse() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/capitec-pay/authenticate")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "CapitecPayAuthenticateResponse")

        let request = CapitecPayAuthenticateRequest(
            clientdata: "encrypted-blob",
            trans: "5900549926",
            device: "device-id")
        let result = try await serviceUnderTest.authenticateCapitecPay(request).async()

        XCTAssertEqual(result.status, true)
        XCTAssertEqual(result.type, "success")
        XCTAssertEqual(result.code, "ok")
        XCTAssertEqual(result.message, "Charge pending")
        XCTAssertEqual(result.data.status, "success")
        XCTAssertEqual(result.data.timeToLive, 120)
        XCTAssertEqual(result.data.expiryDate,
                       DateFormatter.paystackFormatter.date(from: "2026-07-07T12:29:20.000Z"))
    }

    func testRequeryCapitecPayHitsCorrectURLWithTransactionReferenceInPath() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/capitec-pay/requery/T_ref_5900549926")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "CapitecRequeryResponse")

        _ = try await serviceUnderTest
            .requeryCapitecPay(transactionReference: "T_ref_5900549926")
            .async()
    }

    func testRequeryCapitecPayDecodesCapitecResponseShape() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/capitec-pay/requery/T_ref_5900549926")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "CapitecRequeryResponse")

        let result = try await serviceUnderTest
            .requeryCapitecPay(transactionReference: "T_ref_5900549926")
            .async()

        XCTAssertEqual(result.status, true)
        XCTAssertEqual(result.message, "Charge successful")
        XCTAssertEqual(result.data.status, "success")
    }

    // MARK: - Pusher envelope

    func testListenForCapitecPayResponseSubscribesToProvidedChannel() async throws {
        let channelName = "CAPITECPAY_5900549926"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "CapitecPayPusherSuccess")

        let result = try await serviceUnderTest
            .listenForCapitecPayResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, true)
        XCTAssertEqual(result.type, "success")
        XCTAssertEqual(result.code, "ok")
        XCTAssertEqual(result.message, "Charge successful")
        XCTAssertEqual(result.data?.status, "success")
    }

    func testListenForCapitecPayResponseDecodesFailedShapeWithoutData() async throws {
        let channelName = "CAPITECPAY_5900549926"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "CapitecPayPusherFailed")

        let result = try await serviceUnderTest
            .listenForCapitecPayResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, false)
        XCTAssertEqual(result.message, "Bank declined")
        XCTAssertNil(result.data)
    }

    func testListenForCapitecPayResponseDecodesEnvelopeWithMissingData() async throws {
        let channelName = "CAPITECPAY_5900549926"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "CapitecPayPusherPending")

        let result = try await serviceUnderTest
            .listenForCapitecPayResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, true)
        XCTAssertNil(result.data)
    }

    func testListenForCapitecPayResponseDecodesMinimalEnvelope() async throws {
        let channelName = "CAPITECPAY_5900549926"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString("{ \"status\": true }")

        let result = try await serviceUnderTest
            .listenForCapitecPayResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, true)
        XCTAssertNil(result.type)
        XCTAssertNil(result.code)
        XCTAssertNil(result.message)
        XCTAssertNil(result.data)
    }
}
