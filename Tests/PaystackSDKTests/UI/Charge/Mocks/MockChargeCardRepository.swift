import Foundation
import PaystackCore
@testable import PaystackUI

class MockChargeCardRepository: ChargeCardRepository {

    var expectedChargeCardTransaction: ChargeCardTransaction?
    var expectedErrorResponse: Error?

    var birthdaySubmitted: (birthday: String, accessCode: String) = ("", "")
    var phoneSubmitted: (phone: String, accessCode: String) = ("", "")
    var otpSubmitted: (otp: String, accessCode: String) = ("", "")

    func submitBirthday(_ birthday: String, accessCode: String) async throws -> ChargeCardTransaction {
        birthdaySubmitted = (birthday, accessCode)
        return try await mockedResponse()
    }

    func submitPhone(_ phone: String, accessCode: String) async throws -> PaystackUI.ChargeCardTransaction {
        phoneSubmitted = (phone, accessCode)
        return try await mockedResponse()
    }

    func submitOTP(_ otp: String, accessCode: String) async throws -> PaystackUI.ChargeCardTransaction {
        otpSubmitted = (otp, accessCode)
        return try await mockedResponse()
    }

    private func mockedResponse() async throws -> ChargeCardTransaction {
        guard let response = expectedChargeCardTransaction else {
            throw expectedErrorResponse ?? MockError.stubNotProvided
        }
        return response
    }

}
