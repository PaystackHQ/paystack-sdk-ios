import Foundation

@testable import PaystackCore

class MockServiceExecutor: ServiceExecutor {

    var data: Data?
    var response: URLResponse?
    var error: Error?

    var serviceExpectations: [(URLRequest) -> Bool] = []

    func execute(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard serviceExpectations.allSatisfy({ $0(request) }) else {
            completion(nil, nil, nil)
            return
        }

        completion(data, response, error)
    }

}

extension MockServiceExecutor {

    func expectURL(_ url: String) -> Self {
        serviceExpectations.append { request in
            request.url?.absoluteString == url
        }

        return self
    }

    func expectMethod(_ method: HTTPMethod) -> Self {
        serviceExpectations.append { request in
            request.httpMethod == method.rawValue.uppercased()
        }

        return self
    }

    func expectHeader(_ header: String, _ value: String) -> Self {
        serviceExpectations.append { request in
            request.allHTTPHeaderFields?[header] == value
        }

        return self
    }

    func expectBody<T: Encodable>(_ body: T) -> Self {
        serviceExpectations.append { request in
            request.httpBody == (try? JSONEncoder.encoder.encode(body))
        }

        return self
    }

    func andReturn(json filename: String) {
        let bundle = Bundle.module
        let url = bundle.url(forResource: filename, withExtension: "json")
        self.data = url.flatMap { try? Data(contentsOf: $0) }
        self.response = url.flatMap { HTTPURLResponse(url: $0, statusCode: 200, httpVersion: nil, headerFields: nil) }
    }

    func andThrow(_ error: Error) {
        self.error = error
    }

}
