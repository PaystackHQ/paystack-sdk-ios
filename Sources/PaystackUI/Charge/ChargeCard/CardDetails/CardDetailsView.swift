import SwiftUI

@available(iOS 14.0, *)
struct CardDetailsView: View {

    @StateObject
    var viewModel: CardDetailsViewModel

    private let cardNumberMaximumLength = 24
    private let expiryDateMaximumLength = 7

    @State
    private var showCvvError = false

    @State
    private var showCardNumberError = false

    @State
    private var showExpiryError = false

    init(amountDetails: AmountCurrency,
         encryptionKey: String,
         chargeCardContainer: ChargeCardContainer) {
        self._viewModel = StateObject(
            wrappedValue: CardDetailsViewModel(
                amountDetails: amountDetails,
                encryptionKey: encryptionKey,
                chargeCardContainer: chargeCardContainer))
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Enter your card details to pay")
                .font(.body16M)

            FormInput(title: viewModel.buttonTitle,
                      enabled: viewModel.isValid,
                      action: viewModel.submitCardDetails,
                      secondaryButtonText: viewModel.chargeCardContainer.inTestMode ?
                      "Use a test card" : "",
                      secondaryAction: viewModel.chargeCardContainer.inTestMode ?
                      viewModel.switchToTestModeCardSelection : nil) {
                cardNumber

                HorizontallyGroupedFormInputItemView {
                    expiryDate
                    cvv
                }
            }
        }
        .padding(16)
    }

    @ViewBuilder
    var cardNumber: some FormInputItemView {
        let cardNumberBinding = Binding(
            get: { viewModel.cardNumber },
            set: { viewModel.formatAndSetCardNumber($0) }
        )

        TextFieldFormInputView(title: "Card Number",
                               placeholder: "0000 0000 0000 0000",
                               text: cardNumberBinding,
                               keyboardType: .numberPad,
                               maxLength: cardNumberMaximumLength,
                               inErrorState: $showCardNumberError,
                               defaultFocused: true,
                               accessoryView: viewModel.cardType.cardImage)
        .validateCardNumber(errorMessage: "Invalid Card Number")
    }

    @ViewBuilder
    var expiryDate: some FormInputItemView {
        let expiryBinding = Binding(
            get: { viewModel.cardExpiry },
            set: { viewModel.formatAndSetCardExpiry($0) }
        )

        TextFieldFormInputView(title: "Card Expiry",
                               placeholder: "MM / YY",
                               text: expiryBinding,
                               keyboardType: .numberPad,
                               maxLength: expiryDateMaximumLength,
                               inErrorState: $showExpiryError)
        .validateExpiry(errorMessage: "Invalid Card Expiry")
    }

    var cvv: some FormInputItemView {
        TextFieldFormInputView(title: "CVV",
                               placeholder: "123",
                               text: $viewModel.cvv,
                               keyboardType: .numberPad,
                               maxLength: viewModel.maximumCvvDigits,
                               inErrorState: $showCvvError)
        .minLength(viewModel.maximumCvvDigits, errorMessage: "Invalid CVV")
    }
}

@available(iOS 14.0, *)
struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsView(
            amountDetails: .init(amount: 10000,
                                 currency: "USD"),
            encryptionKey: "test_encryption_key",
            chargeCardContainer: ChargeCardViewModel(
                transactionDetails: .example,
                chargeContainer: ChargeViewModel(accessCode: "access_code")))
    }
}
