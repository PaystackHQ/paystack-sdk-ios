import XCTest
@testable import PaystackUI

final class ChargeCardViewModelTests: PSTestCase {

    var serviceUnderTest: ChargeCardViewModel!
    var mockTransactionDetails = VerifyAccessCode.example
    var mockChargeContainer: MockChargeContainer!
    var mockRepository: MockChargeCardRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockChargeContainer = MockChargeContainer()
        mockRepository = MockChargeCardRepository()
        serviceUnderTest = ChargeCardViewModel(transactionDetails: mockTransactionDetails,
                                               chargeContainer: mockChargeContainer,
                                               repository: mockRepository)
    }

    func testRestartCardPaymentResetsStateToCardDetailsWithAmount() {
        serviceUnderTest.chargeCardState = .pin
        serviceUnderTest.restartCardPayment()
        XCTAssertEqual(serviceUnderTest.chargeCardState,
                       .cardDetails(amount: mockTransactionDetails.amountCurrency,
                                    encryptionKey: mockTransactionDetails.publicEncryptionKey))
    }

    func testInitialStateIsSetToCardDetailsInLiveMode() {
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .live,
                                                         merchantName: "Test Merchant",
                                                         publicEncryptionKey: "test_encryption_key")
        serviceUnderTest = ChargeCardViewModel(transactionDetails: transactionDetails,
                                               chargeContainer: mockChargeContainer,
                                               repository: mockRepository)
        XCTAssertEqual(serviceUnderTest.chargeCardState,
                       .cardDetails(amount: transactionDetails.amountCurrency,
                                    encryptionKey: transactionDetails.publicEncryptionKey))
    }

    func testInitialStateIsSetToTestModeCardSelectionInTestMode() {
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .test,
                                                         merchantName: "Test Merchant",
                                                         publicEncryptionKey: "test_encryption_key")
        serviceUnderTest = ChargeCardViewModel(transactionDetails: transactionDetails,
                                               chargeContainer: mockChargeContainer,
                                               repository: mockRepository)
        XCTAssertEqual(serviceUnderTest.chargeCardState,
                       .testModeCardSelection(amount: transactionDetails.amountCurrency,
                                              encryptionKey: transactionDetails.publicEncryptionKey))
    }

    func testInTestModeReturnsTrueIfDomainIsTest() {
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .test,
                                                         merchantName: "Test Merchant",
                                                         publicEncryptionKey: "test_encryption_key")
        serviceUnderTest = ChargeCardViewModel(transactionDetails: transactionDetails,
                                               chargeContainer: mockChargeContainer,
                                               repository: mockRepository)
        XCTAssertTrue(serviceUnderTest.inTestMode)
    }

    func testInTestModeReturnsFalseIfDomainIsLive() {
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .live,
                                                         merchantName: "Test Merchant",
                                                         publicEncryptionKey: "test_encryption_key")
        serviceUnderTest = ChargeCardViewModel(transactionDetails: transactionDetails,
                                               chargeContainer: mockChargeContainer,
                                               repository: mockRepository)
        XCTAssertFalse(serviceUnderTest.inTestMode)
    }

    func testSwitchToTestModeCardSelectionChangesState() {
        let transactionDetails: VerifyAccessCode = .init(amount: 10000,
                                                         currency: "USD",
                                                         accessCode: "test_access",
                                                         paymentChannels: [], domain: .live,
                                                         merchantName: "Test Merchant",
                                                         publicEncryptionKey: "test_encryption_key")
        serviceUnderTest.switchToTestModeCardSelection()
        XCTAssertEqual(serviceUnderTest.chargeCardState,
                       .testModeCardSelection(amount: transactionDetails.amountCurrency,
                                              encryptionKey: transactionDetails.publicEncryptionKey))
    }

    func testProcessResponseWithAddressStatusSetsStateToAddressAndFetchesAddreses() async {
        let addressResponse = ChargeCardTransaction(status: .sendAddress, countryCode: "US")
        let mockStates = ["Test State A", "Test State B"]

        mockRepository.expectedAddressStates = mockStates

        await serviceUnderTest.processTransactionResponse(addressResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState, .address(states: mockStates))
    }

    func testProcessResponseWithAddressStatusSetsStatusToGenericErrorIfCountryCodeIsNotPresent() async {
        let addressResponse = ChargeCardTransaction(status: .sendAddress)
        mockRepository.expectedAddressStates = ["Test State A", "Test State B"]

        await serviceUnderTest.processTransactionResponse(addressResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState, .error(.generic))
    }

    func testProcessResponseWithAddressStatusSetsStatusToGenericErrorIfFetchingAddressStatesFails() async {
        let addressResponse = ChargeCardTransaction(status: .sendAddress)

        mockRepository.expectedErrorResponse = MockError.general

        await serviceUnderTest.processTransactionResponse(addressResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState, .error(.generic))
    }

    func testProcessResponseWithBirthdayStatusSetsStateToBirthday() async {
        let birthdayResponse = ChargeCardTransaction(status: .sendBirthday)
        await serviceUnderTest.processTransactionResponse(birthdayResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState, .birthday)
    }

    func testProcessResponseWithPhoneStatusSetsStateToPhone() async {
        let phoneResponse = ChargeCardTransaction(status: .sendPhone)
        await serviceUnderTest.processTransactionResponse(phoneResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState, .phoneNumber)
    }

    func testProcessResponseWithOTPStatusSetsStateToOTP() async {
        let expectedPhoneNumber = "0123456789"
        let otpResponse = ChargeCardTransaction(status: .sendOtp, customerPhone: expectedPhoneNumber)
        await serviceUnderTest.processTransactionResponse(otpResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState, .otp(phoneNumber: expectedPhoneNumber))
    }

    func testProcessResponseWithOTPStatusSetsStatusToGenericErrorIfPhoneNumberIsNotPresent() async {
        let otpResponse = ChargeCardTransaction(status: .sendOtp)
        await serviceUnderTest.processTransactionResponse(otpResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState, .error(.generic))
    }

    func testProcessResponseWithPinStatusSetsStateToPin() async {
        let pinResponse = ChargeCardTransaction(status: .sendPin)
        await serviceUnderTest.processTransactionResponse(pinResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState, .pin)
    }

    func testProcessResponseWithSuccessStatusCallsChargeContainerToUpdateStatus() async {
        let successResponse = ChargeCardTransaction(status: .success)
        await serviceUnderTest.processTransactionResponse(successResponse)
        XCTAssertTrue(mockChargeContainer.transactionSuccessful)
    }

    func testProcessResponseWithFailureSetsStateToFailed() async {
        let successResponse = ChargeCardTransaction(status: .failed)
        await serviceUnderTest.processTransactionResponse(successResponse)
        XCTAssertEqual(serviceUnderTest.chargeCardState, .failed)
    }

    func testCallingDisplayTransactionErrorSetsStateToErrorStateWithTheAccompanyingError() {
        let error = ChargeError(message: "Test")
        serviceUnderTest.displayTransactionError(error)
        XCTAssertEqual(serviceUnderTest.chargeCardState, .error(error))
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
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}
