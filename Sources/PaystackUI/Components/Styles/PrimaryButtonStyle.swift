import SwiftUI

// TODO: Move this to the design system and replace colors/fonts
@available(iOS 14.0, *)
struct PrimaryButtonStyle: ButtonStyle {

    @Environment(\.isEnabled)
    var isEnabled

    var showLoading: Bool

    init(showLoading: Bool = false) {
        self.showLoading = showLoading
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            if showLoading {
                LoadingIndicator(tintColor: foreground)
            } else {
                configuration.label
            }
        }
        .padding()
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .font(.body)
        .background(configuration.isPressed ? pressedBackground : background)
        .foregroundColor(configuration.isPressed ? pressedForeground : foreground)
        .cornerRadius(8)
        .disabled(showLoading)
    }

}

// TODO: These values are all incorrect and will be pulled from Design when available
@available(iOS 14.0, *)
extension PrimaryButtonStyle {

    var background: Color {
        isEnabled ? .green : .gray
    }

    var pressedBackground: Color {
        .green.opacity(0.75)
    }

    var foreground: Color {
        .white
    }

    var pressedForeground: Color {
        .white.opacity(0.75)
    }

}

@available(iOS 14.0, *)
struct PrimaryButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button("Example", action: {})
            .buttonStyle(PrimaryButtonStyle(showLoading: false))
            .padding()
    }
}
