import SwiftUI

// TODO: Replace constants and colors from design system
// Note: When we drop UI Support for iOS 14, we should clean this up to remove the conditionals
struct FormTextFieldStyle: TextFieldStyle {

    // swiftlint:disable:next identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .foregroundColor(.black)
            .font(.body)
    }
}

extension TextFieldStyle where Self == FormTextFieldStyle {

    static var form: Self {
        return .init()
    }
}
