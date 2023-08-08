import SwiftUI

@available(iOS 14.0, *)
// TODO: Replace constants and colors from design system
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
            VStack(spacing: 24) {
                Text("Use any of the options below to test the payment flow")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                FormInput(title: viewModel.buttonTitle,
                          enabled: viewModel.isValid,
                          action: viewModel.proceedWithTestCard,
                          secondaryButtonText: "Use another card",
                          secondaryAction: viewModel.displayManualCardDetailsEntry) {
                    testCardOptions
                }
            }
            .padding(16)
        }
    }

    var testCardOptions: some FormInputItemView {
        SingleSelectionFormInputView(
            items: TestCard.allCases,
            selectedItem: $viewModel.testCard) { item in
                HStack {
                    Text(item.description)
                        .foregroundColor(.black)
                        .font(.body)

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
                transactionDetails: .example))
    }
}
