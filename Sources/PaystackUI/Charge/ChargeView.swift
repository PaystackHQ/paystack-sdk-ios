import SwiftUI
import PaystackCore

@available(iOS 14.0, *)
struct ChargeView: View {

    @StateObject
    var viewModel: ChargeViewModel

    @EnvironmentObject
    var visibilityContainer: ViewVisibilityContainer

    init(accessCode: String, paystack: Paystack) {
        self._viewModel = StateObject(
            wrappedValue: ChargeViewModel(
                accessCode: accessCode,
                repository: ChargeRepositoryImplementation(paystack: paystack)))
    }

    var body: some View {
        VStack {
            if viewModel.centerView {
                Spacer()
            }

            if viewModel.inTestMode {
                TestModeInidcator()
            }

            switch viewModel.transactionState {
            case .loading(let message):
                LoadingView(message: message)
            case .error:
                Text("TODO")
            case .payment(let type):
                paymentFlowView(for: type)
            case .success(let amount, let merchant):
                ChargeSuccessView(amount: amount, merchant: merchant)
            }

            Spacer()

            Image.paystackSecured
                .aspectRatio(contentMode: .fit)
                .frame(width: 140)
        }
        .task(viewModel.verifyAccessCodeAndProceedWithCard)
        .modalCancelButton(showConfirmation: viewModel.displayCloseButtonConfirmation,
                           onCancelled: chargeCancelled)
    }

    @ViewBuilder
    func paymentFlowView(for type: ChargePaymentType) -> some View {
        switch type {
        case .card(let transactionInformation):
            ChargeCardView(transactionDetails: transactionInformation)
        }
    }

    func chargeCancelled() {
        switch viewModel.transactionState {
        case .success:
            visibilityContainer.completeAndDismiss(with: .success)
        default:
            visibilityContainer.cancelAndDismiss()
        }
    }
}
