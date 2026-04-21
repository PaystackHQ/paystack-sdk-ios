import XCTest
@testable import PaystackCore
@testable import PaystackUI

final class ChargeMobileMoneyRepositoryImplementationTests: PSTestCase {

    let apiKey = "testsk_Example"
    var serviceUnderTest: ChargeMobileMoneyRepositoryImplementation!
    var paystack: Paystack!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paystack = try PaystackBuilder.newInstance.setKey(apiKey).build()
        PaystackContainer.instance.store(paystack)
        serviceUnderTest = ChargeMobileMoneyRepositoryImplementation()
    }

    func testChargeMobileMoneySubmitsRequestUsingPaystackObjectAndMapsCorrectlyToModel() async throws {
        let transactionId = "1504248187"

        mockServiceExecutor
            .expectURL("https://api.paystack.co/charge/mobile_money")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "ChargeMobileMoneyResponse")

        let result = try await serviceUnderTest.chargeMobileMoney(phone: "0703362111",
                                                                  transactionId: transactionId,
                                                                  provider: "MPESA")
        XCTAssertEqual(result, .jsonExample)
    }

    func testListenForMPesaSubscribesToMobileMoneyChannelAndMapsSuccessToSuccess() async throws {
        let transactionId = 1234
        let mockSubscription = PusherSubscription(channelName: "MOBILE_MONEY_\(transactionId)",
                                                  eventName: "response")
        // swiftlint:disable:next line_length
        let responseString = "{\"redirecturl\":\"?trxref=2wdckavunc&reference=2wdckavunc\",\"trans\":\"1234\",\"trxref\":\"2wdckavunc\",\"reference\":\"2wdckavunc\",\"status\":\"success\",\"message\":\"Success\",\"response\":\"Approved\"}"

        mockSubscriptionListener
            .expectSubscription(mockSubscription)
            .andReturnString(responseString)

        let result = try await serviceUnderTest.listenForMPesa(for: transactionId)
        XCTAssertEqual(result, .init(status: .success))
    }

    func testListenForMPesaMapsFailedSubscriptionResponseToFailedStatus() async throws {
        let transactionId = 4321
        let mockSubscription = PusherSubscription(channelName: "MOBILE_MONEY_\(transactionId)",
                                                  eventName: "response")
        // swiftlint:disable:next line_length
        let responseString = "{\"redirecturl\":\"?trxref=ref&reference=ref\",\"trans\":\"4321\",\"trxref\":\"ref\",\"reference\":\"ref\",\"status\":\"failed\",\"message\":\"Declined\",\"response\":\"Declined\"}"

        mockSubscriptionListener
            .expectSubscription(mockSubscription)
            .andReturnString(responseString)

        let result = try await serviceUnderTest.listenForMPesa(for: transactionId)
        XCTAssertEqual(result, .init(status: .failed))
    }

    func testCheckPendingChargeSubmitsRequestUsingPaystackObjectAndMapsCorrectlyToModel() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/charge/access_code_test")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "ChargeAuthenticationResponse")

        let result = try await serviceUnderTest.checkPendingCharge(with: "access_code_test")
        XCTAssertEqual(result, .jsonExample)
    }
}

// MARK: - Expected response models

private extension MobileMoneyTransaction {
    static var jsonExample: MobileMoneyTransaction {
        MobileMoneyTransaction(transaction: "1504248187",
                               phone: "0703362111",
                               provider: "MPESA",
                               channelName: "MOBILE_MONEY_1504248187",
                               timer: 60,
                               message: "Please complete authorization process on your mobile phone")
    }
}

private extension ChargeCardTransaction {
    static var jsonExample: ChargeCardTransaction {
        ChargeCardTransaction(status: .success,
                              message: "madePayment",
                              countryCode: "NG")
    }
}
