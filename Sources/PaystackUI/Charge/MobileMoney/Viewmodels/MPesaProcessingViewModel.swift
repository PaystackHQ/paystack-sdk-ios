import Foundation
import PaystackCore

class MPesaProcessingViewModel: ObservableObject {

    var container: MPesaContainer
    var repository: ChargeMobileMoneyRepository
    let mobileMoneyTransaction: MobileMoneyTransaction
    @Published
    var counter = 0

    init(container: MPesaContainer,
         mobileMoneyTransaction: MobileMoneyTransaction,
         repository: ChargeMobileMoneyRepository = ChargeMobileMoneyRepositoryImplementation()) {
        self.container = container
        self.repository = repository
        self.mobileMoneyTransaction = mobileMoneyTransaction
    }

    var transactionDetails: VerifyAccessCode {
        container.transactionDetails
    }

    func checkTransactionStatus() {
        Task {
            await checkPendingCharge()
        }
    }

    @MainActor
    func initializeMPesaAuthorization() async {
        do {
            let authenticationResult = try await repository.listenForMPesa(
                for: Int(mobileMoneyTransaction.transaction) ?? 0)
            await container.processTransactionResponse(authenticationResult)
        } catch {
            Logger.error("Listening for M-Pesa transaction failed with error: %@",
                         arguments: error.localizedDescription)
            container.displayTransactionError(ChargeError(error: error))
        }
    }

    @MainActor
    private func checkPendingCharge() async {
        do {
            let authenticationResult = try await repository.checkPendingCharge(
                with: transactionDetails.accessCode)
            await container.processTransactionResponse(authenticationResult)
        } catch {
            Logger.error("Checking pending M-Pesa charge failed with error: %@",
                         arguments: error.localizedDescription)
            container.displayTransactionError(ChargeError(error: error))
        }
    }

    func cancelTransaction() {
        container.restartMPesaPayment()
    }

}
