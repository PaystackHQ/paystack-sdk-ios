import Foundation
import PaystackCore
@testable import PaystackUI

class MockChargeCardRepository: ChargeCardRepository {

    var expectedChargeCardTransaction: ChargeCardTransaction?
    var expectedAddressStates: [String]?
    var expectedErrorResponse: Error?

    var cardDetailsSubmitted: (card: CardCharge?, accessCode: String,
                               publicEncryptionKey: String) = (nil, "", "")
    var birthdaySubmitted: (birthday: Date?, accessCode: String) = (nil, "")
    var phoneSubmitted: (phone: String, accessCode: String) = ("", "")
    var otpSubmitted: (otp: String, accessCode: String) = ("", "")
    var addressSubmitted: (address: Address?, accessCode: String) = (nil, "")
    var pinSubmitted: (pin: String, accessCode: String,
                       publicEncryptionKey: String) = ("", "", "")
    var redirectTranactionId: Int?
    var pendingChargeAccessCode: String?

    func submitCardDetails(_ card: CardCharge, publicEncryptionKey: String,
                           accessCode: String) async throws -> ChargeCardTransaction {
        cardDetailsSubmitted = (card, accessCode, publicEncryptionKey)
        return try await mockedResponse()
    }

    func submitBirthday(_ birthday: Date, accessCode: String) async throws -> ChargeCardTransaction {
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

    func submitAddress(_ address: Address, accessCode: String) async throws -> ChargeCardTransaction {
        addressSubmitted = (address, accessCode)
        return try await mockedResponse()
    }

    func submitPin(_ pin: String, publicEncryptionKey: String,
                   accessCode: String) async throws -> ChargeCardTransaction {
        pinSubmitted = (pin, accessCode, publicEncryptionKey)
        return try await mockedResponse()
    }

    func getAddressStates(for countryCode: String) async throws -> [String] {
        guard let expectedAddressStates else {
            throw expectedErrorResponse ?? MockError.stubNotProvided
        }
        return expectedAddressStates
    }

    func listenFor3DS(for transactionId: Int) async throws -> ChargeCardTransaction {
        self.redirectTranactionId = transactionId
        return try await mockedResponse()
    }

    func checkPendingCharge(with accessCode: String) async throws -> ChargeCardTransaction {
        pendingChargeAccessCode = accessCode
        return try await mockedResponse()
    }

    private func mockedResponse() async throws -> ChargeCardTransaction {
        guard let response = expectedChargeCardTransaction else {
            throw expectedErrorResponse ?? MockError.stubNotProvided
        }
        return response
    }

}
