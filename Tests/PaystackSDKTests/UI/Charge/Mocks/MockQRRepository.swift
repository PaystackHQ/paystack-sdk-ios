import Foundation
@testable import PaystackCore
@testable import PaystackUI

class MockQRRepository: QRRepository {

    var expectedDetails: QRDetails?
    var expectedGenerateError: Error?

    var expectedListenResponses: [ChargeCardTransaction] = []
    var expectedListenError: Error?

    var expectedCheckPendingResults: [ChargeCardTransaction] = []
    var expectedCheckPendingError: Error?

    var generateSubmitted: (reference: String,
                            channelOption: String,
                            variant: QRVariant) = ("", "", .scanToPay)
    private(set) var generateCallCount = 0

    private(set) var listenCallCount = 0
    private(set) var lastListenedChannel: String?

    private(set) var checkPendingCallCount = 0
    private(set) var lastCheckPendingAccessCode: String?

    func generate(reference: String,
                  channelOption: String,
                  variant: QRVariant) async throws -> QRDetails {
        generateCallCount += 1
        generateSubmitted = (reference, channelOption, variant)
        if let error = expectedGenerateError {
            throw error
        }
        guard let details = expectedDetails else {
            throw MockError.stubNotProvided
        }
        return details
    }

    func listenForResponse(onChannel channelName: String)
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
        throw MockError.stubNotProvided
    }

    func checkPending(accessCode: String) async throws -> ChargeCardTransaction {
        checkPendingCallCount += 1
        lastCheckPendingAccessCode = accessCode
        if !expectedCheckPendingResults.isEmpty {
            return expectedCheckPendingResults.removeFirst()
        }
        if let error = expectedCheckPendingError {
            expectedCheckPendingError = nil
            throw error
        }
        throw MockError.stubNotProvided
    }
}
