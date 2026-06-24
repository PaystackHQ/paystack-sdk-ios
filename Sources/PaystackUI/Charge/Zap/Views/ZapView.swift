import SwiftUI


@available(iOS 14.0, *)
struct ZapView: View {

    @StateObject
    var viewModel: ZapViewModel

    init(chargeContainer: ChargeContainer,
         transactionDetails: VerifyAccessCode,
         config: ZapConfig) {
        self._viewModel = StateObject(wrappedValue: ZapViewModel(
            chargeContainer: chargeContainer,
            transactionDetails: transactionDetails,
            config: config))
    }

    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.state {
            case .loading(let message):
                LoadingView(message: message)
            case .awaitingPayment(let details):
                ZapPaymentView(
                    details: details,
                    remainingSeconds: viewModel.remainingSeconds,
                    onChangePaymentMethod: viewModel.userTappedChangePaymentMethod,
                    showsOpenZapButton: ZapViewModel.showsOpenZapButton)
            case .sessionExpired:
                ZapSessionExpiredView(
                    message: ZapViewModel.sessionExpiredCopy,
                    onTryAgain: { await viewModel.retryAfterExpiry() })
            case .error(let error):
                ErrorView(message: error.message,
                          buttonText: "Try again",
                          buttonAction: { Task { await viewModel.initiateMandate() } })
            case .fatalError(let error):
                ErrorView(message: error.message,
                          automaticallyDismissWith: .init(
                            error: error,
                            transactionReference: viewModel.transactionDetails.reference))
            }
        }
        .task(viewModel.initiateMandate)
    }
}
