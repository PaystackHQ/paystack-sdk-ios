import Foundation
@testable import PaystackUI

class MockChargeMobileMoneyRepository: ChargeMobileMoneyRepository {

    var expectedMobileMoneyTransaction: MobileMoneyTransaction?
    var expectedChargeCardTransaction: ChargeCardTransaction?
    var expectedErrorResponse: Error?

    var chargeMobileMoneySubmitted: (phone: String, transactionId: String,
                                     provider: String) = ("", "", "")
    var listenForMPesaTransactionId: Int?
    var pendingChargeAccessCode: String?

    func chargeMobileMoney(phone: String, transactionId: String,
                           provider: String) async throws -> MobileMoneyTransaction {
        chargeMobileMoneySubmitted = (phone, transactionId, provider)
        guard let response = expectedMobileMoneyTransaction else {
            throw expectedErrorResponse ?? MockError.stubNotProvided
        }
        return response
    }

    func listenForMPesa(for transactionId: Int) async throws -> ChargeCardTransaction {
        listenForMPesaTransactionId = transactionId
        guard let response = expectedChargeCardTransaction else {
            throw expectedErrorResponse ?? MockError.stubNotProvided
        }
        return response
    }

    func checkPendingCharge(with accessCode: String) async throws -> ChargeCardTransaction {
        pendingChargeAccessCode = accessCode
        guard let response = expectedChargeCardTransaction else {
            throw expectedErrorResponse ?? MockError.stubNotProvided
        }
        return response
    }
}
