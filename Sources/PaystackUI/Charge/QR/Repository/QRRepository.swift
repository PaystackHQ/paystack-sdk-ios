import Foundation
import PaystackCore

protocol QRRepository {
    func generate(reference: String,
                  channelOption: String,
                  variant: QRVariant) async throws -> QRDetails

    func listenForResponse(onChannel channelName: String)
        async throws -> ChargeCardTransaction

    func checkPending(accessCode: String) async throws -> ChargeCardTransaction
}

struct QRRepositoryImplementation: QRRepository {

    let paystack: Paystack

    init() {
        self.paystack = PaystackContainer.instance.retrieve()
    }

    func generate(reference: String,
                  channelOption: String,
                  variant: QRVariant) async throws -> QRDetails {
        let request = QRGenerateRequest(
            reference: reference,
            channel: channelOption)
        let response = try await paystack.generateQR(request).async()
        guard response.status, !response.data.errors else {
            throw ChargeError(message: response.message)
        }
        guard let details = QRDetails.from(response, variant: variant) else {
            throw ChargeError(message: "The QR image URL is invalid")
        }
        return details
    }

    func listenForResponse(onChannel channelName: String)
        async throws -> ChargeCardTransaction {
        let response = try await paystack
            .listenForQRResponse(onChannel: channelName).async()
        return ChargeCardTransaction.from(response)
    }

    func checkPending(accessCode: String) async throws -> ChargeCardTransaction {
        let response = try await paystack
            .checkPendingCharge(forAccessCode: accessCode).async()
        return ChargeCardTransaction.from(response)
    }
}
