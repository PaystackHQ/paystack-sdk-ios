import Foundation
class MPesaProcessingViewModel: ObservableObject {

    var chargeCardContainer: ChargeContainer
    var repository: ChargeMobileMoneyRepository
    var transactionDetails: VerifyAccessCode
    let mobileMoneyTransaction: MobileMoneyTransaction
    @Published
    var counter = 0

    init(transactionDetails: VerifyAccessCode,
         chargeCardContainer: ChargeContainer,
         mobileMoneyTransaction: MobileMoneyTransaction,
         repository: ChargeMobileMoneyRepository = ChargeMobileMoneyRepositoryImplementation()) {
        self.transactionDetails = transactionDetails
        self.chargeCardContainer = chargeCardContainer
        self.repository = repository
        self.mobileMoneyTransaction = mobileMoneyTransaction
    }

    func checkTransactionStatus() {
        Task {
            await checkPendingCharge()
        }
    }

    @MainActor
    func initializeMPesaAuthorization() async {
        do {
            let authenticationResult = try await repository.listenForMPesa(for: Int( mobileMoneyTransaction.transaction) ?? 0)

            if authenticationResult.status == .success {
                chargeCardContainer.processSuccessfulTransaction(details: transactionDetails)
            } else {
                print(authenticationResult.status.rawValue)
            }
        } catch {
            let error = ChargeError(error: error)
            //chargeCardContainer.displayTransactionError(error)
        }
    }

    @MainActor
    private func checkPendingCharge() async {
        do {
            // chargeCardState = .loading(message: "Checking transaction status")
            // try await Task.sleep(nanoseconds: checkPendingChargeDelay)
            let authenticationResult = try await repository.checkPendingCharge(
                with: transactionDetails.accessCode)
            if authenticationResult.status == .success {
                chargeCardContainer.processSuccessfulTransaction(details: transactionDetails)
            }
        } catch {
            let error = ChargeError(error: error)
            // displayTransactionError(error)
        }
    }

    func cancelTransaction() {
        // chargeCardContainer.restartCardPayment()
    }

}
