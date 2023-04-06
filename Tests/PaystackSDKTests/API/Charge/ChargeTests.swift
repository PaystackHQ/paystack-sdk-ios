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
        let otpRequestBody = SubmitOtpRequest(otp: "12345", reference: "abcde")

        mockServiceExecutor
            .expectURL("https://api.paystack.co/charge/submit_otp")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectBody(otpRequestBody)
            .andReturn(json: "ChargeAuthenticationResponse")

        _ = try serviceUnderTest.authenticateCharge(.otp(otpRequestBody)).sync()
    }

    func testAuthenticateChargeWithPinAuthentication() throws {
        let pinRequestBody = SubmitPinRequest(pin: "1234", reference: "abcde")

        mockServiceExecutor
            .expectURL("https://api.paystack.co/charge/submit_pin")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectBody(pinRequestBody)
            .andReturn(json: "ChargeAuthenticationResponse")

        _ = try serviceUnderTest.authenticateCharge(.pin(pinRequestBody)).sync()
    }

    func testAuthenticateChargeWithPhoneAuthentication() throws {
        let phoneRequestBody = SubmitPhoneRequest(phone: "0111234567", reference: "abcde")

        mockServiceExecutor
            .expectURL("https://api.paystack.co/charge/submit_phone")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectBody(phoneRequestBody)
            .andReturn(json: "ChargeAuthenticationResponse")

        _ = try serviceUnderTest.authenticateCharge(.phone(phoneRequestBody)).sync()
    }

    func testAuthenticateChargeWithBirthdayAuthentication() throws {
        let birthdayRequestBody = SubmitBirthdayRequest(birthday: "1990-01-01", reference: "abcde")

        mockServiceExecutor
            .expectURL("https://api.paystack.co/charge/submit_birthday")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectBody(birthdayRequestBody)
            .andReturn(json: "ChargeAuthenticationResponse")

        _ = try serviceUnderTest.authenticateCharge(.birthday(birthdayRequestBody)).sync()
    }

    func testAuthenticateChargeWithAddressAuthentication() throws {
        let addressRequestBody = SubmitAddressRequest(address: "123 Road",
                                                      city: "Johannesburg",
                                                      state: "Gauteng",
                                                      zipCode: "1234",
                                                      reference: "abcde")

        mockServiceExecutor
            .expectURL("https://api.paystack.co/charge/submit_address")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectBody(addressRequestBody)
            .andReturn(json: "ChargeAuthenticationResponse")

        _ = try serviceUnderTest.authenticateCharge(.address(addressRequestBody)).sync()
    }

}
