import XCTest
@testable import PaystackUI

final class CardPinViewModelTests: XCTestCase {

    var serviceUnderTest: CardPinViewModel!
    var mockRepository: MockChargeCardRepository!
    var mockChargeCardContainer: MockChargeCardContainer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeCardContainer = MockChargeCardContainer()
        mockRepository = MockChargeCardRepository()
        serviceUnderTest = CardPinViewModel(chargeCardContainer: mockChargeCardContainer,
                                            repository: mockRepository)
    }

    func testCancelTransactionCallsContainerToRestartCardFlow() {
        serviceUnderTest.cancelTransaction()
        XCTAssertTrue(mockChargeCardContainer.cardPaymentRestarted)
    }

    func testSubmittingPinSendsRepositoryResultToCardContainer() async throws {
        let expectedPin = "12345"
        mockRepository.expectedChargeCardTransaction = .example
        serviceUnderTest.pinText = expectedPin
        await serviceUnderTest.submitPin()

        XCTAssertEqual(mockRepository.pinSubmitted.pin, expectedPin)
        XCTAssertEqual(mockChargeCardContainer.transactionResponse, .example)
    }

}
