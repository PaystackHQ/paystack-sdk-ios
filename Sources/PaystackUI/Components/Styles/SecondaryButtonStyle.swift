import SwiftUI

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
        .frame(height: .buttonHeight)
        .frame(maxWidth: .infinity)
        .font(.body16M)
        .background(
            RoundedRectangle(cornerRadius: .cornerRadius, style: .continuous)
                .stroke(configuration.isPressed ?
                        border : pressedBorder, lineWidth: 1)
        )
        .foregroundColor(configuration.isPressed ? pressedForeground : foreground)
        .cornerRadius(.cornerRadius)
        .disabled(showLoading)
    }

}

// TODO: Remove pressed states if we later decided that they will be
@available(iOS 14.0, *)
extension SecondaryButtonStyle {

    var border: Color {
        .green02
    }

    var pressedBorder: Color {
        .green02
    }

    var foreground: Color {
        .green02
    }

    var pressedForeground: Color {
        .green02
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
