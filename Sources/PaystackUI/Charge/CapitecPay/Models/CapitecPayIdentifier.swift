import Foundation

enum CapitecPayIdentifier: String, CaseIterable, Equatable, CustomStringConvertible {
    case cellphone     = "CELLPHONE"
    case idNumber      = "IDNUMBER"
    case accountNumber = "ACCOUNTNUMBER"

    var pickerTitle: String {
        switch self {
        case .cellphone:     return "Cellphone Number"
        case .idNumber:      return "ID Number"
        case .accountNumber: return "Account Number"
        }
    }

    var description: String { pickerTitle }

    var prompt: String {
        switch self {
        case .cellphone:
            return "Enter the mobile number linked to your Capitec account"
        case .idNumber:
            return "Enter the ID number linked to your Capitec account"
        case .accountNumber:
            return "Enter the account number linked to your Capitec account"
        }
    }

    var placeholder: String {
        switch self {
        case .cellphone:     return "Enter your cellphone number"
        case .idNumber:      return "Enter your ID number"
        case .accountNumber: return "Enter your account number"
        }
    }
}
