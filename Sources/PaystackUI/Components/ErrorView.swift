import SwiftUI

// TODO: Move this to the design system and replace colors/fonts
@available(iOS 14.0, *)
struct ErrorView: View {

    var message: String
    var buttonText: String
    var buttonAction: () -> Void

    init(message: String, buttonText: String, buttonAction: @escaping () -> Void) {
        self.message = message
        self.buttonText = buttonText
        self.buttonAction = buttonAction
    }

    var body: some View {
        VStack(spacing: 16) {
            Image.errorIcon

            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)

            Button(buttonText, action: buttonAction)
                .buttonStyle(SecondaryButtonStyle())
        }
        .padding(16)
    }
}

@available(iOS 14.0, *)
struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(message: "Street address does not match",
                  buttonText: "Try another card",
                  buttonAction: {})
    }
}
