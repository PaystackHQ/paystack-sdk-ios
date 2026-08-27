import Foundation
import PaystackCore

protocol CapitecPayRepository {
    func authenticate(identifier: CapitecPayIdentifier,
                      value: String,
                      transactionId: Int,
                      deviceId: String,
                      publicEncryptionKey: String) async throws -> CapitecPayDetails

    func requery(transactionReference: String) async throws -> ChargeCapitecTransaction

    func listenForCapitecPayResponse(onChannel channelName: String)
        async throws -> ChargeCardTransaction
}

struct CapitecPayRepositoryImplementation: CapitecPayRepository {

    let paystack: Paystack
    let cryptography: CryptographyProtocol

    init(cryptography: CryptographyProtocol = Cryptography()) {
        self.paystack = PaystackContainer.instance.retrieve()
        self.cryptography = cryptography
    }

    func authenticate(identifier: CapitecPayIdentifier,
                      value: String,
                      transactionId: Int,
                      deviceId: String,
                      publicEncryptionKey: String) async throws -> CapitecPayDetails {
        
        let plaintext = "\(identifier.rawValue)*\(value)"
        let clientdata = try cryptography.encrypt(
            text: plaintext, publicKey: publicEncryptionKey)
        let request = CapitecPayAuthenticateRequest(
            clientdata: clientdata,
            trans: "\(transactionId)",
            device: deviceId)
        let response = try await paystack.authenticateCapitecPay(request).async()
        return CapitecPayDetails.from(response, transactionId: transactionId)
    }

    func requery(transactionReference: String) async throws -> ChargeCapitecTransaction {
        let response = try await paystack
            .requeryCapitecPay(transactionReference: transactionReference).async()
        return ChargeCapitecTransaction.from(response)
    }

    func listenForCapitecPayResponse(onChannel channelName: String)
        async throws -> ChargeCardTransaction {
        let response = try await paystack
            .listenForCapitecPayResponse(onChannel: channelName).async()
        return ChargeCardTransaction.from(response)
    }
}
