import Foundation
import PaystackCore

class MobileMoneyProcessingViewModel: ObservableObject {

    var container: MobileMoneyContainer
    var repository: ChargeMobileMoneyRepository
    let mobileMoneyTransaction: MobileMoneyTransaction
    @Published
    var counter = 0

    init(container: MobileMoneyContainer,
         mobileMoneyTransaction: MobileMoneyTransaction,
         repository: ChargeMobileMoneyRepository = ChargeMobileMoneyRepositoryImplementation()) {
        self.container = container
        self.repository = repository
        self.mobileMoneyTransaction = mobileMoneyTransaction
    }

    var transactionDetails: VerifyAccessCode {
        container.transactionDetails
    }

    var authorizationPromptText: String {
        if !mobileMoneyTransaction.message.isEmpty {
            return mobileMoneyTransaction.message
        }
        return "Please authorize the payment with \(container.provider.value) on your phone"
    }

    func checkTransactionStatus() {
        Task {
            await checkPendingCharge()
        }
    }

    @MainActor
    func initializeMobileMoneyAuthorization() async {
        do {
            let authenticationResult = try await repository.listenForMobileMoneyResponse(
                for: Int(mobileMoneyTransaction.transaction) ?? 0)
            await container.processTransactionResponse(authenticationResult)
        } catch {
            Logger.error("Listening for mobile money transaction failed with error: %@",
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
            Logger.error("Checking pending mobile money charge failed with error: %@",
                         arguments: error.localizedDescription)
            container.displayTransactionError(ChargeError(error: error))
        }
    }

    func cancelTransaction() {
        container.restartMobileMoneyPayment()
    }

}
