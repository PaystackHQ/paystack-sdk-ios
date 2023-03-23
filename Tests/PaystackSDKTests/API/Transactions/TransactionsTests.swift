import XCTest
@testable import PaystackSDK

class TransactionsTests: PSTestCase {
    
    let apiKey = "testsk_Example"
    
    var serviceUnderTest: Paystack!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceUnderTest = try PaystackBuilder.newInstance
            .setKey(apiKey)
            .build()
    }
    
//    func testVerifyAccessCode() throws {
//        mockServiceExecutor
//            .expectURL("https://api.paystack.co/transaction/verify_access_code/12345")
//            .expectMethod(.get)
//            .expectHeader("Authorization", "Bearer \(apiKey)")
//            .andReturn(json: "VerifyAccessCode")
//
//        _ = try serviceUnderTest.verifyAccessCode(12345).sync()
//    }
    
}
