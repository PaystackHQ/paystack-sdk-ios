import SwiftUI
import Combine

struct ValidationFormInputView<Content: FormInputItemView>: FormInputItemViewModifier {

    var validators: [FormValidator]

    @State
    var validatorStates: [Bool] = [false]

    @ViewBuilder
    var content: Content

    @Binding
    var isInErrorState: Bool

    init(validator: FormValidator, errorState: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.validators = [validator]
        self.content = content()
        self._isInErrorState = errorState
    }

    init(validators: [FormValidator], errorState: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.validators = validators
        self.content = content()
        self._isInErrorState = errorState
    }

    var validateContent = PassthroughSubject<Void, Never>()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content

            if isInErrorState {
                ForEach(Array(zip(validators.indices, validators)), id: \.0) { index, validator in
                    if !validatorStates[index] {
                        Text(validator.errorMessage)
                            .font(.body12R)
                            .foregroundColor(.error01)
                    }
                }
            }
        }
        .onReceive(validateContent) { _ in
            validate()
        }
    }

}

extension ValidationFormInputView {

    func validate() {
        content.submit.forEach { $0.send() }
        withAnimation {
            validatorStates = validators.map { $0.validate() }
            // swiftlint:disable:next reduce_boolean
            let allValidationsPassed = validatorStates.reduce(true) { $1 && $0 }
            isInErrorState = !allValidationsPassed
        }
    }

    var submit: [PassthroughSubject<Void, Never>] {
        return [validateContent] + content.submit
    }

    var isValid: [FormValidator] {
        return validators + content.isValid
    }

}
