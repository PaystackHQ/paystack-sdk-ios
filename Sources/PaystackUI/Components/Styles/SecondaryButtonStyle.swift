import SwiftUI

// TODO: Move this to the design system and replace colors/fonts
@available(iOS 14.0, *)
struct SecondaryButtonStyle: ButtonStyle {

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
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(configuration.isPressed ?
                        border : pressedBorder, lineWidth: 1)
        )
        .foregroundColor(configuration.isPressed ? pressedForeground : foreground)
        .cornerRadius(8)
        .disabled(showLoading)
    }

}

// TODO: These values are all incorrect and will be pulled from Design when available
// TODO: Remove pressed states if we later decided that they will be
@available(iOS 14.0, *)
extension SecondaryButtonStyle {

    var border: Color {
        .green
    }

    var pressedBorder: Color {
        .green
    }

    var foreground: Color {
        .green
    }

    var pressedForeground: Color {
        .green
    }

}

@available(iOS 14.0, *)
struct SecondaryButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button("Example", action: {})
            .buttonStyle(SecondaryButtonStyle(showLoading: false))
            .padding()
    }
}
