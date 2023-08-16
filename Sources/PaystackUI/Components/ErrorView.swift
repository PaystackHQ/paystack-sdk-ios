import SwiftUI

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
        VStack(spacing: .doublePadding) {
            Image.errorIcon

            Text(message)
                .font(.body16M)
                .foregroundColor(.stackBlue)
                .padding(.bottom, .singlePadding)

            Button(buttonText, action: buttonAction)
                .buttonStyle(SecondaryButtonStyle())
        }
        .padding(.doublePadding)
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
