import Foundation
@testable import PaystackCore
@testable import PaystackUI

class MockZapRepository: ZapRepository {

    var expectedMandateResponse: ZapMandateResponse?
    var expectedErrorResponse: Error?

    var expectedListenForZapResponses: [ChargeCardTransaction] = []
    var expectedListenForZapError: Error?

    var initiateZapMandateSubmitted: (supportedBankId: Int,
                                      transactionId: Int,
                                      walletEmail: String) = (0, 0, "")
    private(set) var initiateZapMandateCallCount = 0

    private(set) var listenForZapResponseCallCount = 0
    private(set) var lastListenedChannel: String?

    func initiateZapMandate(supportedBankId: Int,
                            transactionId: Int,
                            walletEmail: String) async throws -> ZapMandateResponse {
        initiateZapMandateCallCount += 1
        initiateZapMandateSubmitted = (supportedBankId, transactionId, walletEmail)
        guard let response = expectedMandateResponse else {
            throw expectedErrorResponse ?? MockError.stubNotProvided
        }
        return response
    }

    func listenForZapResponse(onChannel channelName: String)
        async throws -> ChargeCardTransaction {
        listenForZapResponseCallCount += 1
        lastListenedChannel = channelName

        if !expectedListenForZapResponses.isEmpty {
            return expectedListenForZapResponses.removeFirst()
        }
        if let error = expectedListenForZapError {
            expectedListenForZapError = nil
            throw error
        }
        throw expectedErrorResponse ?? MockError.stubNotProvided
    }
}
