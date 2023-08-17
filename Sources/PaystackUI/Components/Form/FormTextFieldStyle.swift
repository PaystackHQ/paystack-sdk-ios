import SwiftUI

struct FormTextFieldStyle: TextFieldStyle {

    // swiftlint:disable:next identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.doublePadding)
            .foregroundColor(.stackBlue)
            .font(.body16R)
    }
}

extension TextFieldStyle where Self == FormTextFieldStyle {

    static var form: Self {
        return .init()
    }
}
