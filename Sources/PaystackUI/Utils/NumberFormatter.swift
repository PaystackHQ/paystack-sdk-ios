import Foundation

extension NumberFormatter {

    static func toCurrency(code: String, amount: Decimal,
                           displaySymbol: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.currencySymbol = displaySymbol ? code : ""

        if amount.isWholeNumber {
            formatter.minimumFractionDigits = 0
        }

        let formattedCurrency = formatter.string(from: amount as NSDecimalNumber)
        return formattedCurrency ?? "\(code) \(amount)"
    }

}
