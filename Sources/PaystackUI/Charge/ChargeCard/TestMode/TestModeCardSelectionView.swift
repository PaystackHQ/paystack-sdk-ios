import SwiftUI

@available(iOS 14.0, *)
struct TestModeCardSelectionView: View {

    @StateObject
    var viewModel: TestModeCardSelectionViewModel

    init(amountDetails: AmountCurrency,
         chargeCardContainer: ChargeCardContainer) {
        self._viewModel = StateObject(
            wrappedValue: TestModeCardSelectionViewModel(
                amountDetails: amountDetails,
                chargeCardContainer: chargeCardContainer))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: .triplePadding) {
                Text("Use any of the options below to test the payment flow")
                    .font(.body16M)
                    .foregroundColor(.stackBlue)
                    .multilineTextAlignment(.center)

                FormInput(title: viewModel.buttonTitle,
                          enabled: viewModel.isValid,
                          action: viewModel.proceedWithTestCard,
                          secondaryButtonText: "Use another card",
                          secondaryAction: viewModel.displayManualCardDetailsEntry) {
                    testCardOptions
                }
            }
            .padding(.doublePadding)
        }
    }

    var testCardOptions: some FormInputItemView {
        SingleSelectionFormInputView(
            items: TestCard.allCases,
            selectedItem: $viewModel.testCard) { item in
                HStack {
                    Text(item.description)
                        .foregroundColor(.stackBlue)
                        .font(.body14R)

                    Spacer()

                    if item == viewModel.testCard {
                        item.cardType.cardImage
                    }
                }
            }
    }
}

@available(iOS 14.0, *)
struct TestModeCardSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TestModeCardSelectionView(
            amountDetails: .init(amount: 10000,
                                 currency: "USD"),
            chargeCardContainer: ChargeCardViewModel(
                transactionDetails: .example,
                chargeContainer: ChargeViewModel(accessCode: "access_code")))
    }
}
