import SwiftUI

// TODO: Replace constants and colors from design system
@available(iOS 15, macOS 12.0, *)
struct TextFieldFocusedBorder: ViewModifier {

    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isFocused ?  Color.green : Color.gray, lineWidth: 1)
            )
    }
}

extension View {

    @ViewBuilder
    func focusedBorderColor() -> some View {
        if #available(iOS 15, macOS 12.0, *) {
            self.modifier(TextFieldFocusedBorder())
        } else {
            self.background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
    }
}
