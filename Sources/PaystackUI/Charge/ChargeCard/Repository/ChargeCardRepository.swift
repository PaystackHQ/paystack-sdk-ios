import Foundation
import PaystackCore

protocol ChargeCardRepository {
    func submitCardDetails(_ card: CardCharge, publicEncryptionKey: String,
                           accessCode: String) async throws -> ChargeCardTransaction
    func submitBirthday(_ birthday: Date, accessCode: String) async throws -> ChargeCardTransaction
    func submitPhone(_ phone: String, accessCode: String) async throws -> ChargeCardTransaction
    func submitOTP(_ otp: String, accessCode: String) async throws -> ChargeCardTransaction
    func submitAddress(_ address: Address, accessCode: String) async throws -> ChargeCardTransaction
    func submitPin(_ pin: String, publicEncryptionKey: String,
                   accessCode: String) async throws -> ChargeCardTransaction
    func getAddressStates(for countryCode: String) async throws -> [String]
    func listenFor3DS(for transactionId: Int) async throws -> ChargeCardTransaction
    func checkPendingCharge(with accessCode: String) async throws -> ChargeCardTransaction
}
