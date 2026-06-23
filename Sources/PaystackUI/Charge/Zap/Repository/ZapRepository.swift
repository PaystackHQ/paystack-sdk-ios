import Foundation
import PaystackCore

protocol ZapRepository {

    func initiateZapMandate(supportedBankId: Int,
                            transactionId: Int,
                            walletEmail: String) async throws -> ZapMandateResponse

    func listenForZapResponse(onChannel channelName: String)
        async throws -> BankTransferTransactionUpdate
}

struct ZapRepositoryImplementation: ZapRepository {

    let paystack: Paystack

    init() {
        self.paystack = PaystackContainer.instance.retrieve()
    }

    func initiateZapMandate(supportedBankId: Int,
                            transactionId: Int,
                            walletEmail: String) async throws -> ZapMandateResponse {
        let request = ZapMandateRequest(id: supportedBankId,
                                        transactionId: transactionId,
                                        walletId: walletEmail)
        return try await paystack.initiateZapMandate(request).async()
    }

    func listenForZapResponse(onChannel channelName: String)
        async throws -> BankTransferTransactionUpdate {
        let response = try await paystack
            .listenForZapResponse(onChannel: channelName).async()
        return BankTransferTransactionUpdate.from(response)
    }
}
