import SwiftUI

@available(iOS 14.0, *)
struct CardAddressView: View {

    @StateObject
    var viewModel: CardAddressViewModel

    let displayMessage: String

    init(states: [String],
         displayMessage: String?,
         chargeCardContainer: ChargeCardContainer) {
        self.displayMessage = displayMessage ??
        "Enter your billing address to complete this payment"
        self._viewModel = StateObject(
            wrappedValue: CardAddressViewModel(states: states,
                                               chargeCardContainer: chargeCardContainer))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: .triplePadding) {

                Text(displayMessage)
                    .font(.body16M)
                    .foregroundColor(.stackBlue)
                    .multilineTextAlignment(.center)

                FormInput(title: "Complete Payment",
                          enabled: viewModel.isValid,
                          action: viewModel.submitAddress,
                          secondaryAction: viewModel.cancelTransaction) {
                    streetField
                    zipCodeField

                    HorizontallyGroupedFormInputItemView {
                        stateField
                        cityField
                    }
                }
            }
            .padding(.doublePadding)
        }
    }

    var streetField: some FormInputItemView {
        TextFieldFormInputView(title: "Street Address",
                               placeholder: "201 Spear Street",
                               text: $viewModel.street,
                               keyboardType: .asciiCapable,
                               defaultFocused: true)
    }

    var zipCodeField: some FormInputItemView {
        TextFieldFormInputView(title: "Zip Code",
                               placeholder: "12345",
                               text: $viewModel.zipCode,
                               keyboardType: .numbersAndPunctuation)
    }

    var stateField: some FormInputItemView {
        PickerFormInputView(title: "State",
                            items: viewModel.stateList,
                            placeholder: "Select State",
                            selectedItem: $viewModel.state)
    }

    var cityField: some FormInputItemView {
        TextFieldFormInputView(title: "City",
                               placeholder: "City",
                               text: $viewModel.city,
                               keyboardType: .asciiCapable)
    }
}

@available(iOS 14.0, *)
struct CardAddressView_Previews: PreviewProvider {
    static var previews: some View {
        CardAddressView(states: [], displayMessage: nil,
                        chargeCardContainer: ChargeCardViewModel(
                            transactionDetails: .example,
                            chargeContainer: ChargeViewModel(accessCode: "access_code")))
    }
}
