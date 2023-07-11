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
        XCTAssertEqual(serviceUnderTest.transactionState, .cardDetails(amount: expectedAmountCurrency))
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
}

extension ChargeState: Equatable {

    public static func == (lhs: ChargeState, rhs: ChargeState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.success(let firstAmount, let firstMerchant), .success(let secondAmount, let secondMerchant)):
            return firstAmount == secondAmount && firstMerchant == secondMerchant
        case (.cardDetails(let first), .cardDetails(let second)):
            return first == second
        case (.error(let first), .error(let second)):
            return first.localizedDescription == second.localizedDescription
        default:
            return false
        }
    }

}
