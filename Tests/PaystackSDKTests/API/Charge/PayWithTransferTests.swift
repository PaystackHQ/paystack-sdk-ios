import XCTest
@testable import PaystackCore

final class PayWithTransferTests: PSTestCase {

    let apiKey = "testsk_Example"

    var serviceUnderTest: Paystack!

    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceUnderTest = try PaystackBuilder.newInstance
            .setKey(apiKey)
            .build()
    }

    func testPayWithTransferSubmitsRequestToCorrectURLAndMethodAndHeaders() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/checkout/pay_with_transfer")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "PayWithTransferResponse")

        let request = PayWithTransferRequest(fulfilLateNotification: true,
                                             transactionId: 6215047322,
                                             preferredProvider: nil)
        let result = try await serviceUnderTest.payWithTransfer(request).async()
        XCTAssertEqual(result, .jsonExample)
    }

    func testPayWithTransferDecodesAllFieldsFromResponse() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/checkout/pay_with_transfer")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "PayWithTransferResponse")

        let request = PayWithTransferRequest(fulfilLateNotification: false,
                                             transactionId: 6215047322)
        let result = try await serviceUnderTest.payWithTransfer(request).async()

        XCTAssertTrue(result.status)
        XCTAssertEqual(result.message, "Please make a transfer to the account specified")
        XCTAssertEqual(result.data.accountName, "PAYSTACK CHECKOUT")
        XCTAssertEqual(result.data.accountNumber, "9985488398")
        XCTAssertEqual(result.data.transactionReference, "T6215047322I100043S0g703")
        XCTAssertEqual(result.data.transactionId, "6215047322")
        XCTAssertEqual(result.data.pusherChannel, "PWT6215047322")
        XCTAssertEqual(result.data.bank.slug, "titan-paystack")
        XCTAssertEqual(result.data.bank.name, "Paystack-Titan")
        XCTAssertEqual(result.data.bank.id, 629)
    }

    func testPayWithTransferDecodesDateFieldsUsingPaystackFormatter() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/checkout/pay_with_transfer")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "PayWithTransferResponse")

        let request = PayWithTransferRequest(fulfilLateNotification: false,
                                             transactionId: 6215047322)
        let result = try await serviceUnderTest.payWithTransfer(request).async()

        let expectedAccountExpiry = DateFormatter.paystackFormatter
            .date(from: "2026-06-02T15:18:37.053Z")
        let expectedAssignmentExpiry = DateFormatter.paystackFormatter
            .date(from: "2026-06-02T22:48:37.053Z")
        XCTAssertEqual(result.data.accountExpiresAt, expectedAccountExpiry)
        XCTAssertEqual(result.data.assignmentExpiresAt, expectedAssignmentExpiry)
    }

    func testListenForTransferResponseSubscribesToProvidedChannelWithResponseEvent() async throws {
        let channelName = "PWT6215047322"
        let mockSubscription = PusherSubscription(channelName: channelName,
                                                  eventName: "response")
        mockSubscriptionListener
            .expectSubscription(mockSubscription)
            .andReturnString(fromJson: "PayWithTransferPusherSuccess")

        let result = try await serviceUnderTest
            .listenForTransferResponse(onChannel: channelName).async()
        XCTAssertEqual(result.status, "success")
    }

    func testListenForTransferResponseDecodesSuccessEvent() async throws {
        let channelName = "PWT3818017015"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "PayWithTransferPusherSuccess")

        let result = try await serviceUnderTest
            .listenForTransferResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, "success")
        XCTAssertEqual(result.message, "Payment Successful")
        XCTAssertEqual(result.data?.messageType, "SUCCESS")
        XCTAssertEqual(result.data?.transactionId, "3818017015")
        XCTAssertEqual(result.data?.reference, "T3818017015I615243Sujjxh")
        XCTAssertEqual(result.data?.trxref, "T3818017015I615243Sujjxh")
        XCTAssertEqual(result.data?.trans, "3818017015")
        XCTAssertEqual(result.data?.response, "Approved")
        XCTAssertEqual(result.data?.redirecturl, "")
        XCTAssertNil(result.errors)
    }

    func testListenForTransferResponseDecodesCreditRequestReceivedEvent() async throws {
        let channelName = "PWT3818017015"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "PayWithTransferPusherCreditReceived")

        let result = try await serviceUnderTest
            .listenForTransferResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, "transfer-credit-request-received")
        XCTAssertEqual(result.message, "credit request received")
        XCTAssertEqual(result.data?.messageType, "TRANSFER_CREDIT_REQUEST_RECEIVED")
        XCTAssertEqual(result.data?.referenceId, "3818017015")
        XCTAssertEqual(result.data?.transactionId, "3818017015")
    }

    func testListenForTransferResponseDecodesCreditRequestPendingEvent() async throws {
        let channelName = "PWT3818017015"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "PayWithTransferPusherCreditPending")

        let result = try await serviceUnderTest
            .listenForTransferResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, "transfer-credit-request-pending")
        XCTAssertEqual(result.data?.messageType, "TRANSFER_CREDIT_REQUEST_PENDING")
    }

    func testListenForTransferResponseDecodesCreditRequestRejectedEvent() async throws {
        let channelName = "PWT3818017015"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "PayWithTransferPusherCreditRejected")

        let result = try await serviceUnderTest
            .listenForTransferResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, "transfer-credit-request-rejected")
        XCTAssertEqual(result.message, "Transfer was rejected")
        XCTAssertEqual(result.data?.messageType, "TRANSFER_CREDIT_REQUEST_REJECTED")
    }

    func testListenForTransferResponseDecodesIncorrectAmountSentEvent() async throws {
        let channelName = "PWT3818017015"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channelName, eventName: "response"))
            .andReturnString(fromJson: "PayWithTransferPusherIncorrectAmount")

        let result = try await serviceUnderTest
            .listenForTransferResponse(onChannel: channelName).async()

        XCTAssertEqual(result.status, "failed")
        XCTAssertEqual(result.message, "incorrect amount sent")
        XCTAssertNil(result.data)
        XCTAssertNotNil(result.errors)
        XCTAssertEqual(result.errors?.isEmpty, true)
    }
}

private extension PayWithTransferResponse {
    static var jsonExample: PayWithTransferResponse {
        PayWithTransferResponse(
            status: true,
            message: "Please make a transfer to the account specified",
            data: PayWithTransferData(
                accountName: "PAYSTACK CHECKOUT",
                accountNumber: "9985488398",
                transactionReference: "T6215047322I100043S0g703",
                bank: TransferBank(slug: "titan-paystack",
                                   name: "Paystack-Titan",
                                   id: 629),
                accountExpiresAt: DateFormatter.paystackFormatter
                    .date(from: "2026-06-02T15:18:37.053Z")!,
                assignmentExpiresAt: DateFormatter.paystackFormatter
                    .date(from: "2026-06-02T22:48:37.053Z")!,
                transactionId: "6215047322",
                pusherChannel: "PWT6215047322"))
    }
}
