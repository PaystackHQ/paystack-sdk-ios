import Foundation

struct AmountCurrency: Equatable {
    var amount: Decimal
    var currency: String

    private var smallestUnit: Decimal { 0.01 }
}

extension AmountCurrency: CustomStringConvertible {

    var description: String {
        let actualAmount = amount * smallestUnit
        return actualAmount.format(withCurrency: currency)
    }

}
