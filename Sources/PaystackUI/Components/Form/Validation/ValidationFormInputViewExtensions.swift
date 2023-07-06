import SwiftUI

@available(iOS 14.0, *)
extension TextFieldFormInputView {

    func required(errorMessage: String) -> some FormInputItemView {
        let validator = SimpleValidator.required($text.wrappedValue, errorMessage: errorMessage)
        return ValidationFormInputView(validator: validator, errorState: $inErrorState) {
            self
        }
    }

    func required<T>(optional: Binding<T?>, errorMessage: String) -> some FormInputItemView {
        let validator = SimpleValidator.required(optional.wrappedValue, errorMessage: errorMessage)
        return ValidationFormInputView(validator: validator, errorState: $inErrorState) {
            self
        }
    }

    func required<T>(array: Binding<[T]>, errorMessage: String) -> some FormInputItemView {
        let validator = SimpleValidator.required(array.wrappedValue, errorMessage: errorMessage)
        return ValidationFormInputView(validator: validator, errorState: $inErrorState) {
            self
        }
    }

    func minLength(_ minLength: Int, errorMessage: String) -> some FormInputItemView {
        let validator = SimpleValidator.minLength(minLength,
                                                  text: $text.wrappedValue,
                                                  errorMessage: errorMessage)
        return ValidationFormInputView(validator: validator, errorState: $inErrorState) {
            self
        }
    }

    func greaterThan(_ number: Double, errorMessage: String) -> some FormInputItemView {
        let validator = SimpleValidator.greaterThan(number,
                                                    text: $text.wrappedValue,
                                                    errorMessage: errorMessage)
        return ValidationFormInputView(validator: validator, errorState: $inErrorState) {
            self
        }
    }

    func greaterThanZero(errorMessage: String) -> some FormInputItemView {
        return greaterThan(.zero, errorMessage: errorMessage)
    }

    func greaterThanOrEqualTo(_ number: Double, errorMessage: String) -> some FormInputItemView {
        return greaterThan(number + 1, errorMessage: errorMessage)
    }

    func lessThanOrEqualTo(_ number: Double, errorMessage: String) -> some FormInputItemView {
        let validator = SimpleValidator.lessThan(number + 1,
                                                 text: $text.wrappedValue,
                                                 errorMessage: errorMessage)
        return ValidationFormInputView(validator: validator, errorState: $inErrorState) {
            self
        }
    }

    func validateCardNumber(errorMessage: String) -> some FormInputItemView {
        let validator = CardInfoValidator.cardNumber($text.wrappedValue, errorMessage: errorMessage)
        return ValidationFormInputView(validator: validator, errorState: $inErrorState) {
            self
        }
    }

    func validateExpiry(errorMessage: String) -> some FormInputItemView {
        let validator = CardInfoValidator.cardExpiry($text.wrappedValue, errorMessage: errorMessage)
        return ValidationFormInputView(validator: validator, errorState: $inErrorState) {
            self
        }
    }

    func multipleValidations(text: Binding<String>, inErrorState: Binding<Bool>,
                             validators: [FormValidator]) -> some FormInputItemView {
        return ValidationFormInputView(validators: validators, errorState: $inErrorState) {
            self
        }
    }
}
