import XCTest
@testable import PaystackCore
@testable import PaystackUI

final class BankTransferRepositoryImplementationTests: PSTestCase {

    let apiKey = "testsk_Example"
    var serviceUnderTest: BankTransferRepositoryImplementation!
    var paystack: Paystack!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paystack = try PaystackBuilder.newInstance.setKey(apiKey).build()
        PaystackContainer.instance.store(paystack)
        serviceUnderTest = BankTransferRepositoryImplementation()
    }

    func testPayWithTransferSubmitsRequestUsingPaystackObjectAndMapsCorrectlyToModel() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/checkout/pay_with_transfer")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "PayWithTransferResponse")

        let result = try await serviceUnderTest.payWithTransfer(
            fulfilLateNotification: true,
            transactionId: 6215047322,
            preferredProvider: nil)

        XCTAssertEqual(result, .jsonExample)
    }

    func testPayWithTransferMapsBankNameAndSlugFromResponse() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/checkout/pay_with_transfer")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "PayWithTransferResponse")

        let result = try await serviceUnderTest.payWithTransfer(
            fulfilLateNotification: false,
            transactionId: 6215047322,
            preferredProvider: nil)

        XCTAssertEqual(result.bankName, "Paystack-Titan")
        XCTAssertEqual(result.bankSlug, "titan-paystack")
        XCTAssertEqual(result.accountNumber, "9985488398")
        XCTAssertEqual(result.accountName, "PAYSTACK CHECKOUT")
        XCTAssertEqual(result.pusherChannel, "PWT6215047322")
        XCTAssertEqual(result.transactionId, "6215047322")
        XCTAssertEqual(result.transactionReference, "T6215047322I100043S0g703")
    }

    func testPayWithTransferForwardsPreferredProviderWhenSupplied() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/checkout/pay_with_transfer")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "PayWithTransferResponse")

        _ = try await serviceUnderTest.payWithTransfer(
            fulfilLateNotification: true,
            transactionId: 6215047322,
            preferredProvider: "wema-bank")
    }

    func testCheckPendingChargeSubmitsRequestUsingPaystackObjectAndMapsCorrectlyToModel() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/charge/access_code_test")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "ChargeAuthenticationResponse")

        let result = try await serviceUnderTest.checkPendingCharge(with: "access_code_test")
        XCTAssertEqual(result.status, .success)
    }

    func testListenForTransferResponseSubscribesToProvidedChannelAndMapsSuccess() async throws {
        let channel = "PWT6215047322"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channel, eventName: "response"))
            .andReturnString(fromJson: "PayWithTransferPusherSuccess")

        let result = try await serviceUnderTest.listenForTransferResponse(onChannel: channel)

        XCTAssertEqual(result.status, .success)
        XCTAssertEqual(result.message, "Payment Successful")
        XCTAssertEqual(result.transactionId, "3818017015")
        XCTAssertEqual(result.reference, "T3818017015I615243Sujjxh")
    }

    func testListenForTransferResponseMapsCreditRequestReceivedEvent() async throws {
        let channel = "PWT3818017015"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channel, eventName: "response"))
            .andReturnString(fromJson: "PayWithTransferPusherCreditReceived")

        let result = try await serviceUnderTest.listenForTransferResponse(onChannel: channel)

        XCTAssertEqual(result.status, .creditRequestReceived)
        XCTAssertEqual(result.message, "credit request received")
        XCTAssertEqual(result.transactionId, "3818017015")
    }

    func testListenForTransferResponseMapsCreditRequestPendingEvent() async throws {
        let channel = "PWT3818017015"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channel, eventName: "response"))
            .andReturnString(fromJson: "PayWithTransferPusherCreditPending")

        let result = try await serviceUnderTest.listenForTransferResponse(onChannel: channel)

        XCTAssertEqual(result.status, .creditRequestPending)
    }

    func testListenForTransferResponseMapsCreditRequestRejectedEvent() async throws {
        let channel = "PWT3818017015"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channel, eventName: "response"))
            .andReturnString(fromJson: "PayWithTransferPusherCreditRejected")

        let result = try await serviceUnderTest.listenForTransferResponse(onChannel: channel)

        XCTAssertEqual(result.status, .creditRequestRejected)
        XCTAssertEqual(result.message, "Transfer was rejected")
    }

    /// Under the new taxonomy a bare `status: "failed"` event maps to
    /// `.failed` regardless of the message field — the legacy "failed +
    /// incorrect amount in message → incorrectAmount" fallback is gone.
    /// The explicit `incorrect-amount-sent` status string is what now
    /// signals the refund-initiated wrong-amount case.
    func testListenForTransferResponseMapsBareFailedShapeToFailed() async throws {
        let channel = "PWT3818017015"
        mockSubscriptionListener
            .expectSubscription(PusherSubscription(channelName: channel, eventName: "response"))
            .andReturnString(fromJson: "PayWithTransferPusherIncorrectAmount")

        let result = try await serviceUnderTest.listenForTransferResponse(onChannel: channel)

        XCTAssertEqual(result.status, .failed)
        XCTAssertEqual(result.message, "incorrect amount sent")
    }
}

private extension BankTransferDetails {
    static var jsonExample: BankTransferDetails {
        BankTransferDetails(
            accountName: "PAYSTACK CHECKOUT",
            accountNumber: "9985488398",
            bankName: "Paystack-Titan",
            bankSlug: "titan-paystack",
            transactionReference: "T6215047322I100043S0g703",
            pusherChannel: "PWT6215047322",
            accountExpiresAt: DateFormatter.paystackFormatter
                .date(from: "2026-06-02T15:18:37.053Z")!,
            transactionId: "6215047322")
    }
}
