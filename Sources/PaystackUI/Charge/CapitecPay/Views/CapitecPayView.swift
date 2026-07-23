import SwiftUI

@available(iOS 14.0, *)
struct CapitecPayView: View {

    @StateObject
    var viewModel: CapitecPayViewModel

    init(chargeContainer: ChargeContainer,
         transactionDetails: VerifyAccessCode,
         config: CapitecPayConfig) {
        self._viewModel = StateObject(wrappedValue: CapitecPayViewModel(
            chargeContainer: chargeContainer,
            transactionDetails: transactionDetails,
            config: config))
    }

    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.state {
            case .identifierEntry:
                CapitecPayIdentifierEntryView(
                    viewModel: viewModel,
                    amount: viewModel.transactionDetails.amountCurrency,
                    onChangePaymentMethod: viewModel.userTappedChangePaymentMethod)
            case .authenticating:
                LoadingView(message: "Starting your Capitec Pay payment…")
            case .awaitingApproval:
                CapitecPayAwaitingApprovalView(
                    remainingSeconds: viewModel.remainingSeconds,
                    isRequerying: false,
                    onIveApprovedThePayment: viewModel.userTappedIveApprovedThePayment,
                    onChangePaymentMethod: viewModel.userTappedChangePaymentMethod)
            case .requerying:
                CapitecPayAwaitingApprovalView(
                    remainingSeconds: 0,
                    isRequerying: true,
                    onIveApprovedThePayment: viewModel.userTappedIveApprovedThePayment,
                    onChangePaymentMethod: viewModel.userTappedChangePaymentMethod)
            case .error(let error):
                ErrorView(message: error.message,
                          buttonText: "Try again",
                          buttonAction: { viewModel.state = .identifierEntry })
            case .fatalError(let error):
                ErrorView(message: error.message,
                          automaticallyDismissWith: .init(
                            error: error,
                            transactionReference: viewModel.transactionDetails.reference))
            }
        }
    }
}
