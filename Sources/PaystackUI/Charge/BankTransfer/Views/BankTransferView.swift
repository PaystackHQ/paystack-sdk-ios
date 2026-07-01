import SwiftUI

@available(iOS 14.0, *)
struct BankTransferView: View {

    @StateObject
    var viewModel: BankTransferViewModel

    init(chargeContainer: ChargeContainer,
         transactionDetails: VerifyAccessCode,
         config: BankTransferConfig) {
        self._viewModel = StateObject(wrappedValue: BankTransferViewModel(
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
                BankTransferAccountDetailsView(
                    details: details,
                    amount: viewModel.transactionDetails.amountCurrency,
                    provider: viewModel.config.provider,
                    onIveSentTheMoney: { await viewModel.userTappedIveSentTheMoney() },
                    onChangePaymentMethod: viewModel.userTappedChangePaymentMethod)
                    .id(details.transactionReference)
            case .confirmingPayment(let details, let phase):
                BankTransferConfirmingView(
                    details: details,
                    phase: phase,
                    confirmationWindowSeconds: viewModel.confirmationWindowSeconds,
                    elapsedSeconds: viewModel.confirmationElapsedSeconds,
                    onBackToAccountNumber: viewModel.userTappedBackToAccountNumber,
                    onChangePaymentMethod: viewModel.userTappedChangePaymentMethod)
            case .takingLongerThanExpected(let details):
                BankTransferTakingLongerView(
                    details: details,
                    onGetHelp: viewModel.userTappedGetHelp,
                    onBackToAccountNumber: viewModel.userTappedBackToAccountNumber,
                    onChangePaymentMethod: viewModel.userTappedChangePaymentMethod)
            case .delayedConfirmation:
                BankTransferDelayedConfirmationView(
                    supportEmail: "support@paystack.com",
                    onChangePaymentMethod: viewModel.userTappedChangePaymentMethod,
                    onKeepWaiting: viewModel.userTappedKeepWaiting)
            case .refundInitiated(_, let message):
                BankTransferRefundInitiatedView(
                    message: message,
                    transactionReference: viewModel.transactionDetails.reference,
                    onChooseAnotherPaymentMethod:
                        viewModel.userTappedChooseAnotherPaymentMethodFromRefund)
            case .error(let error):
                ErrorView(message: error.message,
                          buttonText: "Try again",
                          buttonAction: { Task { await viewModel.retryProvisioning() } })
            case .fatalError(let error):
                ErrorView(message: error.message,
                          automaticallyDismissWith: .init(
                            error: error,
                            transactionReference: viewModel.transactionDetails.reference))
            }
        }
        .task(viewModel.provisionVirtualAccount)
    }
}
