import SwiftUI

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
        .frame(height: .buttonHeight)
        .frame(maxWidth: .infinity)
        .font(.body16M)
        .background(configuration.isPressed ? pressedBackground : background)
        .foregroundColor(configuration.isPressed ? pressedForeground : foreground)
        .cornerRadius(.cornerRadius)
        .disabled(showLoading)
    }

}

@available(iOS 14.0, *)
extension PrimaryButtonStyle {

    var background: Color {
        isEnabled ? .stackGreen : .stackGreen.opacity(0.6)
    }

    var pressedBackground: Color {
        .stackGreen.opacity(0.75)
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
