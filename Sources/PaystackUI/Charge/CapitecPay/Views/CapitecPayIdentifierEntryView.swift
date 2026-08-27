import SwiftUI

@available(iOS 14.0, *)
struct CapitecPayIdentifierEntryView: View {

    @ObservedObject
    var viewModel: CapitecPayViewModel

    let amount: AmountCurrency
    let onChangePaymentMethod: () -> Void

    @State private var showValidationError = false

    var body: some View {
        ScrollView {
            VStack(spacing: .triplePadding) {

                Image("capitecPayLogo", bundle: .current)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)

                Text(viewModel.identifier.prompt)
                    .font(.body16M)
                    .foregroundColor(.stackBlue)
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.identifier)

                FormInput(title: "Confirm  \(amount.description)",
                          enabled: viewModel.isValid,
                          action: viewModel.submitIdentifier,
                          secondaryButtonText: "Change payment method",
                          secondaryAction: onChangePaymentMethod) {
                    identifierPicker
                    identifierField
                }

                CapitecPayInfoBanner(
                    text: "Have your phone ready to approve the payment in your Capitec app.")
            }
            .padding(.doublePadding)
        }
    }

    @ViewBuilder
    private var identifierPicker: some FormInputItemView {
        PickerFormInputView(
            title: "",
            items: CapitecPayIdentifier.allCases,
            placeholder: viewModel.identifier.pickerTitle,
            selectedItem: Binding(
                get: { viewModel.identifier as CapitecPayIdentifier? },
                set: { newValue in
                    if let newValue = newValue, newValue != viewModel.identifier {
                        viewModel.identifier = newValue
                        viewModel.value = ""
                    }
                }))
    }

    @ViewBuilder
    private var identifierField: some FormInputItemView {
        TextFieldFormInputView(
            title: "",
            placeholder: viewModel.identifier.placeholder,
            text: $viewModel.value,
            keyboardType: keyboardType(for: viewModel.identifier),
            maxLength: maxLength(for: viewModel.identifier),
            inErrorState: $showValidationError,
            defaultFocused: true,
            accessoryView: accessoryView(for: viewModel.identifier))
    }

    private func keyboardType(for identifier: CapitecPayIdentifier) -> KeyboardType {
        switch identifier {
        case .cellphone:     return .phonePad
        case .idNumber:      return .numberPad
        case .accountNumber: return .numberPad
        }
    }

    private func maxLength(for identifier: CapitecPayIdentifier) -> Int? {
        switch identifier {
        case .cellphone:     return 10
        case .idNumber:      return 13
        case .accountNumber: return 20
        }
    }

    @ViewBuilder
    private func accessoryView(for identifier: CapitecPayIdentifier) -> some View {
        switch identifier {
        case .cellphone:
            Image("southAfricaFlagLogo", bundle: .current)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        case .idNumber, .accountNumber:
            EmptyView()
        }
    }
}

@available(iOS 14.0, *)
struct CapitecPayIdentifierEntryView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = CapitecPayViewModel(
            chargeContainer: PreviewChargeContainer(),
            transactionDetails: .example,
            config: CapitecPayConfig(
                transactionId: 5900549926,
                transactionReference: "T_ref",
                publicEncryptionKey: "test_key"),
            repository: PreviewCapitecPayRepository())
        return CapitecPayIdentifierEntryView(
            viewModel: vm,
            amount: AmountCurrency(amount: 12500, currency: "ZAR"),
            onChangePaymentMethod: {})
    }
}

private struct PreviewChargeContainer: ChargeContainer {
    func processSuccessfulTransaction(details: VerifyAccessCode) {}
    func restartFromChannelSelection() {}
}

private struct PreviewCapitecPayRepository: CapitecPayRepository {
    func authenticate(identifier: CapitecPayIdentifier,
                      value: String,
                      transactionId: Int,
                      deviceId: String,
                      publicEncryptionKey: String) async throws -> CapitecPayDetails {
        .example
    }
    func requery(transactionReference: String) async throws -> ChargeCapitecTransaction {
        ChargeCapitecTransaction(status: "success")
    }
    func listenForCapitecPayResponse(onChannel channelName: String)
        async throws -> ChargeCardTransaction {
        ChargeCardTransaction(status: .success)
    }
}
