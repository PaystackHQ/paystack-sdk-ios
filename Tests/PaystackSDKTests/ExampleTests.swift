import XCTest
import Paystack
import Paystack_Transactions

class ExampleTests: XCTestCase {
    
    func test() throws {
        let instance = try PaystackBuilder.newInstance
            .setKey("sk_test_587abe69a1bac4da30cf5105424e29c34da03fa3")
            .build()
        
//        let service
//        let response = try service.sync()
//
//        dump(response)
    }
    
}

