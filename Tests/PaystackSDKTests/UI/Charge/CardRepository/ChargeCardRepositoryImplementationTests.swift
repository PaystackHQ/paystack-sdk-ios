import XCTest
@testable import PaystackCore
@testable import PaystackUI

final class ChargeCardRepositoryImplementationTests: PSTestCase {

    let apiKey = "testsk_Example"
    var serviceUnderTest: ChargeCardRepositoryImplementation!
    var paystack: Paystack!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paystack = try PaystackBuilder.newInstance.setKey(apiKey).build()
        PaystackContainer.instance.store(paystack)
        serviceUnderTest = ChargeCardRepositoryImplementation()
    }

    // TODO: Add test for testSubmitBirthdaySubmitsRequestUsingPaystackObjectAndMapsCorrectlyToModel

    // TODO: testSubmitPhoneSubmitsRequestUsingPaystackObjectAndMapsCorrectlyToModel

    // TODO: Add Test for testSubmitOTPSubmitsRequestUsingPaystackObjectAndMapsCorrectlyToModel

    // TODO: Add Test for testSubmitAddressSubmitsRequestUsingPaystackObjectAndMapsCorrectlyToModel

    func testCheckPendingChargeSubmitsRequestUsingPaystackObjectAndMapsCorrectlyToModel() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/charge/access_code_test")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "ChargeAuthenticationResponse")

        let result = try await serviceUnderTest.checkPendingCharge(with: "access_code_test")
        XCTAssertEqual(result, .jsonExample)
    }

    func testListenFor3DSResponseListensUsingThePaystackObjectAndMapsCorrectlyToModel() async throws {
        let transactionId = 1234
        let mockSubscription = PusherSubscription(channelName: "3DS_\(transactionId)",
                                                  eventName: "response")

        // swiftlint:disable:next line_length
        let responseString = "{\"redirecturl\":\"?trxref=2wdckavunc&reference=2wdckavunc\",\"trans\":\"1234\",\"trxref\":\"2wdckavunc\",\"reference\":\"2wdckavunc\",\"status\":\"success\",\"message\":\"Success\",\"response\":\"Approved\"}"

        mockSubscriptionListener
            .expectSubscription(mockSubscription)
            .andReturnString(responseString)

        let result = try await serviceUnderTest.listenFor3DS(for: transactionId)
        XCTAssertEqual(result, .init(status: .success))
    }

    func testGetAddressStatesSubmitsRequestUsingPaystackObjectAndMapsCorrectlyToStringArray() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/address_verification/states?country=US")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "AddressStatesResponse")

        let result = try await serviceUnderTest.getAddressStates(for: "US")
        let firstThreeStatesFromResult = result.prefix(3)
        XCTAssertEqual(firstThreeStatesFromResult, ["Alaska", "Alabama", "Arkansas"])
    }

}

// MARK: - ChargeCardTransaction Based off Json result
private extension ChargeCardTransaction {
    static var jsonExample: ChargeCardTransaction {
        ChargeCardTransaction(status: .success,
                              message: "madePayment",
                              countryCode: "NG")
    }
}
