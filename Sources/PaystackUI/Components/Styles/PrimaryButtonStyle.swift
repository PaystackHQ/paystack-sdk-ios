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
        isEnabled ? .accentPrimary : .accentPrimaryDisabled
    }

    var pressedBackground: Color {
        .accentPrimaryPressed
    }

    var foreground: Color {
        .contentOnAccent
    }

    var pressedForeground: Color {
        .contentOnAccentPressed
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

@available(iOS 14.0, *)
struct PaymentChannelSelectionButton: ButtonStyle {

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
        .focusedBorderColor(defaultColor: .borderSubtle)
        .font(.body16M)
        .background(configuration.isPressed ? pressedBackground : background)
        .foregroundColor(configuration.isPressed ? pressedForeground : foreground)
        .cornerRadius(.cornerRadius)
        .disabled(showLoading)
    }

}

@available(iOS 14.0, *)
extension PaymentChannelSelectionButton {

    var background: Color {
        isEnabled ? .accentPrimary : .accentPrimaryDisabled
    }

    var pressedBackground: Color {
        .accentPrimaryPressed
    }

    var foreground: Color {
        .contentOnAccent
    }

    var pressedForeground: Color {
        .contentOnAccentPressed
    }

}

@available(iOS 14.0, *)
struct PaymentChannelSelectionButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("Example", action: {})
            .buttonStyle(PrimaryButtonStyle(showLoading: false))
            .padding()
    }
}
