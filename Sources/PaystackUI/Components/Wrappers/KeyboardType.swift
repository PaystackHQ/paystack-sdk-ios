import Foundation
import SwiftUI

enum KeyboardType {
    case `default`
    case asciiCapable
    case numbersAndPunctuation
    case URL
    case numberPad
    case phonePad
    case namePhonePad
    case emailAddress
    case decimalPad
    case twitter
    case webSearch
    case asciiCapableNumberPad

    #if os(iOS)
    var mapToUIKeyboardType: UIKeyboardType {
        switch self {
        case .default:
            return .default
        case .asciiCapable:
            return .asciiCapable
        case .numbersAndPunctuation:
            return .numbersAndPunctuation
        case .URL:
            return .URL
        case .numberPad:
            return .numberPad
        case .phonePad:
            return .phonePad
        case .namePhonePad:
            return .namePhonePad
        case .emailAddress:
            return .emailAddress
        case .decimalPad:
            return .decimalPad
        case .twitter:
            return .twitter
        case .webSearch:
            return .webSearch
        case .asciiCapableNumberPad:
            return .asciiCapableNumberPad
        }
    }
    #endif
}

extension View {
    func keyboardType(_ keyboard: KeyboardType) -> some View {
        #if os(iOS)
        return keyboardType(keyboard.mapToUIKeyboardType)
        #else
        return self
        #endif
    }
}
