import XCTest
@testable import PaystackCore

final class CryptographyTests: XCTestCase {
    var serviceUnderTest: Cryptography!
    let publicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCeCnSCpcVRhP5cvJ8HNTzax/Lw17ERVTS/wafBTLlJ0BxT+WGwy2OfdIshAroiZfSAWfFKFhF9KbKJvcyPGQ4oDibSbN/YriHmKxQt2CP6l3X0A7wHzSRLD4QR2DaqcA+blrm0szZQ5/8goyK+JDlyHrsSck/AVzm4S2zQ8FEEIQIDAQAB"

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
        let clearText = [String](repeating: "a", count: 117).joined(separator: "")

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
        let dataEncryptedWithDifferentKey = "c49dou2gFV2kLQQrSncNbARFUSfronZtMoumWZTmd7ALXiAxiwwKT08iG58WtgfAqfEBYHFw0riD3aKj0iwVxKLdw3TIX5eoJVXME9IO6JXRUjnshlwSMqNL3pZ3+yDIosxvGPUK8XE5anajO5y3TekaG6OqG46EtiLiAoZJ+/s="

        XCTAssertThrowsError(try serviceUnderTest.decrypt(base64String: dataEncryptedWithDifferentKey,
                                                          privateKey: privateKey)) { error in
            XCTAssertEqual(error as? CryptographyError, CryptographyError.decryptionFailed)
        }
    }

    func testStandaloneDecryptionWithMatchingPrivateKey() {
        let encryptedData = "UoeZtFlZgBu5j6OzH+5qKeDMAklJ6dyo/2fCYzY0MmifDqQHx81ZzO1GRjYXvKehgZRfU7dwcr8behWHFiHC/BS0X0h25rEtoaH4+2ddkfMGmhVHcIYSyQWzPhabD5rIGZdfPQnHCdNx6OR4lraGM6C0ngraMdSNQifiXe6+qfU="
        guard let decryptedString = try? serviceUnderTest.decrypt(base64String: encryptedData,
                                                                  privateKey: privateKey) else {
            XCTFail("Decryption failed")
            return
        }

        let expectedValue = "Hello World"
        XCTAssertEqual(expectedValue, decryptedString)
    }

}
