import SwiftUI

// TODO: Replace constants and colors from design system
@available(iOS 15, macOS 12.0, *)
struct TextFieldFocusedBorder: ViewModifier {

    var defaultColor: Color

    @FocusState
    private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isFocused ?  Color.green : defaultColor, lineWidth: 1)
            )
    }
}

extension View {

    @ViewBuilder
    func focusedBorderColor(defaultColor: Color = .gray) -> some View {
        if #available(iOS 15, macOS 12.0, *) {
            self.modifier(TextFieldFocusedBorder(defaultColor: defaultColor))
        } else {
            self.background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(defaultColor, lineWidth: 1)
            )
        }
    }
}
