// swiftlint:disable file_length type_body_length line_length
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

    func testAuthenticateChargeWithOTPAuthentication() throws {
        let otpRequestBody = SubmitOtpRequest(otp: "12345", accessCode: "abcde")

        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/charge/submit_otp")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectBody(otpRequestBody)
            .andReturn(json: "ChargeAuthenticationResponse")

        _ = try serviceUnderTest.authenticateCharge(withOtp: "12345", accessCode: "abcde").sync()
    }

    func testMobileMoneyCharge() throws {
        let mobileMoneyRequestBody = MobileMoneyChargeRequest(channelName: "MOBILE_MONEY_1504248187", phone: "0723362418", transaction: "1504248187", provider: "MPESA")

        mockServiceExecutor
            .expectURL("https://api.paystack.co/charge/mobile_money")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectBody(mobileMoneyRequestBody)
            .andReturn(json: "ChargeMobileMoneyResponse")

        let mobileMoneyData = MobileMoneyData(phone: "0723362418", transaction: "1504248187", provider: "MPESA")

        _ = try serviceUnderTest.chargeMobileMoney(with: mobileMoneyData).sync()
    }

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

    func testAuthenticateChargeWithBirthdayAuthentication() throws {
        let birthdayRequestBody = SubmitBirthdayRequest(birthday: "1990-01-01", accessCode: "abcde")

        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/charge/submit_birthday")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectBody(birthdayRequestBody)
            .andReturn(json: "ChargeAuthenticationResponse")

        guard let birthday = DateFormatter.toDate(usingFormat: "yyyy-MM-dd",
                                                  from: "1990-01-01") else {
            XCTFail("Failed to construct birthday")
            return
        }

        _ = try serviceUnderTest.authenticateCharge(withBirthday: birthday, accessCode: "abcde").sync()
    }

    func testAuthenticateChargeWithAddressAuthentication() throws {
        let address = Address(address: "123 Road", city: "Johannesburg",
                              state: "Gauteng", zipCode: "1234")
        let addressRequestBody = SubmitAddressRequest(address: address,
                                                      accessCode: "abcde")

        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/charge/submit_address")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectBody(addressRequestBody)
            .andReturn(json: "ChargeAuthenticationResponse")

        _ = try serviceUnderTest.authenticateCharge(withAddress: address, accessCode: "abcde").sync()
    }

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

    func testListenForMobileMoney() throws {
        let transactionId = 1234
        let mockSubscription = PusherSubscription(channelName: "MOBILE_MONEY_\(transactionId)",
                                                  eventName: "response")

        // swiftlint:disable:next line_length
        let responseString = "{\"redirecturl\":\"?trxref=2wdckavunc&reference=2wdckavunc\",\"trans\":\"1234\",\"trxref\":\"2wdckavunc\",\"reference\":\"2wdckavunc\",\"status\":\"success\",\"message\":\"Success\",\"response\":\"Approved\"}"

        mockSubscriptionListener
            .expectSubscription(mockSubscription)
            .andReturnString(responseString)

        _ = try serviceUnderTest.listenForMobileMoneyResponse(for: transactionId).sync()
    }

}
// swiftlint:enable file_length type_body_length line_length
