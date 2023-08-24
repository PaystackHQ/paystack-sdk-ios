import XCTest
@testable import PaystackUI

final class ChargeCardViewModelTests: PSTestCase {

    var serviceUnderTest: ChargeCardViewModel!
    var mockTransactionDetails = VerifyAccessCode.example

    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceUnderTest = ChargeCardViewModel(transactionDetails: mockTransactionDetails)
    }

    func testRestartCardPaymentResetsStateToCardDetailsWithAmount() {
        serviceUnderTest.chargeCardState = .pin
        serviceUnderTest.restartCardPayment()
        XCTAssertEqual(serviceUnderTest.chargeCardState,
                       .cardDetails(amount: mockTransactionDetails.amountCurrency))
    }

    func testInitialStateIsSetToCardDetailsInLiveMode() {
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .live,
                                                         publicEncryptionKey: "test_encryption_key")
        serviceUnderTest = ChargeCardViewModel(transactionDetails: transactionDetails)
        XCTAssertEqual(serviceUnderTest.chargeCardState,
            .cardDetails(amount: transactionDetails.amountCurrency))
    }

    func testInitialStateIsSetToTestModeCardSelectionInTestMode() {
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .test,
                                                         publicEncryptionKey: "test_encryption_key")
        serviceUnderTest = ChargeCardViewModel(transactionDetails: transactionDetails)
        XCTAssertEqual(serviceUnderTest.chargeCardState,
                       .testModeCardSelection(amount: transactionDetails.amountCurrency))
    }

    func testInTestModeReturnsTrueIfDomainIsTest() {
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .test,
                                                         publicEncryptionKey: "test_encryption_key")
        serviceUnderTest = ChargeCardViewModel(transactionDetails: transactionDetails)
        XCTAssertTrue(serviceUnderTest.inTestMode)
    }

    func testInTestModeReturnsFalseIfDomainIsLive() {
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .live,
                                                         publicEncryptionKey: "test_encryption_key")
        serviceUnderTest = ChargeCardViewModel(transactionDetails: transactionDetails)
        XCTAssertFalse(serviceUnderTest.inTestMode)
    }

    func testSwitchToTestModeCardSelectionChangesState() {
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .live,
                                                         publicEncryptionKey: "test_encryption_key")
        serviceUnderTest.switchToTestModeCardSelection()
        XCTAssertEqual(serviceUnderTest.chargeCardState,
                       .testModeCardSelection(amount: transactionDetails.amountCurrency))
    }
}

extension ChargeCardState: Equatable {
    public static func == (lhs: ChargeCardState, rhs: ChargeCardState) -> Bool {
        switch (lhs, rhs) {
        case (.cardDetails(let first), .cardDetails(let second)):
            return first == second
        case (.testModeCardSelection(let first), testModeCardSelection(let second)):
            return first == second
        case (.pin, .pin):
            return true
        case (.phoneNumber, .phoneNumber):
            return true
        case (.otp(let first), .otp(let second)):
            return first == second
        case (.address(let first), .address(let second)):
            return first == second
        case (.birthday, .birthday):
            return true
        case (.error(let first), .error(let second)):
            return first == second
        default:
            return false
        }
    }
}
