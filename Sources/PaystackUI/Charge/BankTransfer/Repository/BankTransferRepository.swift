import Foundation
import PaystackCore

protocol BankTransferRepository {
    func payWithTransfer(fulfilLateNotification: Bool,
                         transactionId: Int,
                         preferredProvider: String?) async throws -> BankTransferDetails

    func checkPendingCharge(with accessCode: String) async throws -> ChargeCardTransaction

    func listenForTransferResponse(onChannel channelName: String)
        async throws -> BankTransferTransactionUpdate
}

struct BankTransferRepositoryImplementation: BankTransferRepository {

    let paystack: Paystack

    init() {
        self.paystack = PaystackContainer.instance.retrieve()
    }

    func payWithTransfer(fulfilLateNotification: Bool,
                         transactionId: Int,
                         preferredProvider: String?) async throws -> BankTransferDetails {
        let request = PayWithTransferRequest(
            fulfilLateNotification: fulfilLateNotification,
            transactionId: transactionId,
            preferredProvider: preferredProvider)
        let response = try await paystack.payWithTransfer(request).async()
        return BankTransferDetails.from(response)
    }

    func checkPendingCharge(with accessCode: String) async throws -> ChargeCardTransaction {
        let response = try await paystack.checkPendingCharge(forAccessCode: accessCode).async()
        return ChargeCardTransaction.from(response)
    }

    func listenForTransferResponse(onChannel channelName: String)
        async throws -> BankTransferTransactionUpdate {
        let response = try await paystack
            .listenForTransferResponse(onChannel: channelName).async()
        return BankTransferTransactionUpdate.from(response)
    }
}
