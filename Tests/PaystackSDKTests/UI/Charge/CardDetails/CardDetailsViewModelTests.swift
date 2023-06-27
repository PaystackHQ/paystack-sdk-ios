import XCTest
@testable import PaystackUI

final class CardDetailsViewModelTests: XCTestCase {

    var serviceUnderTest: CardDetailsViewModel!
    var mockVerifyAccessCodeResponse = VerifyAccessCode(amount: 100, currency: "USD",
                                                        paymentChannels: ["card"], domain: .test)

    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceUnderTest = CardDetailsViewModel(transactionDetails: mockVerifyAccessCodeResponse)
    }

    func testWhenCardNumberChangesThatCardTypeUpdatesToReflectCorrectType() {
        serviceUnderTest.setUpListeners()
        let mastercardCardNumber = "5366282937473838"
        serviceUnderTest.cardNumber = mastercardCardNumber
        XCTAssertEqual(serviceUnderTest.cardType, .mastercard)
    }

}
