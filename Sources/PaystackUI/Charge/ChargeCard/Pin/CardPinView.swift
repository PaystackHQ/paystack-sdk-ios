import SwiftUI

@available(iOS 14.0, *)
// TODO: Replace constants and colors from design system
struct CardPinView: View {

    @StateObject
    var viewModel: CardPinViewModel

    init(chargeCardContainer: ChargeCardContainer) {
        self._viewModel = StateObject(wrappedValue: CardPinViewModel(
            chargeCardContainer: chargeCardContainer))
    }

    var body: some View {
        VStack(spacing: 24) {
            titleText

            #if os(iOS)
            if viewModel.showLoading {
                loadingView
            } else {
                PinTextView(text: $viewModel.pinText,
                            isSecureTextEntry: true) {
                    viewModel.submitPin()
                }

                Button("Cancel", action: viewModel.cancelTransaction)
                    .foregroundColor(.gray)
            }
            #endif

        }
        .padding(16)
    }

    var titleText: some View {
        Text("Please enter your 4-digit card pin to authorize this payment")
            .font(.headline)
            .multilineTextAlignment(.center)
    }

    var loadingView: some View {
        LoadingIndicator(tintColor: .gray)
            .scaleEffect(2)
            .padding(16)
    }
}

@available(iOS 14.0, *)
struct CardPinView_Previews: PreviewProvider {
    static var previews: some View {
        CardPinView(chargeCardContainer: ChargeCardViewModel(
            transactionDetails: .example))
    }
}
