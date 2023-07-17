import XCTest
@testable import PaystackUI

final class ChargeViewModelTests: PSTestCase {

    var serviceUnderTest: ChargeViewModel!
    var mockRepo: MockChargeRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockRepo = MockChargeRepository()
        serviceUnderTest = ChargeViewModel(accessCode: "access_code_test", repository: mockRepo)
    }

    func testVerifyAccessCodeSetsViewStateAsCardDetailsWhenSuccessful() async {
        let verifyAccessCodeResponse = VerifyAccessCode(amount: 100, currency: "USD",
                                                                paymentChannels: ["card"], domain: .test)
        mockRepo.expectedVerifyAccessCode = verifyAccessCodeResponse
        let expectedAmountCurrency = AmountCurrency(amount: 100, currency: "USD")
        await serviceUnderTest.verifyAccessCodeAndProceedWithCard()
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .payment(type: .card(amountInformation: expectedAmountCurrency)))
    }

    func testVerifyAccessCodeSetsViewStateAsErrorWhenUnsuccessful() async {
        mockRepo.expectedErrorResponse = MockError.general
        await serviceUnderTest.verifyAccessCodeAndProceedWithCard()
        XCTAssertEqual(serviceUnderTest.transactionState, .error(MockError.general))
    }

    func testSecuredByPaystackShouldBeHiddenForSpecifiedStates() {
        serviceUnderTest.transactionState = .loading()
        XCTAssertTrue(serviceUnderTest.displaySecuredByPaystack)

        serviceUnderTest.transactionState = .success(amount: .init(
            amount: 100, currency: "USD"), merchant: "Test")
        XCTAssertFalse(serviceUnderTest.displaySecuredByPaystack)
    }

    func testViewShouldBeCenteredForSpecifiedStates() {
        serviceUnderTest.transactionState = .loading()
        XCTAssertFalse(serviceUnderTest.centerView)

        serviceUnderTest.transactionState = .success(amount: .init(
            amount: 100, currency: "USD"), merchant: "Test")
        XCTAssertTrue(serviceUnderTest.centerView)
    }

    func testCloseButtonConfirmationShouldNotBePresentOnCertainViews() {
        serviceUnderTest.transactionState = .loading()
        XCTAssertTrue(serviceUnderTest.displayCloseButtonConfirmation)

        serviceUnderTest.transactionState = .success(amount: .init(
            amount: 100, currency: "USD"), merchant: "Test")
        XCTAssertFalse(serviceUnderTest.displaySecuredByPaystack)
    }
}

extension ChargeState: Equatable {

    public static func == (lhs: ChargeState, rhs: ChargeState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.success(let firstAmount, let firstMerchant), .success(let secondAmount, let secondMerchant)):
            return firstAmount == secondAmount && firstMerchant == secondMerchant
        case (.payment(let first), .payment(let second)):
            return first == second
        case (.error(let first), .error(let second)):
            return first.localizedDescription == second.localizedDescription
        default:
            return false
        }
    }

}
