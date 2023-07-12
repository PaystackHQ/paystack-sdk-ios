import XCTest
@testable import PaystackUI

final class DecimalTests: XCTestCase {

    func testFormatCurrencyFormatsWithProvidedSymbol() {
        let result = Decimal(123.45).format(withCurrency: "USD")
        XCTAssertEqual("USD 123.45", result)
    }

    func testFormatCurrencyFormatsWithoutSymbolProvided() {
        let result = Decimal(123.45).format(withCurrency: "USD", displaySymbol: false)
        XCTAssertEqual("123.45", result)
    }

    func testFormatCurrencyWithWholeNumberExcludesDecimals() {
        let result = Decimal(123).format(withCurrency: "USD")
        XCTAssertEqual("USD 123", result)
    }

}
