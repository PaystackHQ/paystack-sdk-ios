import Foundation
import SwiftUI

class SimpleValidator: FormValidator {

    var validation: () -> Bool
    var errorMessage: String

    init(errorMessage: String, validation: @escaping () -> Bool) {
        self.validation = validation
        self.errorMessage = errorMessage
    }

    func validate() -> Bool {
        return validation()
    }
}

extension SimpleValidator {

    static func required(_ text: String, errorMessage: String) -> SimpleValidator {
        return SimpleValidator(errorMessage: errorMessage) {
            !text.isEmpty
        }
    }

    static func required<T>(_ optional: T?, errorMessage: String) -> SimpleValidator {
        return SimpleValidator(errorMessage: errorMessage) {
            optional != nil
        }
    }

    static func required<T>(_ array: [T], errorMessage: String) -> SimpleValidator {
        return SimpleValidator(errorMessage: errorMessage) {
            !array.isEmpty
        }
    }

    static func minLength(_ length: Int, text: String, errorMessage: String) -> SimpleValidator {
        return SimpleValidator(errorMessage: errorMessage) {
            text.count >= length
        }
    }

    static func greaterThan(_ number: Double, text: String, errorMessage: String) -> SimpleValidator {
        return SimpleValidator(errorMessage: errorMessage) {
            guard let amount = Double(text) else {
                return false
            }

            return amount > number
        }
    }

    static func lessThan(_ number: Double, text: String, errorMessage: String) -> SimpleValidator {
        return SimpleValidator(errorMessage: errorMessage) {
            guard let amount = Double(text) else {
                return false
            }

            return amount < number
        }
    }
}
