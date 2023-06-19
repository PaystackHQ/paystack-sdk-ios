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
        let expectedVerifyAccessCodeResponse = VerifyAccessCode(amount: 100, currency: "USD",
                                                                paymentChannels: ["card"])
        mockRepo.expectedVerifyAccessCode = expectedVerifyAccessCodeResponse
        await serviceUnderTest.verifyAccessCodeAndProceedWithCard()
        XCTAssertEqual(serviceUnderTest.transactionState, .cardDetails(expectedVerifyAccessCodeResponse))
    }

    func testVerifyAccessCodeSetsViewStateAsErrorWhenUnsuccessful() async {
        mockRepo.expectedErrorResponse = MockError.general
        await serviceUnderTest.verifyAccessCodeAndProceedWithCard()
        XCTAssertEqual(serviceUnderTest.transactionState, .error(MockError.general))
    }
}

extension ChargeState: Equatable {

    public static func == (lhs: ChargeState, rhs: ChargeState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.cardDetails(let first), .cardDetails(let second)):
            return first == second
        case (.error(let first), .error(let second)):
            return first.localizedDescription == second.localizedDescription
        default:
            return false
        }
    }

}
