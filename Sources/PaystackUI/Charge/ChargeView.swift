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
            switch viewModel.transactionState {
            case .loading(let message):
                LoadingView(message: message)
            case .error:
                Text("TODO")
            case .cardDetails(let verifyAccessCode):
               CardDetailsView(transactionDetails: verifyAccessCode)
            }

            if viewModel.displaySecuredByPaystack {
                Image.paystackSecured
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140)
            }

            Spacer()
        }
        .task(viewModel.verifyAccessCodeAndProceedWithCard)
        .modalCancelButton(onCancelled: chargeCancelled)
    }

    func chargeCancelled() {
        visibilityContainer.cancelAndDismiss()
    }
}
