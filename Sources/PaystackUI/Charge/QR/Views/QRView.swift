import SwiftUI
import PaystackCore

@available(iOS 14.0, *)
struct QRView: View {

    @StateObject
    var viewModel: QRViewModel

    init(chargeContainer: ChargeContainer,
         transactionDetails: VerifyAccessCode,
         config: QRConfig) {
        self._viewModel = StateObject(wrappedValue: QRViewModel(
            chargeContainer: chargeContainer,
            transactionDetails: transactionDetails,
            config: config))
    }

    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.state {
            case .loadingQR:
                LoadingView(message: "Generating your QR code…")
            case .awaitingScan(let details):
                QRDisplayView(
                    variant: viewModel.variant,
                    details: details,
                    amount: viewModel.transactionDetails.amountCurrency,
                    inlineBanner: viewModel.inlineBanner,
                    onICompletedPayment: viewModel.userTappedICompletedPayment,
                    onChangePaymentMethod: viewModel.userTappedChangePaymentMethod)
            case .verifying:
                LoadingView(message: "Verifying your payment…")
            case .error(let error):
                ErrorView(message: error.message,
                          buttonText: "Try again",
                          buttonAction: { Task { await viewModel.retry() } })
            case .fatalError(let error):
                ErrorView(message: error.message,
                          automaticallyDismissWith: .init(
                            error: error,
                            transactionReference: viewModel.transactionDetails.reference))
            }
        }
        .task { await viewModel.onAppear() }
    }
}
