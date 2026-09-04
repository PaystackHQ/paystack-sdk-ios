import Foundation
@testable import PaystackCore
@testable import PaystackUI

class MockCapitecPayRepository: CapitecPayRepository {

    var expectedDetails: CapitecPayDetails?
    var expectedRequeryResults: [ChargeCardTransaction] = []
    var expectedErrorResponse: Error?

    var expectedListenResponses: [ChargeCardTransaction] = []
    var expectedListenError: Error?

    var authenticateSubmitted: (identifier: CapitecPayIdentifier,
                                value: String,
                                transactionId: Int,
                                deviceId: String,
                                publicEncryptionKey: String) = (.cellphone, "", 0, "", "")
    private(set) var authenticateCallCount = 0

    private(set) var requeryCallCount = 0
    private(set) var lastRequeryReference: String?

    private(set) var listenCallCount = 0
    private(set) var lastListenedChannel: String?

    func authenticate(identifier: CapitecPayIdentifier,
                      value: String,
                      transactionId: Int,
                      deviceId: String,
                      publicEncryptionKey: String) async throws -> CapitecPayDetails {
        authenticateCallCount += 1
        authenticateSubmitted = (identifier, value, transactionId, deviceId, publicEncryptionKey)
        guard let details = expectedDetails else {
            throw expectedErrorResponse ?? MockError.stubNotProvided
        }
        return details
    }

    func requery(transactionReference: String) async throws -> ChargeCardTransaction {
        requeryCallCount += 1
        lastRequeryReference = transactionReference
        if !expectedRequeryResults.isEmpty {
            return expectedRequeryResults.removeFirst()
        }
        throw expectedErrorResponse ?? MockError.stubNotProvided
    }

    func listenForCapitecPayResponse(onChannel channelName: String)
        async throws -> ChargeCardTransaction {
        listenCallCount += 1
        lastListenedChannel = channelName
        if !expectedListenResponses.isEmpty {
            return expectedListenResponses.removeFirst()
        }
        if let error = expectedListenError {
            expectedListenError = nil
            throw error
        }
        throw expectedErrorResponse ?? MockError.stubNotProvided
    }
}
