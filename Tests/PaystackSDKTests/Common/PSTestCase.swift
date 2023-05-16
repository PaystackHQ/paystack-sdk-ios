import XCTest

@testable import PaystackCore

class PSTestCase: XCTestCase {

    var mockServiceExecutor: MockServiceExecutor!
    var mockSubscriptionListener: MockPusherSubscriptionListener!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockServiceExecutor = MockServiceExecutor()
        mockSubscriptionListener = MockPusherSubscriptionListener()
        ServiceExecutorProvider.set(executor: mockServiceExecutor)
        SubscriptionListenerProvider.set(listener: mockSubscriptionListener)
    }

    override func tearDownWithError() throws {
        ServiceExecutorProvider.reset()
        SubscriptionListenerProvider.reset()
        try super.tearDownWithError()
    }

}
