import XCTest
@testable import PaystackCore

final class CryptographyTests: XCTestCase {
    var serviceUnderTest: Cryptography!
    // swiftlint:disable:next line_length
    let publicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCeCnSCpcVRhP5cvJ8HNTzax/Lw17ERVTS/wafBTLlJ0BxT+WGwy2OfdIshAroiZfSAWfFKFhF9KbKJvcyPGQ4oDibSbN/YriHmKxQt2CP6l3X0A7wHzSRLD4QR2DaqcA+blrm0szZQ5/8goyK+JDlyHrsSck/AVzm4S2zQ8FEEIQIDAQAB"

    // swiftlint:disable:next line_length
    let privateKey = "MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAJ4KdIKlxVGE/ly8nwc1PNrH8vDXsRFVNL/Bp8FMuUnQHFP5YbDLY590iyECuiJl9IBZ8UoWEX0psom9zI8ZDigOJtJs39iuIeYrFC3YI/qXdfQDvAfNJEsPhBHYNqpwD5uWubSzNlDn/yCjIr4kOXIeuxJyT8BXObhLbNDwUQQhAgMBAAECgYEAhoO1mUHJSdJdwccVwEfS7RBEujOL1YnlZNVKmJ9aEfZdNihLuvPSbnT+unEcxoxq6Bgl5H4WEqc7/Dsc8itMPPsi17rw64BQK2S2ZYyzWxPVrdxJmBFDVK7Fq2jfnUtBlhzY/fJ+gbOf7EvuPDi5vzoaQf15TuALL/C/jiuvFQECQQDMe1Nkn3X4ebVoojtQzyOBxXTNMk1qFnFUTKBKh0UNqJJKL8stxeWh84GgKAZOSrf80jnAmnJ8vKJjr1lv4vyRAkEAxdvIGvNCU21wSUcA3YsUFMzbKCE+pOxwqo9jklySH0m6FGtaO+3T0tcKgAYOyULrXjPa1FfGjppdqRHkshOWkQJAYOHRqiwvTdIElJXA+tGZpiOy6oH50djeSy2fCJC8s/L5lPK+FmrcGPZxpTsxeajHMZ89Q7cppVYOrqJnAq8OMQJAOH06UW94VUdekp1CAv6NOi8OtxNexkl3FUsg+42QbnxnMyM/PPL20jBxIAIawJ1pg5i8dnmlB9vMt9OS/sCW8QJAQ23UgXrKHiCU89R9UY5XzSCzYY2qCRPG0sfVWnuB23m6rN2smIr2lQFOUg+TPPwMYSt+OQQ0pGm9bd6yHYDVkQ=="

    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceUnderTest = Cryptography()
    }

    func testSimpleEncryptionCase() {
        let clearText = "Hello World"

        guard let encryptedData = try? serviceUnderTest.encrypt(text: clearText, publicKey: publicKey) else {
            XCTFail("Encryption failed")
            return
        }
        guard let decryptedString = try? serviceUnderTest.decrypt(base64String: encryptedData,
                                                                  privateKey: privateKey) else {
            XCTFail("Decryption failed")
            return
        }

        XCTAssertEqual(decryptedString, clearText)
    }

    func testEncryptionWithSpecialCharacters() {
        let mockCardConcatenation = "1234567890123456*123*01*23"
        guard let encryptedData = try? serviceUnderTest.encrypt(text: mockCardConcatenation,
                                                                publicKey: publicKey) else {
            XCTFail("Encryption failed")
            return
        }

        guard let decryptedString = try? serviceUnderTest.decrypt(base64String: encryptedData,
                                                                  privateKey: privateKey) else {
            XCTFail("Decryption failed")
            return
        }

        XCTAssertEqual(decryptedString, mockCardConcatenation)
    }

    func testLongClearTextCase() {
        let clearText = [String](repeating: "a", count: 86).joined(separator: "")

        guard let encryptedData = try? serviceUnderTest.encrypt(text: clearText, publicKey: publicKey) else {
            XCTFail("Encryption failed")
            return
        }

        guard let decryptedString = try? serviceUnderTest.decrypt(base64String: encryptedData,
                                                                  privateKey: privateKey) else {
            XCTFail("Decryption failed")
            return
        }

        XCTAssertEqual(decryptedString, clearText)
    }

    func testAttemptingToEncryptTextThatIsOverTheLengthLimitThrowsError() {
        let clearText = [String](repeating: "a", count: 200).joined(separator: "")

        XCTAssertThrowsError(try serviceUnderTest.encrypt(text: clearText, publicKey: publicKey)) { error in
            XCTAssertEqual(error as? CryptographyError, CryptographyError.encryptionFailed)
        }
    }

    func testAttemptToEncryptTextWithPublicKeyThatIsNotBase64ThrowsError() {
        let clearText = "Hello World"
        XCTAssertThrowsError(try serviceUnderTest.encrypt(text: clearText, publicKey: "ABC")) { error in
            XCTAssertEqual(error as? CryptographyError, CryptographyError.invalidBase64String)
        }
    }

    func testAttemptToEncryptWithRandomBase64StringFailsParsingAndThrowsError() {
        let clearText = "Hello World"
        let invalidKey = "SGVsbG8gV29ybGQgMTIz"
        XCTAssertThrowsError(try serviceUnderTest.encrypt(text: clearText, publicKey: invalidKey)) { error in
            XCTAssertEqual(error as? CryptographyError, CryptographyError.asn1ParsingFailed)
        }
    }

    func testAttemptToEncryptWithInvalidKeyFailsToCreateKeyAndThrowsError() {
        // swiftlint:disable:next line_length
        let pkcs8Key = "MIIBvTBXBgkqhkiG9w0BBQ0wSjApBgkqhkiG9w0BBQwwHAQIpZHwLtkYRb4CAggAMAwGCCqGSIb3DQIJBQAwHQYJYIZIAWUDBAECBBCCGsoP7F4bd8O5I1poTn8PBIIBYBtM1tgqsAQgbSZT0475aHufzFuJuPWOYqiHag8OUKMeZuxVHndElipEY2V5lS9mwddwtWaGuYD/Swcdt0Xht8U8BF0SjSyzQ4YtRsG9CmEHYhWmQ5AqK1W3mDUApO38Cm5L1HrHV4YJnYmmK9jgq+iWlLFDmB8s4TA6kMPWbCENlpr1kEXz4hLwY3ylH8XWI65WX2jGSn61jayCwpf1HPFBPDUaS5s3f92aKjk0AE8htsDBBiCVS3Yjq4QSbhfzuNIZ1TooXT9Xn+EJC0yjVnlTHZMfqrcA3OmVSi4kftugjAax4Z2qDqO+onkgeJAwP75scMcwH0SQUdrNrejgfIzJFWzcH9xWwKhOT9s9hLx2OfPlMtDDSJVRspqwwQrFQwinX0cR9Hx84rSMrFndxZi52o9EOLJ7cithncoW1KOAf7lIJIUzP0oIKkskAndQo2UiZsxgoMYuq02T07DOknc="
        let clearText = "Hello World"

        XCTAssertThrowsError(try serviceUnderTest.encrypt(text: clearText, publicKey: pkcs8Key)) { error in
            XCTAssertEqual(error as? CryptographyError, CryptographyError.keyCreationFailed)
        }
    }

    func testAttemptToEncryptWithAPrivateKeyFailsToCreateKeyAndThrowsError() {
        let clearText = "Hello World"

        XCTAssertThrowsError(try serviceUnderTest.encrypt(text: clearText, publicKey: privateKey)) { error in
            XCTAssertEqual(error as? CryptographyError, CryptographyError.keyCreationFailed)
        }
    }

    func testDecryptionFailsWhenAnInvalidPrivateKeyIsUsed() {
        // swiftlint:disable:next line_length
        let dataEncryptedWithDifferentKey = "c49dou2gFV2kLQQrSncNbARFUSfronZtMoumWZTmd7ALXiAxiwwKT08iG58WtgfAqfEBYHFw0riD3aKj0iwVxKLdw3TIX5eoJVXME9IO6JXRUjnshlwSMqNL3pZ3+yDIosxvGPUK8XE5anajO5y3TekaG6OqG46EtiLiAoZJ+/s="

        XCTAssertThrowsError(try serviceUnderTest.decrypt(base64String: dataEncryptedWithDifferentKey,
                                                          privateKey: privateKey)) { error in
            XCTAssertEqual(error as? CryptographyError, CryptographyError.decryptionFailed)
        }
    }

    func testStandaloneDecryptionWithMatchingPrivateKey() {
        // swiftlint:disable:next line_length
        let encryptedData = "JGQR/v/7z+Owaw969pxlO5PmEn1WFwHqvEPHvXvsBs4QLyakWW+AciAEqrBK1vBAFgLHuzWTrD9uwAR5OC3or14tTDVAy5vMDyXRGgVFiR1JXdK4fuPxG5+anr/i1VIL4bQb+F2g3alLgjLkl1J7wPINhj0lXFOS0hrssKZDaCU="
        guard let decryptedString = try? serviceUnderTest.decrypt(base64String: encryptedData,
                                                                  privateKey: privateKey) else {
            XCTFail("Decryption failed")
            return
        }

        let expectedValue = "Hello World"
        XCTAssertEqual(expectedValue, decryptedString)
    }

    func testEncryptionOfObjectDecryptsBackToTheSameObject() throws {
        let mockObject = MockObject(number: 123, name: "Test")

        let encryptedData = try serviceUnderTest.encrypt(model: mockObject,
                                                         publicKey: publicKey)
        let decryptedData: MockObject = try serviceUnderTest.decrypt(base64String: encryptedData,
                                                                     privateKey: privateKey)
        XCTAssertEqual(mockObject, decryptedData)
    }

    func testAlreadyEncryptedJsonStringDecryptsCorrectlyToModel() throws {
        // swiftlint:disable:next line_length
        let encryptedData = "g+zqJYWMz0FcUQpOvvaWSa6/Tyb4WZP8G0MdoHhmR9BXUXhX/n3JkQ2dyH7AM97DxUOIVZGcnQHJIEAssVG5FdCWpFVQTuTd7ErDk0vMjJfnJHwol8VBxd+b8rbFKnNbVMOeleLPJ6Jgvv2jdoFLqOsb/0iTF17SLlTIYH1uSd0="
        let expectedObject = MockObject(number: 789, name: "Test Decrypt")

        let decryptedData: MockObject = try serviceUnderTest.decrypt(base64String: encryptedData,
                                                                     privateKey: privateKey)
        XCTAssertEqual(expectedObject, decryptedData)
    }

    func testDecryptionFailsWhenDecryptedDataCannotBeDecodedToTheExpectedModel() {
        // swiftlint:disable:next line_length
        let encryptedData = "D745spEYFbavF2a0JRuc/cgK5YQuNuBP5DsAjDx+2aY84jH6S7PoeiD4nAUy7mVkSp133Py+nVCBWrd9nKfzrjArZYjvXgwy7+Q1gdRXD132GD2YI1wLg9M4nauid1cbKfPeXMqboisuEdHWR6dvCqn55septvQOwJAOariJAsE="

        do {
            let _: MockObject = try serviceUnderTest.decrypt(base64String: encryptedData,
                                                             privateKey: privateKey)
            XCTFail("Decoding should fail")
        } catch {
            XCTAssertEqual(error as? CryptographyError, CryptographyError.modelDecodingFailed)
        }
    }

}

private struct MockObject: Codable, Equatable {
    var number: Int
    var name: String
}

// MARK: - Decryption
extension Cryptography {
    func decrypt(base64String: String, privateKey: String) throws -> String {
        guard let data = Data(base64Encoded: base64String) else {
            throw CryptographyError.invalidBase64String
        }
        let key = try createKey(from: privateKey, isPublic: false)

        var error: Unmanaged<CFError>?
        guard let decrypted = SecKeyCreateDecryptedData(key, .rsaEncryptionOAEPSHA1,
                                                        data as CFData, &error),
                let decryptedString = String(data: decrypted as Data, encoding: .utf8) else {
            throw CryptographyError.decryptionFailed
        }

        return decryptedString
    }

    func decrypt<T: Decodable>(base64String: String, privateKey: String) throws -> T {
        let decryptedString = try decrypt(base64String: base64String, privateKey: privateKey)
        guard let encodedData = decryptedString.data(using: .utf8),
              let model = try? JSONDecoder.decoder.decode(T.self, from: encodedData) else {
            throw CryptographyError.modelDecodingFailed
        }
        return model
    }
}
