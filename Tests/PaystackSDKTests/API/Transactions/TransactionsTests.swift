import XCTest
@testable import PaystackCore

class TransactionsTests: PSTestCase {
    
    let apiKey = "testsk_Example"
    
    var serviceUnderTest: Paystack!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceUnderTest = try PaystackBuilder.newInstance
            .setKey(apiKey)
            .build()
    }
    
    func testVerifyAccessCode() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/verify_access_code/access_code_test")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "VerifyAccessCode")

        _ = try await serviceUnderTest.verifyAccessCode("access_code_test").async()
    }
    
}
