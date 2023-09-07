import SwiftUI

@available(iOS 14.0, *)
struct CardPinView: View {

    @StateObject
    var viewModel: CardPinViewModel

    init(encryptionKey: String, chargeCardContainer: ChargeCardContainer) {
        self._viewModel = StateObject(wrappedValue: CardPinViewModel(
            encryptionKey: encryptionKey, chargeCardContainer: chargeCardContainer))
    }

    var body: some View {
        VStack(spacing: .triplePadding) {
            titleText

            #if os(iOS)
            if viewModel.showLoading {
                loadingView
            } else {
                PinTextView(text: $viewModel.pinText,
                            isSecureTextEntry: true,
                            onCommit: viewModel.submitPin)

                Button("Cancel", action: viewModel.cancelTransaction)
                    .foregroundColor(.navy02)
                    .font(.body14M)
            }
            #endif

        }
        .padding(.doublePadding)
    }

    var titleText: some View {
        Text("Please enter your 4-digit card pin to authorize this payment")
            .font(.body16M)
            .foregroundColor(.stackBlue)
            .multilineTextAlignment(.center)
    }

    var loadingView: some View {
        LoadingIndicator(tintColor: .navy04)
            .scaleEffect(2)
            .padding(.doublePadding)
    }
}

@available(iOS 14.0, *)
struct CardPinView_Previews: PreviewProvider {
    static var previews: some View {
        CardPinView(encryptionKey: "test_encryption_key",
                    chargeCardContainer: ChargeCardViewModel(
            transactionDetails: .example,
            chargeContainer: ChargeViewModel(accessCode: "access_code")))
    }
}
