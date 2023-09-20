import XCTest
import PaystackCore
@testable import PaystackUI

final class CardBirthdayViewModelTests: XCTestCase {

    var serviceUnderTest: CardBirthdayViewModel!
    var mockChargeCardContainer: MockChargeCardContainer!
    var mockRepository: MockChargeCardRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeCardContainer = MockChargeCardContainer()
        mockRepository = MockChargeCardRepository()
        serviceUnderTest = CardBirthdayViewModel(chargeCardContainer: mockChargeCardContainer,
                                                 repository: mockRepository)
    }

    func testCancelTransactionCallsContainerToRestartCardFlow() {
        serviceUnderTest.cancelTransaction()
        XCTAssertTrue(mockChargeCardContainer.cardPaymentRestarted)
    }

    func testFormIsInvalidWhenAllFieldsAreEmpty() {
        serviceUnderTest.year = ""
        serviceUnderTest.day = ""
        serviceUnderTest.month = nil
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testFormIsInvalidWhenSomeFieldsAreEmpty() {
        serviceUnderTest.year = "2000"
        serviceUnderTest.day = "01"
        serviceUnderTest.month = nil
        XCTAssertFalse(serviceUnderTest.isValid)
    }

    func testFormIsValidIfAllFieldsAreNotEmpty() {
        serviceUnderTest.year = "2000"
        serviceUnderTest.day = "01"
        serviceUnderTest.month = .january
        XCTAssertTrue(serviceUnderTest.isValid)
    }

    func testSubmittingBirthdayConstructsBirthdayCorrectlyAndSendsRepoResultToCardContainer() async throws {
        serviceUnderTest.year = "2020"
        serviceUnderTest.month = .january
        serviceUnderTest.day = "01"

        mockRepository.expectedChargeCardTransaction = .example
        await serviceUnderTest.submitBirthday()

        let birthdayString = DateFormatter.toString(usingFormat: "yyyy-MM-dd",
                                                    from: mockRepository.birthdaySubmitted.birthday!)
        XCTAssertEqual(birthdayString, "2020-01-01")
        XCTAssertEqual(mockChargeCardContainer.transactionResponse, .example)
    }

    func testSubmittingBirthdayThrowsErrorWhenBirthdayIsNotValid() async {
        serviceUnderTest.year = "123"
        serviceUnderTest.month = .january
        serviceUnderTest.day = "01"

        await serviceUnderTest.submitBirthday()

        XCTAssertEqual(mockChargeCardContainer.transactionError, .generic)
    }

    func testSubmittingBirthdayWithErrorForwardsErrorToCardContainer() async {
        let expectedErrorMessage = "Error Message"
        let expectedError: PaystackError = .response(code: 400, message: expectedErrorMessage)
        mockRepository.expectedErrorResponse = expectedError

        serviceUnderTest.year = "2000"
        serviceUnderTest.month = .january
        serviceUnderTest.day = "01"
        await serviceUnderTest.submitBirthday()

        XCTAssertEqual(mockChargeCardContainer.transactionError,
                       .init(message: expectedErrorMessage))
    }
}
