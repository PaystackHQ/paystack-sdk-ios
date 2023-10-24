import Foundation

struct Cryptography {

    func encrypt(text: String, publicKey: String) throws -> String {
        let key = try createKey(from: publicKey, isPublic: true)

        var encryptionError: Unmanaged<CFError>?
        guard let textData = text.data(using: .utf8),
              let encryptedData = SecKeyCreateEncryptedData(key, .rsaEncryptionOAEPSHA1,
                                                            textData as CFData, &encryptionError) as Data? else {
            throw CryptographyError.encryptionFailed
        }
        return encryptedData.base64EncodedString()
    }

    func encrypt<T: Encodable>(model: T, publicKey: String) throws -> String {
        let encodedModel = try JSONEncoder.encoder.encode(model)
        guard let jsonString = String(data: encodedModel, encoding: .utf8) else {
            throw CryptographyError.modelEncodingFailed
        }
        return try encrypt(text: jsonString, publicKey: publicKey)
    }
}

// MARK: - Preparing Key
extension Cryptography {
    func createKey(from key: String, isPublic: Bool) throws -> SecKey {
        guard let keyData = Data(base64Encoded: key,
                                 options: [.ignoreUnknownCharacters]) else {
            throw CryptographyError.invalidBase64String
        }

        return try createKey(from: keyData, isPublic: isPublic)
    }

    private func createKey(from data: Data, isPublic: Bool) throws -> SecKey {
        let headerlessData = try stripKeyHeader(keyData: data)
        let keyClass = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate

        let sizeInBits = headerlessData.count * 8
        let keyDict: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: keyClass,
            kSecAttrKeySizeInBits: NSNumber(value: sizeInBits),
            kSecReturnPersistentRef: true
        ]

        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(headerlessData as CFData,
                                             keyDict as CFDictionary, &error) else {
            throw CryptographyError.keyCreationFailed
        }
        return key
    }

    // This code is sourced from SwiftyRSA project https://github.com/TakeScoop/SwiftyRSA published under the MIT Licence
    private func stripKeyHeader(keyData: Data) throws -> Data {

        let node: Asn1Parser.Node
        do {
            node = try Asn1Parser.parse(data: keyData)
        } catch {
            throw CryptographyError.asn1ParsingFailed
        }

        // Ensure the raw data is an ASN1 sequence
        guard case .sequence(let nodes) = node else {
            throw CryptographyError.invalidAsn1RootNode
        }

        // Detect whether the sequence only has integers, in which case it's a headerless key
        let onlyHasIntegers = nodes.filter { node -> Bool in
            if case .integer = node {
                return false
            }
            return true
        }.isEmpty

        // Headerless key
        if onlyHasIntegers {
            return keyData
        }

        // If last element of the sequence is a bit string, return its data
        if let last = nodes.last, case .bitString(let data) = last {
            return data
        }

        // If last element of the sequence is an octet string, return its data
        if let last = nodes.last, case .octetString(let data) = last {
            return data
        }

        // Unable to extract bit/octet string or raw integer sequence
        throw CryptographyError.invalidAsn1Structure
    }
}
