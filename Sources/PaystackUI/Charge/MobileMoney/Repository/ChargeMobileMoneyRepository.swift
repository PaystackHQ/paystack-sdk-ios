import Foundation
import PaystackCore

protocol ChargeMobileMoneyRepository {
    func chargeMobileMoney(phone: String, transactionId: String, provider: String) async throws -> MobileMoneyTransaction
    func listenForMPesa(for transactionId: Int) async throws -> ChargeCardTransaction
    func checkPendingCharge(with accessCode: String) async throws -> ChargeCardTransaction
}

struct ChargeMobileMoneyRepositoryImplementation: ChargeMobileMoneyRepository {

    let paystack: Paystack

    init() {
        self.paystack = PaystackContainer.instance.retrieve()
    }

    func chargeMobileMoney(phone: String, transactionId: String, provider: String) async throws -> MobileMoneyTransaction {
        let request = MobileMoneyData(phone: phone, transaction: transactionId, provider: provider)
        let response = try await paystack.chargeMobileMoney(with: request).async()
        return MobileMoneyTransaction.from(response)
    }

    func listenForMPesa(for transactionId: Int) async throws -> ChargeCardTransaction {
        let response = try await paystack.listenForMobileMoneyResponse(for: transactionId).async()
        return ChargeCardTransaction.from(response)
    }

    func checkPendingCharge(with accessCode: String) async throws -> ChargeCardTransaction {
        let response = try await paystack.checkPendingCharge(forAccessCode: accessCode).async()
        return ChargeCardTransaction.from(response)
    }
}
