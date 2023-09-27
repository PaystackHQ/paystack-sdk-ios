import SwiftUI

@available(iOS 14.0, *)
struct ErrorView: View {

    var message: String
    var buttonText: String?
    var buttonAction: (() -> Void)?
    var dismissWithError: ChargeErrorDetails?

    @EnvironmentObject
    var visibilityContainer: ViewVisibilityContainer

    init(message: String,
         buttonText: String? = nil,
         buttonAction: (() -> Void)? = nil,
         automaticallyDismissWith errorDetails: ChargeErrorDetails? = nil) {
        self.message = message
        self.buttonText = buttonText
        self.buttonAction = buttonAction
        self.dismissWithError = errorDetails
    }

    var body: some View {
        VStack(spacing: .doublePadding) {
            Image.errorIcon

            Text(message)
                .font(.body16M)
                .foregroundColor(.stackBlue)
                .padding(.bottom, .singlePadding)

            if let buttonText, let buttonAction {
                Button(buttonText, action: buttonAction)
                    .buttonStyle(SecondaryButtonStyle())
            }

        }
        .padding(.doublePadding)
        .task(dismissIfNecessary)
    }

    func dismissIfNecessary() async {
        guard let errorDetails = dismissWithError else { return }
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        visibilityContainer.completeAndDismiss(with: .error(error: errorDetails.error,
                                                            reference: errorDetails.transactionReference))
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
