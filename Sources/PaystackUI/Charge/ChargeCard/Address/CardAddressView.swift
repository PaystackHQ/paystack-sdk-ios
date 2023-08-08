import SwiftUI

@available(iOS 14.0, *)
// TODO: Replace constants and colors from design system
struct CardAddressView: View {

    @StateObject
    var viewModel: CardAddressViewModel

    init(states: [String],
         chargeCardContainer: ChargeCardContainer) {
        self._viewModel = StateObject(
            wrappedValue: CardAddressViewModel(states: states,
                                               chargeCardContainer: chargeCardContainer))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                Text("Enter your billing address to complete this payment")
                    .font(.headline)
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
            .padding(16)
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
        CardAddressView(states: [],
                        chargeCardContainer: ChargeCardViewModel(
                            transactionDetails: .example))
    }
}
