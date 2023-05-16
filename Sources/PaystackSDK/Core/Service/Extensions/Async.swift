import Foundation

public extension Service {

    func async(_ callback: @escaping (T?, Error?) -> Void) {
        switch self {
        case .request(let request):
            async(request, callback)
        case .subscription(let subscription):
            async(subscription, callback)
        case .error(let error):
            callback(nil, error)
        }
    }

    @available(iOS 13.0.0, *)
    func async() async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            async { result, error in
                if let result = result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: error ?? PaystackError.technical)
                }
            }
        }
    }

}

extension Service {

    func async(_ request: URLRequest, _ callback: @escaping (T?, Error?) -> Void) {
        ServiceExecutorProvider.execute(request: request) { data, response, error in
            let responseCode = (response as? HTTPURLResponse)?.statusCode ?? 500
            if let data = data {
                do {
                    return callback(try JSONDecoder.decoder.decode(T.self, from: data), nil)
                } catch where !responseCode.isSuccessResponseCode {
                    let message = message(from: data)
                    let error = PaystackError.response(code: responseCode, message: message)
                    return callback(nil, error)
                } catch {
                    return callback(nil, error)
                }
            }

            return callback(nil, error ?? PaystackError.technical)
        }
    }

    func async(_ subscription: any Subscription, _ callback: @escaping (T?, Error?) -> Void) {
        SubscriptionListenerProvider.listen(to: subscription) { result in
            switch result {
            case .success(let stringData):
                let data = Data(stringData.utf8)
                do {
                    return callback(try JSONDecoder.decoder.decode(T.self, from: data), nil)
                } catch {
                    callback(nil, error)
                }
            case .failure(let error):
                callback(nil, error)
            }
        }
    }

    func message(from data: Data) -> String {
        if let response = try? JSONDecoder.decoder.decode(ErrorResponse.self, from: data) {
            return response.message
        }

        return "Something went wrong"
    }
}

extension Int {

    var isSuccessResponseCode: Bool {
        return self == 200 || self == 201
    }

}

private struct ErrorResponse: Error, Decodable {
    public var message: String
}
