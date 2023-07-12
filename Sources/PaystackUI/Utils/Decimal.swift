import Foundation

extension Decimal {

    var intValue: Int {
        NSDecimalNumber(decimal: self).intValue
    }

    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }

    var isWholeNumber: Bool {
        self.isZero || (self.isNormal && self.exponent >= 0)
    }

    func format(withCurrency currencyCode: String, displaySymbol: Bool = true) -> String {
        NumberFormatter.toCurrency(code: currencyCode,
                                   amount: self,
                                   displaySymbol: displaySymbol)
    }

}
