import SwiftUI

@available(iOS 15, macOS 12.0, *)
struct TextFieldFocusedBorder: ViewModifier {

    var defaultColor: Color

    @FocusState
    private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .background(
                RoundedRectangle(cornerRadius: .cornerRadius, style: .continuous)
                    .stroke(isFocused ?  Color.stackGreen : defaultColor, lineWidth: 1)
            )
    }
}

extension View {

    @ViewBuilder
    func focusedBorderColor(defaultColor: Color = .navy04) -> some View {
        if #available(iOS 15, macOS 12.0, *) {
            self.modifier(TextFieldFocusedBorder(defaultColor: defaultColor))
        } else {
            self.background(
                RoundedRectangle(cornerRadius: .cornerRadius, style: .continuous)
                    .stroke(defaultColor, lineWidth: 1)
            )
        }
    }
}
