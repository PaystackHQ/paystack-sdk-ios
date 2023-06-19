import SwiftUI
import PaystackCore

@available(iOS 14.0, *)
struct ChargeView: View {

    @StateObject
    var viewModel: ChargeViewModel

    init(accessCode: String, paystack: Paystack) {
        self._viewModel = StateObject(
            wrappedValue: ChargeViewModel(
                accessCode: accessCode,
                repository: ChargeRepositoryImplementation(paystack: paystack)))
    }

    var body: some View {
        VStack {
            switch viewModel.transactionState {
            case .loading:
                Text("TODO")
            case .error:
                Text("TODO")
            case .cardDetails(let verifyAccessCode):
                Text("TODO")
            }
        }
        .task(viewModel.verifyAccessCodeAndProceedWithCard)
    }
}
