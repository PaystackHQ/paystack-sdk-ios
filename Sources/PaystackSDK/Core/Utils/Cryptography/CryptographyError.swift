enum CryptographyError: Error {
    case invalidBase64String
    case asn1ParsingFailed
    case invalidAsn1RootNode
    case invalidAsn1Structure
    case keyCreationFailed
    case encryptionFailed
    case decryptionFailed
    case modelEncodingFailed
    case modelDecodingFailed
}
