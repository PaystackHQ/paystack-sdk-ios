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
        mockRepo.expectedVerifyAccessCode = .example
        await serviceUnderTest.verifyAccessCodeAndProceedWithCard()
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .payment(type: .card(transactionInformation: .example)))
    }

    func testVerifyAccessCodeSetsViewStateAsErrorWhenUnsuccessful() async {
        mockRepo.expectedErrorResponse = MockError.general
        await serviceUnderTest.verifyAccessCodeAndProceedWithCard()
        XCTAssertEqual(serviceUnderTest.transactionState, .error(MockError.general))
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
        XCTAssertFalse(serviceUnderTest.displayCloseButtonConfirmation)
    }

    func testPaymentIsInTestModeWhenDomainIsSetToTest() {
        serviceUnderTest.transactionDetails = .init(amount: 10000, currency: "USD",
                                                    accessCode: "test_access",
                                                    paymentChannels: [], domain: .test)
        XCTAssertTrue(serviceUnderTest.inTestMode)
    }

    func testPaymentIsNotInTestModeWhenDomainIsSetToLive() {
        serviceUnderTest.transactionDetails = .init(amount: 10000, currency: "USD",
                                                    accessCode: "test_access",
                                                    paymentChannels: [], domain: .live)
        XCTAssertFalse(serviceUnderTest.inTestMode)
    }

    func testPaymentIsNotInTestModeWhenDomainIsNotSet() {
        serviceUnderTest.transactionDetails = nil
        XCTAssertFalse(serviceUnderTest.inTestMode)
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
