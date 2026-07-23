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
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "ChargeAuthenticationResponse")

        _ = try await serviceUnderTest
            .requeryCapitecPay(transactionReference: "T_ref_5900549926")
            .async()
    }

    func testRequeryCapitecPayDecodesChargeResponseShape() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/capitec-pay/requery/T_ref_5900549926")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "ChargeAuthenticationResponse")

        let result = try await serviceUnderTest
            .requeryCapitecPay(transactionReference: "T_ref_5900549926")
            .async()

        XCTAssertEqual(result.status, true)
        XCTAssertEqual(result.data.reference, "36xz3b9rie9ppvz")
    }

    func testListenForCapitecPayResponseSubscribesToProvidedChannel() async throws {
        let channelName = "CAPITECPAY_5900549926"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "CapitecPayPusherSuccess")

        let result = try await serviceUnderTest
            .listenForCapitecPayResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, .success)
    }

    func testListenForCapitecPayResponseDecodesFailedShape() async throws {
        let channelName = "CAPITECPAY_5900549926"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "CapitecPayPusherFailed")

        let result = try await serviceUnderTest
            .listenForCapitecPayResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, .failed)
        XCTAssertEqual(result.message, "Bank declined")
    }
}
