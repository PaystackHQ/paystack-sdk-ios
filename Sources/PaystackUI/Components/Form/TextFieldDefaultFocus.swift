import SwiftUI

@available(iOS 15, macOS 12.0, *)
struct TextFieldDefaultFocus: ViewModifier {

    @FocusState
    private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .onAppear(perform: setDefaultFocus)
    }

    func setDefaultFocus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.isFocused = true
        }
    }
}

@available(iOS 14.0, *)
extension View {

    @ViewBuilder
    func setDefaultFocus(_ shouldFocus: Bool) -> some View {
        if #available(iOS 15, macOS 12.0, *), shouldFocus {
            self.modifier(TextFieldDefaultFocus())
        } else {
            self
        }
    }
}
