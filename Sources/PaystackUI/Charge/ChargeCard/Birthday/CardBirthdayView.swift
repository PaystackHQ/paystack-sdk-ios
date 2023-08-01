import SwiftUI

@available(iOS 14.0, *)
// TODO: Replace constants and colors from design system
struct CardBirthdayView: View {

    @StateObject
    var viewModel: CardBirthdayViewModel

    private let dayMaximumLength = 2
    private let yearMaximumLength = 4

    @State
    private var showDayError = false

    @State
    private var showYearError = false

    init(chargeCardContainer: ChargeCardContainer) {
        self._viewModel = StateObject(
            wrappedValue: CardBirthdayViewModel(chargeCardContainer: chargeCardContainer))
    }

    var body: some View {
        VStack(spacing: 24) {
            Image.birthdayIcon

            Text("Verify your date of birth to use this bank account with Paystack")
                .font(.headline)
                .multilineTextAlignment(.center)

            FormInput(title: "Authorize",
                      enabled: viewModel.isValid,
                      action: viewModel.submitPhoneNumber, cancelAction: viewModel.cancelTransaction) {

                monthField

                HorizontallyGroupedFormInputItemView {
                    dayField
                    yearField
                }
            }
        }
        .padding(16)
    }

    var dayField: some FormInputItemView {
        TextFieldFormInputView(title: "Day",
                               placeholder: "01",
                               text: $viewModel.day,
                               keyboardType: .numberPad,
                               maxLength: dayMaximumLength,
                               inErrorState: $showDayError)
        .minLength(2, errorMessage: "Invalid Day")
    }

    var monthField: some FormInputItemView {
        PickerFormInputView(title: "Month",
                            items: Month.allCases.reversed(),
                            placeholder: "Select Month",
                            selectedItem: $viewModel.month)
    }

    var yearField: some FormInputItemView {
        TextFieldFormInputView(title: "Year",
                               placeholder: "1990",
                               text: $viewModel.year,
                               keyboardType: .numberPad,
                               maxLength: yearMaximumLength,
                               inErrorState: $showYearError)
        .minLength(4, errorMessage: "Invalid Year")
    }
}

@available(iOS 14.0, *)
struct CardBirthdayView_Previews: PreviewProvider {
    static var previews: some View {
        CardBirthdayView(chargeCardContainer: ChargeCardViewModel(
            amountDetails: .init(amount: 100000, currency: "USD")))
    }
}
