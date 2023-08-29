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

    func testSubmitBirthdaySubmitsRequestUsingPaystackObjectAndMapsCorrectlyToModel() async throws {
        let birthdayRequestBody = SubmitBirthdayRequest(birthday: "1990-01-01",
                                                        accessCode: "test_access")

        mockServiceExecutor
            .expectURL("https://api.paystack.co/charge/submit_birthday")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectBody(birthdayRequestBody)
            .andReturn(json: "ChargeAuthenticationResponse")

        let result = try await serviceUnderTest.submitBirthday("1990-01-01",
                                                               accessCode: "test_access")
        XCTAssertEqual(result, .jsonExample)
    }

    func testSubmitPhoneSubmitsRequestUsingPaystackObjectAndMapsCorrectlyToModel() async throws {
        let phoneRequestBody = SubmitPhoneRequest(phone: "0111234567", accessCode: "test_access")

        mockServiceExecutor
            .expectURL("https://api.paystack.co/charge/submit_phone")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectBody(phoneRequestBody)
            .andReturn(json: "ChargeAuthenticationResponse")

        let result = try await serviceUnderTest.submitPhone("0111234567",
                                                            accessCode: "test_access")
        XCTAssertEqual(result, .jsonExample)
    }

    func testSubmitOTPSubmitsRequestUsingPaystackObjectAndMapsCorrectlyToModel() async throws {
        let otpRequestBody = SubmitOtpRequest(otp: "12345", accessCode: "test_access")

        mockServiceExecutor
            .expectURL("https://api.paystack.co/charge/submit_otp")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectBody(otpRequestBody)
            .andReturn(json: "ChargeAuthenticationResponse")

        let result = try await serviceUnderTest.submitOTP("12345", accessCode: "test_access")
        XCTAssertEqual(result, .jsonExample)
    }

    func testSubmitPinSubmitsRequestUsingPaystackObjectAndMapsCorrectlyToModel() async throws {
        let pinRequestBody = SubmitPinRequest(pin: "123456", accessCode: "test_access")

        mockServiceExecutor
            .expectURL("https://api.paystack.co/charge/submit_pin")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectBody(pinRequestBody)
            .andReturn(json: "ChargeAuthenticationResponse")

        let result = try await serviceUnderTest.submitPin("123456", accessCode: "test_access")
        XCTAssertEqual(result, .jsonExample)
    }

    func testSubmitAddressSubmitsRequestUsingPaystackObjectAndMapsCorrectlyToModel() async throws {
        let address = Address(address: "123 Road", city: "Johannesburg",
                              state: "Gauteng", zipCode: "1234")
        let addressRequestBody = SubmitAddressRequest(address: address,
                                                      accessCode: "test_access")

        mockServiceExecutor
            .expectURL("https://api.paystack.co/charge/submit_address")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectBody(addressRequestBody)
            .andReturn(json: "ChargeAuthenticationResponse")

        let result = try await serviceUnderTest.submitAddress(address, accessCode: "test_access")
        XCTAssertEqual(result, .jsonExample)
    }

}

// MARK: - ChargeCardTransaction Based off Json result
private extension ChargeCardTransaction {
    static var jsonExample: ChargeCardTransaction {
        ChargeCardTransaction(status: .success,
                              customerPhone: "+27123456789",
                              countryCode: "NG")
    }
}
