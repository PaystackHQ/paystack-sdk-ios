import Foundation
@testable import PaystackCore

class MockPusherSubscriptionListener: SubscriptionListener {

    var response: Result<String, SubscriptionError>?

    var subscriptionExpectation: PusherSubscription?

    func listen(to subscription: any Subscription,
                completion: @escaping (Result<String, SubscriptionError>) -> Void) {
        guard let subscription = subscription as? PusherSubscription,
              let expectation = subscriptionExpectation,
              subscription.subscriptionDetails == expectation.subscriptionDetails else {
            completion(.failure(.other("Subscription expectations could not be met")))
            return
        }

        guard let response = response else {
            completion(.failure(.other("No response has been provided")))
            return
        }

        completion(response)
    }

}

extension MockPusherSubscriptionListener {

    func expectSubscription(_ subscription: PusherSubscription) -> Self {
        self.subscriptionExpectation = subscription
        return self
    }

    func andReturnString(_ stringData: String) {
        self.response = .success(stringData)
    }

    func andReturnString(fromJson filename: String) {
        let bundle = Bundle.module
        guard let url = bundle.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return
        }
        let jsonString = String(decoding: data, as: UTF8.self)

        self.response = .success(jsonString)
    }

    func andReturnError(_ error: SubscriptionError) {
        self.response = .failure(error)
    }

}
