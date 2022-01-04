import XCTest
import Paystack

@testable import Paystack_Transactions

class TransactionsTests: PSTestCase {
    
    let apiKey = "testsk_Example"
    
    var serviceUnderTest: Paystack!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceUnderTest = try PaystackBuilder.newInstance
            .setKey(apiKey)
            .build()
    }
    
    func testInitializeTransaction() throws {
        let request = InitializeTransactionRequest(amount: 1000,
                                                   email: "test@test.com")
        
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/initialize")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectHeader("Content-Type", "application/json")
            .expectBody(request)
            .andReturn(json: "InitializeTransaction")
        
        _ = try serviceUnderTest.initializeTransaction(request).sync()
    }
    
    func testVerifyTransaction() throws {
        let reference = "exampleRef"

        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/verify/\(reference)")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "VerifyTransaction")
        
        _ = try serviceUnderTest.verifyTransaction(reference).sync()
    }
    
    func testListTransactions() throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction?customer=123")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "ListTransactions")
        
        _ = try serviceUnderTest.listTransactions(.customer(123)).sync()
    }
    
    func testFetchTransaction() throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/123456")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "FetchTransaction")
        
        _ = try serviceUnderTest.fetchTransaction(123456).sync()
    }
    
    func testChargeAuthorization() throws {
        let request = ChargeAuthorizationRequest(amount: 5000,
                                                 email: "test@test.com",
                                                 authorizationCode: "A_ASD21e1sadF")
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/charge_authorization")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectHeader("Content-Type", "application/json")
            .expectBody(request)
            .andReturn(json: "ChargeAuthorization")
        
        _ = try serviceUnderTest.chargeAuthorization(request).sync()
    }
    
    func testCheckAuthorization() throws {
        let request = CheckAuthorizationRequest(amount: 5005,
                                                email: "test@test.com",
                                                authorizationCode: "A_GAWF421S")
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/check_authorization")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectHeader("Content-Type", "application/json")
            .expectBody(request)
            .andReturn(json: "CheckAuthorization")
        
        _ = try serviceUnderTest.checkAuthorization(request).sync()
    }
    
    func testViewTransactionTimeline() throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/timeline/T123456")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "ViewTransactionTimeline")
        
        _ = try serviceUnderTest.viewTransactionTimeline("T123456").sync()
    }
    
    func testTransactionTotals() throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/totals?page=3")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "TransactionTotals")
        
        _ = try serviceUnderTest.getTransactionTotals(.page(3)).sync()
    }
    
    func testExportTransactions() throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/export?status=success")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "ExportTransactions")
        
        _ = try serviceUnderTest.exportTransactions(.status(.success)).sync()
    }
    
    func testPartialDebit() throws {
        let request = PartialDebitRequest(authorizationCode: "A_AGWD32131",
                                          currency: .ngn,
                                          amount: "5000",
                                          email: "test@test.com")
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/partial_debit")
            .expectMethod(.post)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .expectHeader("Content-Type", "application/json")
            .expectBody(request)
            .andReturn(json: "PartialDebit")
        
        _ = try serviceUnderTest.partialDebit(request).sync()
    }
    
}
