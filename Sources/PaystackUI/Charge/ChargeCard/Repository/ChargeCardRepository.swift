import PaystackCore

protocol ChargeCardRepository {
    func submitCardDetails(_ card: CardCharge, publicEncryptionKey: String,
                           accessCode: String) async throws -> ChargeCardTransaction
    func submitBirthday(_ birthday: String, accessCode: String) async throws -> ChargeCardTransaction
    func submitPhone(_ phone: String, accessCode: String) async throws -> ChargeCardTransaction
    func submitOTP(_ otp: String, accessCode: String) async throws -> ChargeCardTransaction
    func submitAddress(_ address: Address, accessCode: String) async throws -> ChargeCardTransaction
    func submitPin(_ pin: String, accessCode: String) async throws -> ChargeCardTransaction
}
