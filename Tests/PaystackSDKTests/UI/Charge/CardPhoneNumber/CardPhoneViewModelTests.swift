import XCTest
@testable import PaystackUI

final class CardPhoneViewModelTests: XCTestCase {

    var serviceUnderTest: CardPhoneViewModel!
    var mockChargeCardContainer: MockChargeCardContainer!
    var mockRepository: MockChargeCardRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeCardContainer = MockChargeCardContainer()
        mockRepository = MockChargeCardRepository()
        serviceUnderTest = CardPhoneViewModel(chargeCardContainer: mockChargeCardContainer,
                                              repository: mockRepository)
    }

    func testButtonIsDisabledWhenPhoneNumberIsLessThanTenDigits() {
        serviceUnderTest.phoneNumber = "0123456"
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testButtonIsEnabledWhenPhoneNumberIsMoreThanOrEqualToTenDigits() {
        serviceUnderTest.phoneNumber = "0123456789"
        XCTAssertTrue(serviceUnderTest.isValid)

        serviceUnderTest.phoneNumber = "+270123456789"
        XCTAssertTrue(serviceUnderTest.isValid)
    }

    func testCancelTransactionCallsContainerToRestartCardFlow() {
        serviceUnderTest.cancelTransaction()
        XCTAssertTrue(mockChargeCardContainer.cardPaymentRestarted)
    }

    func testSubmittingPhoneNumberSendsRepositoryResultToCardContainer() async throws {
        let expectedPhoneNumber = "0123456789"
        mockRepository.expectedChargeCardTransaction = .example
        serviceUnderTest.phoneNumber = expectedPhoneNumber
        await serviceUnderTest.submitPhoneNumber()

        XCTAssertEqual(mockRepository.phoneSubmitted.phone, expectedPhoneNumber)
        XCTAssertEqual(mockChargeCardContainer.transactionResponse, .example)
    }
}
