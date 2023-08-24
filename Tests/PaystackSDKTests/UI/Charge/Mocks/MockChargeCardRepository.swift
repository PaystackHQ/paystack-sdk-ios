import Foundation
import PaystackCore
@testable import PaystackUI

class MockChargeCardRepository: ChargeCardRepository {

    var expectedChargeCardTransaction: ChargeCardTransaction?
    var expectedErrorResponse: Error?

    var birthdaySubmitted: (birthday: String, accessCode: String) = ("", "")

    func submitBirthday(_ birthday: String, accessCode: String) async throws -> ChargeCardTransaction {
        birthdaySubmitted = (birthday, accessCode)
        return try await mockedResponse()
    }

    private func mockedResponse() async throws -> ChargeCardTransaction {
        guard let response = expectedChargeCardTransaction else {
            throw expectedErrorResponse ?? MockError.stubNotProvided
        }
        return response
    }

}
