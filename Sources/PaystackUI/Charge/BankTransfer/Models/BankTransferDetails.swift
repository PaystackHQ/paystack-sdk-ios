import Foundation
import PaystackCore

struct BankTransferDetails: Equatable {
    let accountName: String
    let accountNumber: String
    let bankName: String
    let bankSlug: String
    let transactionReference: String
    let pusherChannel: String
    let accountExpiresAt: Date
    let transactionId: String
}

extension BankTransferDetails {

    static func from(_ response: PayWithTransferResponse) -> Self {
        BankTransferDetails(
            accountName: response.data.accountName,
            accountNumber: response.data.accountNumber,
            bankName: response.data.bank.name,
            bankSlug: response.data.bank.slug,
            transactionReference: response.data.transactionReference,
            pusherChannel: response.data.pusherChannel,
            accountExpiresAt: response.data.accountExpiresAt,
            transactionId: response.data.transactionId)
    }
}

extension BankTransferDetails {
    static var example: BankTransferDetails {
        BankTransferDetails(
            accountName: "PAYSTACK CHECKOUT",
            accountNumber: "9985488398",
            bankName: "Paystack-Titan",
            bankSlug: "titan-paystack",
            transactionReference: "T6215047322I100043S0g703",
            pusherChannel: "PWT6215047322",
            accountExpiresAt: Date().addingTimeInterval(30 * 60),
            transactionId: "6215047322")
    }
}
