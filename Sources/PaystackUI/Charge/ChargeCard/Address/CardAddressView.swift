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
                          cancelAction: viewModel.cancelTransaction) {
                    streetField
                    zipCodeField

                    HorizontallyGroupedFormInputItemView {

                        // TODO: Add State drop down

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
                               keyboardType: .asciiCapable)
    }

    var zipCodeField: some FormInputItemView {
        TextFieldFormInputView(title: "Zip Code",
                               placeholder: "12345",
                               text: $viewModel.zipCode,
                               keyboardType: .numbersAndPunctuation)
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
            amountDetails: .init(amount: 100000, currency: "USD")))
    }
}
