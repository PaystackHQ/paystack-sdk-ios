import Foundation
import PaystackCore

struct BankTransferTransactionUpdate: Equatable {
    let status: BankTransferStatus
    let message: String?
    let reference: String?
    let transactionId: String?
}

extension BankTransferTransactionUpdate {

    static func from(_ response: PayWithTransferPusherResponse) -> Self {
        BankTransferTransactionUpdate(
            status: BankTransferStatus(rawStatus: response.status,
                                       message: response.message),
            message: response.message,
            reference: response.data?.reference ?? response.data?.trxref,
            transactionId: response.data?.transactionId ?? response.data?.referenceId)
    }
}
