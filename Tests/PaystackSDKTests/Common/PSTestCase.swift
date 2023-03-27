import XCTest

@testable import PaystackCore

class PSTestCase: XCTestCase {
    
    var mockServiceExecutor: MockServiceExecutor!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockServiceExecutor = MockServiceExecutor()
        ServiceExecutorProvider.set(executor: mockServiceExecutor)
    }
    
    override func tearDownWithError() throws {
        ServiceExecutorProvider.reset()
        try super.tearDownWithError()
    }
    
}
