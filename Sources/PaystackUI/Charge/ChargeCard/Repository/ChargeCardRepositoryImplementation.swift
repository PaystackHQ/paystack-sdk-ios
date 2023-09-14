import Foundation
import PaystackCore

struct ChargeCardRepositoryImplementation: ChargeCardRepository {

    let paystack: Paystack

    init() {
        self.paystack = PaystackContainer.instance.retrieve()
    }

    func submitCardDetails(_ card: CardCharge, publicEncryptionKey: String,
                           accessCode: String) async throws -> ChargeCardTransaction {
        let response = try await paystack.chargeCard(card,
                                                     publicEncryptionKey: publicEncryptionKey,
                                                     accessCode: accessCode).async()
        return ChargeCardTransaction.from(response)
    }

    func submitBirthday(_ birthday: Date, accessCode: String) async throws -> ChargeCardTransaction {
        let response = try await paystack.authenticateCharge(withBirthday: birthday,
                                                             accessCode: accessCode).async()
        return ChargeCardTransaction.from(response)
    }

    func submitPhone(_ phone: String, accessCode: String) async throws -> ChargeCardTransaction {
        let response = try await paystack.authenticateCharge(withPhone: phone,
                                                             accessCode: accessCode).async()
        return ChargeCardTransaction.from(response)
    }

    func submitOTP(_ otp: String, accessCode: String) async throws -> ChargeCardTransaction {
        let response = try await paystack.authenticateCharge(withOtp: otp,
                                                             accessCode: accessCode).async()
        return ChargeCardTransaction.from(response)
    }

    func submitAddress(_ address: Address, accessCode: String) async throws -> ChargeCardTransaction {
        let response = try await paystack.authenticateCharge(withAddress: address,
                                                             accessCode: accessCode).async()
        return ChargeCardTransaction.from(response)
    }

    func submitPin(_ pin: String, publicEncryptionKey: String,
                   accessCode: String) async throws -> ChargeCardTransaction {
        let response = try await paystack.authenticateCharge(withPin: pin,
                                                             publicEncryptionKey: publicEncryptionKey,
                                                             accessCode: accessCode).async()
        return ChargeCardTransaction.from(response)
    }

    func getAddressStates(for countryCode: String) async throws -> [String] {
        let response = try await paystack.addressStates(for: countryCode).async()
        let states = response.data.compactMap { $0.name }
        return states
    }

    func listenFor3DS(for transactionId: Int) async throws -> ChargeCardTransaction {
        let response = try await paystack.listenFor3DSResponse(for: transactionId).async()
        return ChargeCardTransaction.from(response)
    }

    func checkPendingCharge(with accessCode: String) async throws -> ChargeCardTransaction {
        let response = try await paystack.checkPendingCharge(forAccessCode: accessCode).async()
        return ChargeCardTransaction.from(response)
    }
}
