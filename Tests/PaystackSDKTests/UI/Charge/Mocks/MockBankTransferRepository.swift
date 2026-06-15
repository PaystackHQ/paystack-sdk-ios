import Foundation
@testable import PaystackUI

class MockBankTransferRepository: BankTransferRepository {

    var expectedBankTransferDetails: BankTransferDetails?
    var expectedChargeCardTransaction: ChargeCardTransaction?
    var expectedErrorResponse: Error?

    var expectedListenForTransferResponses: [BankTransferTransactionUpdate] = []
    var expectedListenForTransferError: Error?

    var payWithTransferSubmitted: (fulfilLateNotification: Bool,
                                   transactionId: Int,
                                   preferredProvider: String?) = (false, 0, nil)
    private(set) var payWithTransferCallCount = 0

    private(set) var checkPendingChargeCallCount = 0
    private(set) var pendingChargeAccessCode: String?

    private(set) var listenForTransferResponseCallCount = 0
    private(set) var lastListenedChannel: String?

    func payWithTransfer(fulfilLateNotification: Bool,
                         transactionId: Int,
                         preferredProvider: String?) async throws -> BankTransferDetails {
        payWithTransferCallCount += 1
        payWithTransferSubmitted = (fulfilLateNotification, transactionId, preferredProvider)
        guard let details = expectedBankTransferDetails else {
            throw expectedErrorResponse ?? MockError.stubNotProvided
        }
        return details
    }

    func checkPendingCharge(with accessCode: String) async throws -> ChargeCardTransaction {
        checkPendingChargeCallCount += 1
        pendingChargeAccessCode = accessCode
        guard let response = expectedChargeCardTransaction else {
            throw expectedErrorResponse ?? MockError.stubNotProvided
        }
        return response
    }

    func listenForTransferResponse(onChannel channelName: String)
        async throws -> BankTransferTransactionUpdate {
        listenForTransferResponseCallCount += 1
        lastListenedChannel = channelName

        if !expectedListenForTransferResponses.isEmpty {
            return expectedListenForTransferResponses.removeFirst()
        }
        if let error = expectedListenForTransferError {
            expectedListenForTransferError = nil
            throw error
        }
        throw expectedErrorResponse ?? MockError.stubNotProvided
    }
}
