import Foundation
import Paystack

protocol TransactionService: PaystackService {
    func initialize(_ request: InitializeTransactionRequest) -> ServiceResponse<InitializedTransaction>
    func verify(_ reference: String) -> ServiceResponse<Transaction>
    func list(_ queries: [ListTransactionQuery]) -> ServiceResponse<[Transaction]>
    func get(_ id: Int) -> ServiceResponse<Transaction>
    func chargeAuthorization(_ request: ChargeAuthorizationRequest) -> ServiceResponse<Transaction>
    func checkAuthorization(_ request: CheckAuthorizationRequest) -> ServiceResponse<Amount>
    func getTimeline(_ idOrReference: String) -> ServiceResponse<TransactionTimeline>
    func getTotals(_ queries: [TransactionTotalsQuery]) -> ServiceResponse<TransactionTotals>
    func export(_ queries: [ExportTransactionsQuery]) -> ServiceResponse<TransactionExportPath>
    func partialDebit(_ request: PartialDebitRequest) -> ServiceResponse<Transaction>
}

struct TransactionServiceImplementation: TransactionService {
    
    var config: PaystackConfig
    
    var parentPath: String {
        return "transaction"
    }
    
    func initialize(_ request: InitializeTransactionRequest) -> ServiceResponse<InitializedTransaction> {
        return post("/initialize", request)
            .asService()
    }
    
    func verify(_ reference: String) -> ServiceResponse<Transaction> {
        return get("/verify/\(reference)")
            .asService()
    }
    
    func list(_ queries: [ListTransactionQuery]) -> ServiceResponse<[Transaction]> {
        return get()
            .setQueryItems(queries.keyPairs)
            .asService()
    }
    
    func get(_ id: Int) -> ServiceResponse<Transaction> {
        return get("/\(id)")
            .asService()
    }
    
    func chargeAuthorization(_ request: ChargeAuthorizationRequest) -> ServiceResponse<Transaction> {
        return post("/charge_authorization", request)
            .asService()
    }
    
    func checkAuthorization(_ request: CheckAuthorizationRequest) -> ServiceResponse<Amount> {
        return post("/check_authorization", request)
            .asService()
    }
    
    func getTimeline(_ idOrReference: String) -> ServiceResponse<TransactionTimeline> {
        return get("/timeline/\(idOrReference)")
            .asService()
    }
    
    func getTotals(_ queries: [TransactionTotalsQuery]) -> ServiceResponse<TransactionTotals> {
        return get("/totals")
            .setQueryItems(queries.keyPairs)
            .asService()
    }
    
    func export(_ queries: [ExportTransactionsQuery]) -> ServiceResponse<TransactionExportPath> {
        return get("/export")
            .setQueryItems(queries.keyPairs)
            .asService()
    }
    
    func partialDebit(_ request: PartialDebitRequest) -> ServiceResponse<Transaction> {
        return post("/partial_debit", request)
            .asService()
    }
    
}
