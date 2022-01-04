import Foundation
import Paystack

/// The Transactions API allows you create and manage payments on your integration.
public extension Paystack {
    
    private var service: TransactionService {
        return TransactionServiceImplementation(config: config)
    }
    
    /// Initialize a transaction from your app.
    /// - Parameter request: Request for initializing transaction.
    /// - Returns: Response of the initialized transaction.
    func initializeTransaction(_ request: InitializeTransactionRequest) -> ServiceResponse<InitializedTransaction> {
        return service.initialize(request)
    }
    
    /// Confirm the status of a transaction.
    /// - Parameter reference: The transaction reference used to intiate the transaction.
    /// - Returns: Response of the transaction being verified.
    func verifyTransaction(_ reference: String) -> ServiceResponse<Transaction> {
        return service.verify(reference)
    }
    
    /// List transactions carried out on your integration.
    /// - Parameter queries: Query params to customize the response.
    /// - Returns: Response of transactions.
    func listTransactions(_ queries: ListTransactionQuery...) -> ServiceResponse<[Transaction]> {
        return service.list(queries)
    }
    
    /// Get details of a transaction carried out on your integration.
    /// - Parameter id: An ID for the transaction to fetch.
    /// - Returns: Response of transaction being fetched.
    func fetchTransaction(_ id: Int) -> ServiceResponse<Transaction> {
        return service.get(id)
    }
    
    /// All authorizations marked as reusable can be charged with this endpoint whenever you need to
    /// receive payments.
    /// - Parameter request: Request for charging authorization.
    /// - Returns: Response of transaction for charged authorization.
    func chargeAuthorization(_ request: ChargeAuthorizationRequest) -> ServiceResponse<Transaction> {
        return service.chargeAuthorization(request)
    }
    
    /// All Mastercard and Visa authorizations can be checked with this endpoint to know if they have
    /// funds for the payment you seek.
    ///
    /// This endpoint should be used when you do not know the exact amount to charge a card when
    /// rendering a service. It should be used to check if a card has enough funds based on a maximum
    /// range value. It is well suited for:
    ///  * Ride hailing services
    ///  * Logistics services
    /// - Parameter request: Request for checking authorization.
    /// - Returns: Response of amount for authorization.
    func checkAuthorization(_ request: CheckAuthorizationRequest) -> ServiceResponse<Amount> {
        return service.checkAuthorization(request)
    }
    
    /// View the timeline of a transaction.
    /// - Parameter idOrReference: The ID or the reference of the transaction.
    /// - Returns: Response of timeline for the transaction.
    func viewTransactionTimeline(_ idOrReference: String) -> ServiceResponse<TransactionTimeline> {
        return service.getTimeline(idOrReference)
    }
    
    /// Total amount received on your account.
    /// - Parameter queries: Query params to customize the response.
    /// - Returns: Response of totals on your account.
    func getTransactionTotals(_ queries: TransactionTotalsQuery...) -> ServiceResponse<TransactionTotals> {
        return service.getTotals(queries)
    }
    
    /// List transactions carried out on your integration.
    /// - Parameter queries: Query params to customize the response.
    /// - Returns: Response of the path to the exported transactions.
    func exportTransactions(_ queries: ExportTransactionsQuery...) -> ServiceResponse<TransactionExportPath> {
        return service.export(queries)
    }
    
    /// Retrieve part of a payment from a customer.
    /// - Parameter request: Request for partial debit.
    /// - Returns: Response of transaction for partial debit.
    func partialDebit(_ request: PartialDebitRequest) -> ServiceResponse<Transaction> {
        return service.partialDebit(request)
    }
    
}
