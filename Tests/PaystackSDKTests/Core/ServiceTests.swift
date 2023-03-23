import XCTest
import PaystackSDK

class ServiceTests: PSTestCase {
    
    var service: Service<String>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let request = URLRequest(url: URL(string: "https://api.paystack.co")!)
        service = .request(request)
    }
    
}

// MARK: Async/Callback Tests
extension ServiceTests {
    
    func testAsyncWithCallbackReturnsData() throws {
        let asyncExpectation = expectation(description: "callback")
        mockServiceExecutor.data = try JSONEncoder().encode("example")
        service.async {
            XCTAssertEqual("example", $0)
            XCTAssertNil($1)
            asyncExpectation.fulfill()
        }
        
        wait(for: [asyncExpectation], timeout: 1)
    }
    
    func testAsyncWithCallbackReturnsErrorResponse() throws {
        let asyncExpectation = expectation(description: "callback")
        let error = ErrorResponse(message: "example")
        mockServiceExecutor.data = try JSONEncoder().encode(error)
        service.async {
            XCTAssertNil($0)
            XCTAssertEqual(PaystackError.response(code: 500, message: "example"), $1 as? PaystackError)
            asyncExpectation.fulfill()
        }
        
        wait(for: [asyncExpectation], timeout: 1)
    }
    
    func testAsyncWithCallbackReturnsError() throws {
        let asyncExpectation = expectation(description: "callback")
        mockServiceExecutor.error = PaystackError.technical
        service.async {
            XCTAssertNil($0)
            XCTAssertEqual(PaystackError.technical, $1 as? PaystackError)
            asyncExpectation.fulfill()
        }
        
        wait(for: [asyncExpectation], timeout: 1)
    }
    
}

// MARK: Async/Await Tests
@available(iOS 13.0, *)
extension ServiceTests {
    
    func testAsyncWithAwaitReturnsData() throws {
        let asyncExpectation = expectation(description: "callback")
        mockServiceExecutor.data = try JSONEncoder().encode("example")
        Task {
            let result = try await service.async()
            XCTAssertEqual("example", result)
            asyncExpectation.fulfill()
        }
        
        wait(for: [asyncExpectation], timeout: 1)
    }
    
    func testAsyncWithAwaitReturnsErrorResponse() throws {
        let asyncExpectation = expectation(description: "callback")
        let error = ErrorResponse(message: "example")
        mockServiceExecutor.data = try JSONEncoder().encode(error)
        Task {
            do {
                let _ = try await service.async()
                XCTFail("Service did not throw error for await/async")
            } catch {
                XCTAssertEqual(PaystackError.response(code: 500, message: "example"), error as? PaystackError)
            }
            asyncExpectation.fulfill()
        }
        
        wait(for: [asyncExpectation], timeout: 1)
    }

    func testAsyncWithAwaitReturnsError() throws {
        let asyncExpectation = expectation(description: "callback")
        mockServiceExecutor.error = PaystackError.technical
        Task {
            do {
                let _ = try await service.async()
                XCTFail("Service did not throw error for await/async")
            } catch {
                XCTAssertEqual(PaystackError.technical, error as? PaystackError)
            }
            asyncExpectation.fulfill()
        }
        
        wait(for: [asyncExpectation], timeout: 1)
    }
    
}

// MARK: Sync Tests
extension ServiceTests {
    
    func testSyncWithAwaitReturnsData() throws {
        mockServiceExecutor.data = try JSONEncoder().encode("example")
        
        let result = try service.sync()
        
        XCTAssertEqual("example", result)
    }
    
    func testSyncWithAwaitReturnsErrorResponse() throws {
        let error = ErrorResponse(message: "example")
        mockServiceExecutor.data = try JSONEncoder().encode(error)
        
        do {
            let _ = try service.sync()
            XCTFail("Service did not throw error for await/async")
        } catch {
            XCTAssertEqual(PaystackError.response(code: 500, message: "example"), error as? PaystackError)
        }
    }

    func testSyncWithAwaitReturnsError() throws {
        mockServiceExecutor.error = PaystackError.technical
        do {
            let _ = try service.sync()
            XCTFail("Service did not throw error for await/async")
        } catch {
            XCTAssertEqual(PaystackError.technical, error as? PaystackError)
        }
    }
    
}

// MARK: Publisher Tests
@available(iOS 13.0, *)
extension ServiceTests {
    
    func testPublisherReturnsData() throws {
        let asyncExpectation = expectation(description: "callback")
        mockServiceExecutor.data = try JSONEncoder().encode("example")
        
        let _ = service.publisher()
            .sink { _ in
                // Do nothing
            } receiveValue: {
                XCTAssertEqual("example", $0)
                asyncExpectation.fulfill()
            }
        
        wait(for: [asyncExpectation], timeout: 1)
    }
    
    func testPublisherReturnsErrorResponse() throws {
        let asyncExpectation = expectation(description: "callback")
        let error = ErrorResponse(message: "example")
        mockServiceExecutor.data = try JSONEncoder().encode(error)
        
        let _ = service.publisher()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertEqual(PaystackError.response(code: 500, message: "example"), error as? PaystackError)
                case .finished:
                    XCTFail("Service Publisher did not throw error response")
                }
                
                asyncExpectation.fulfill()
            } receiveValue: { _ in
                // Do nothing
            }
        
        wait(for: [asyncExpectation], timeout: 1)
    }
    
    func testPublisherReturnsError() throws {
        let asyncExpectation = expectation(description: "callback")
        mockServiceExecutor.error = PaystackError.technical
        
        let _ = service.publisher()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertEqual(PaystackError.technical, error as? PaystackError)
                case .finished:
                    XCTFail("Service Publisher did not throw error")
                }
                
                asyncExpectation.fulfill()
            } receiveValue: { _ in
                // Do nothing
            }
        
        wait(for: [asyncExpectation], timeout: 1)
    }
    
}

private struct ErrorResponse: Encodable {
    var message: String
}
