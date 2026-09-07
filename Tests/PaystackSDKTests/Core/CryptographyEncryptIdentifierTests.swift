import XCTest
@testable import PaystackCore

/// Covers `Cryptography.encrypt(text:publicKey:)` against a freshly generated
/// 2048-bit key pair, using the identifier plaintext shapes Capitec Pay sends
/// as `clientdata`.
final class CryptographyEncryptIdentifierTests: XCTestCase {

    private var privateKey: SecKey!
    private var publicKeyBase64: String!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048
        ]
        var error: Unmanaged<CFError>?
        guard let generated = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw XCTSkip("Could not generate RSA key pair: \(error.debugDescription)")
        }
        privateKey = generated

        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw XCTSkip("Could not copy public key from generated pair")
        }
        var exportError: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &exportError) as Data? else {
            throw XCTSkip("Could not export public key: \(exportError.debugDescription)")
        }
        publicKeyBase64 = publicKeyData.base64EncodedString()
    }

    func testEncryptRoundTripsCellphoneIdentifierPlaintext() throws {
        try assertRoundTrip("CELLPHONE*0609603632")
    }

    func testEncryptRoundTripsIDNumberIdentifierPlaintext() throws {
        try assertRoundTrip("IDNUMBER*8001015009087")
    }

    func testEncryptRoundTripsAccountNumberIdentifierPlaintext() throws {
        try assertRoundTrip("ACCOUNTNUMBER*123456789")
    }

    func testEncryptProducesNonDeterministicCiphertext() throws {
        let sut = Cryptography()
        let first = try sut.encrypt(text: "CELLPHONE*0609603632",
                                    publicKey: publicKeyBase64)
        let second = try sut.encrypt(text: "CELLPHONE*0609603632",
                                     publicKey: publicKeyBase64)
        XCTAssertNotEqual(first, second,
                          "OAEP seeds each encryption randomly ; two encryptions of the same plaintext must not be byte-equal")
    }

    private func assertRoundTrip(_ plaintext: String,
                                 file: StaticString = #filePath,
                                 line: UInt = #line) throws {
        let sut = Cryptography()
        let base64Ciphertext = try sut.encrypt(text: plaintext,
                                               publicKey: publicKeyBase64)
        let ciphertext = try XCTUnwrap(Data(base64Encoded: base64Ciphertext),
                                       file: file, line: line)

        var decryptError: Unmanaged<CFError>?
        guard let decryptedCF = SecKeyCreateDecryptedData(privateKey,
                                                          .rsaEncryptionOAEPSHA1,
                                                          ciphertext as CFData,
                                                          &decryptError) else {
            XCTFail("Decryption failed: \(decryptError.debugDescription)",
                    file: file, line: line)
            return
        }
        let decrypted = decryptedCF as Data
        let recovered = try XCTUnwrap(String(data: decrypted, encoding: .utf8),
                                      file: file, line: line)
        XCTAssertEqual(recovered, plaintext, file: file, line: line)
    }
}
