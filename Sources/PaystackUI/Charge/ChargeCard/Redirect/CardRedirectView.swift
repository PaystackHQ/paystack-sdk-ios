import SwiftUI

@available(iOS 14.0, *)
struct CardRedirectView: View {

    let urlString: String

    @StateObject
    var viewModel: CardRedirectViewModel

    @State
    var webviewLoading = false

    init(urlString: String,
         transactionId: Int,
         chargeCardContainer: ChargeCardContainer) {
        self.urlString = urlString
        self._viewModel = StateObject(wrappedValue: CardRedirectViewModel(
            transactionId: transactionId, chargeCardContainer: chargeCardContainer))
    }

    var body: some View {
        if viewModel.displayWebview {
            webview
        } else {
            authenticationInitializationView
        }
    }

    var webview: some View {
        ZStack {
            WebView(url: URL(string: urlString),
                    isLoading: $webviewLoading)

            if webviewLoading {
                LoadingIndicator(tintColor: .navy04)
                    .scaleEffect(2)
            }
        }
    }

    var authenticationInitializationView: some View {
        VStack(spacing: .triplePadding) {
            Image.redirectIcon
            titleText
            primaryButton
            cancelButton
        }
        .padding(.doublePadding)
    }

    var titleText: some View {
        Text("Please click the button below to authenticate with your bank")
            .font(.body16M)
            .foregroundColor(.stackBlue)
            .multilineTextAlignment(.center)
    }

    var primaryButton: some View {
        Button("Authenticate", action: authenticateWithBank)
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, .doublePadding)
            .padding(.top, .singlePadding)
    }

    var cancelButton: some View {
        Button("Cancel", action: viewModel.cancelTransaction)
            .foregroundColor(.navy02)
            .font(.body14M)
    }

    private func authenticateWithBank() {
        Task {
            await viewModel.initiateAndAwaitBankAuthentication()
        }
    }
}

@available(iOS 14.0, *)
struct CardRedirectView_Previews: PreviewProvider {
    static var previews: some View {
        CardRedirectView(urlString: "testUrlString",
                         transactionId: 123,
                         chargeCardContainer: ChargeCardViewModel(
                            transactionDetails: .example,
                            chargeContainer: ChargeViewModel(accessCode: "access_code")))
    }
}
