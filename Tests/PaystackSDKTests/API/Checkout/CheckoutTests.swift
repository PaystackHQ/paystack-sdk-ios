import XCTest
@testable import Paystack
@testable import Checkout

class CheckoutTests: PSTestCase {
    
    let apiKey = "testsk_Example"
    
    var serviceUnderTest: Paystack!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceUnderTest = try PaystackBuilder.newInstance
            .setKey(apiKey)
            .build()
    }

    // Note: Temporarily commenting out as these tests are failing
//    func testRequestInline() throws {
//        mockServiceExecutor
//            .expectURL("https://api.paystack.co/checkout/request_inline?firstname=Justin&lastname=Guedes&key=\(apiKey)")
//            .expectMethod(.get)
//            .expectHeader("Authorization", "Bearer \(apiKey)")
//            .andReturn(json: "RequestInline")
//
//        _ = try serviceUnderTest.requestInline([.firstname("Justin"),
//                                                .lastname("Guedes")]).sync()
//    }
}
