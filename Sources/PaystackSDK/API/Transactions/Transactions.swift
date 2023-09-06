import Foundation

/// The Transactions API allows you create and manage payments on your integration.
public extension Paystack {

    private var service: TransactionService {
        return TransactionServiceImplementation(config: config)
    }

    /// Initiates a secure Card Charge using provided card details
    /// - Parameters:
    ///   - card: The ``CardCharge`` model that encapsulates all the required card details
    ///   - publicEncryptionKey: The public encryption key that will be used, this would be returned as part of ``VerifyAccessCodeResponse``
    ///   - accessCode: The access code for the current transaction
    /// - Returns: A ``Service`` with the ``ChargeResponse`` response
    func chargeCard(_ card: CardCharge,
                    publicEncryptionKey: String,
                    accessCode: String) throws -> Service<ChargeResponse> {
        let encryptedCardCharge = try Cryptography().encrypt(model: card,
                                                             publicKey: publicEncryptionKey)
        let request = ChargeCardRequest(card: encryptedCardCharge, accessCode: accessCode)
        return service.postSubmitCardCharge(request)
    }

    // TODO: Update this description with the correct statues to use this
    /// Checks the status of a charge that has already been initiated.
    /// This should be used when a transaction returns the `timeout` status
    /// - Parameter code: The access code of the transaction being queried
    /// - Returns: A ``Service`` with the latest ``VerifyAccessCodeResponse`` response
    func checkPendingCharge(forAccessCode code: String) -> Service<ChargeResponse> {
        return service.getCheckPendingCharge(for: code)
    }

    /// Verifies an access code for a transaction and returns information related to the transaction, including the supported payment channels
    /// - Parameter code: The access code for the current transaction
    /// - Returns: A ``Service`` with the ``VerifyAccessCodeResponse`` response
    func verifyAccessCode(_ code: String) -> Service<VerifyAccessCodeResponse> {
        return service.getVerifyAccessCode(code)
    }

}
