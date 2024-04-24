import XCTest
@testable import PaystackCore

final class ChargeTests: PSTestCase {

    let apiKey = "testsk_Example"

    var serviceUnderTest: Paystack!

    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceUnderTest = try PaystackBuilder.newInstance
            .setKey(apiKey)
            .build()
    }

    //TODO: testAuthenticateChargeWithOTPAuthentication
    
    func testAuthenticateChargeWithPhoneAuthentication() throws {
        let phoneRequestBody = SubmitPhoneRequest(phone: "0111234567", accessCode: "abcde")

        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/charge/submit_phone")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectBody(phoneRequestBody)
            .andReturn(json: "ChargeAuthenticationResponse")

        _ = try serviceUnderTest.authenticateCharge(withPhone: "0111234567", accessCode: "abcde").sync()
    }
    
    //TODO: Add Test for testAuthenticateChargeWithBirthdayAuthentication
    
    //TODO: Add test for testAuthenticateChargeWithAddressAuthentication

    func testListenFor3DS() throws {
        let transactionId = 1234
        let mockSubscription = PusherSubscription(channelName: "3DS_\(transactionId)",
                                                  eventName: "response")

        // swiftlint:disable:next line_length
        let responseString = "{\"redirecturl\":\"?trxref=2wdckavunc&reference=2wdckavunc\",\"trans\":\"1234\",\"trxref\":\"2wdckavunc\",\"reference\":\"2wdckavunc\",\"status\":\"success\",\"message\":\"Success\",\"response\":\"Approved\"}"

        mockSubscriptionListener
            .expectSubscription(mockSubscription)
            .andReturnString(responseString)

        _ = try serviceUnderTest.listenFor3DSResponse(for: transactionId).sync()
    }

}
