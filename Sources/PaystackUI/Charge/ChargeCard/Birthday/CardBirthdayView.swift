import SwiftUI

@available(iOS 14.0, *)
struct CardBirthdayView: View {

    @StateObject
    var viewModel: CardBirthdayViewModel

    private let dayMaximumLength = 2
    private let yearMaximumLength = 4

    @State
    private var showDayError = false

    @State
    private var showYearError = false

    let displayMessage: String

    init(displayMessage: String?,
         chargeCardContainer: ChargeCardContainer) {
        self.displayMessage = displayMessage ??
        "Verify your date of birth to use this bank account with Paystack"
        self._viewModel = StateObject(
            wrappedValue: CardBirthdayViewModel(chargeCardContainer: chargeCardContainer))
    }

    var body: some View {
        VStack(spacing: .triplePadding) {
            Image.birthdayIcon

            Text(displayMessage)
                .font(.body16M)
                .foregroundColor(.stackBlue)
                .multilineTextAlignment(.center)

            FormInput(title: "Authorize",
                      enabled: viewModel.isValid,
                      action: viewModel.submitBirthday,
                      secondaryAction: viewModel.cancelTransaction) {

                monthField

                HorizontallyGroupedFormInputItemView {
                    dayField
                    yearField
                }
            }
        }
        .padding(.doublePadding)
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
        CardBirthdayView(displayMessage: nil,
                         chargeCardContainer: ChargeCardViewModel(
            transactionDetails: .example,
            chargeContainer: ChargeViewModel(accessCode: "access_code")))
    }
}
