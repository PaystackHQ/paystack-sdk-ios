import XCTest
import PaystackCore
@testable import PaystackUI

final class ChargeViewModelTests: PSTestCase {

    var serviceUnderTest: ChargeViewModel!
    var mockRepo: MockChargeRepository!

    /// Snapshot the production allowlist on entry so individual tests can
    /// mutate `supportedMobileMoneyProviders` freely and we restore the
    /// original value in `tearDown`. Avoids order-dependent test leakage.
    private static let productionAllowlist = ChargeViewModel.supportedMobileMoneyProviders

    override func setUpWithError() throws {
        try super.setUpWithError()
        ChargeViewModel.supportedMobileMoneyProviders = Self.productionAllowlist
        mockRepo = MockChargeRepository()
        serviceUnderTest = ChargeViewModel(accessCode: "access_code_test", repository: mockRepo)
    }

    override func tearDownWithError() throws {
        ChargeViewModel.supportedMobileMoneyProviders = Self.productionAllowlist
        try super.tearDownWithError()
    }

    func testVerifyAccessCodeSetsViewStateAsCardDetailsWhenSuccessful() async {
        let cardOnlyAccessCode = VerifyAccessCode(amount: 10000,
                                                  currency: "USD",
                                                  accessCode: "test_access",
                                                  paymentChannels: [.card],
                                                  domain: .test,
                                                  merchantName: "Test Merchant",
                                                  publicEncryptionKey: "test_encryption_key",
                                                  reference: "test_reference",
                                                  channelOptions: nil)
        mockRepo.expectedVerifyAccessCode = cardOnlyAccessCode
        await serviceUnderTest.verifyAccessCodeAndProceed()
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .payment(type: .card(transactionInformation: cardOnlyAccessCode)))
    }

    func testVerifyAccessCodeSetsViewStateAsErrorWhenUnsuccessful() async {
        mockRepo.expectedErrorResponse = ChargeError.generic
        await serviceUnderTest.verifyAccessCodeAndProceed()
        XCTAssertEqual(serviceUnderTest.transactionState, .error(.generic))
    }

    func testVerifyAccessCodeSetsViewStateAsErrorWhenCardIsNotASupportedPaymentChannel() async {
        let expectedMessage = "No supported payment methods. " +
        "Please reach out to your merchant for further information"
        mockRepo.expectedVerifyAccessCode = .init(amount: 10000,
                                                  currency: "USD",
                                                  accessCode: "test_access",
                                                  paymentChannels: [.ussd],
                                                  domain: .test,
                                                  merchantName: "Test Merchant",
                                                  publicEncryptionKey: "test_encryption_key",
                                                  reference: "test_reference", channelOptions: .example)
        await serviceUnderTest.verifyAccessCodeAndProceed()
        XCTAssertEqual(serviceUnderTest.transactionState, .error(.init(message: expectedMessage)))

    }

    // MARK: - Resolver and auto-route

    func testAutoRoutesToMobileMoneyWhenCardUnsupportedAndExactlyOneAllowlistedProvider() async {
        ChargeViewModel.supportedMobileMoneyProviders = ["MPESA"]
        let response = VerifyAccessCode.with(channels: [.mobileMoney],
                                             mobileMoney: [.mpesaFixture])
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        XCTAssertEqual(serviceUnderTest.transactionState,
                       .payment(type: .mobileMoney(transactionInformation: response,
                                                   provider: .mpesaFixture)))
    }

    func testShowsChannelSelectionWhenMultipleMobileMoneyProvidersAndNoCard() async {
        ChargeViewModel.supportedMobileMoneyProviders = nil   // accept everything
        let response = VerifyAccessCode.with(channels: [.mobileMoney],
                                             mobileMoney: [.mtnFixture, .vodafoneFixture])
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        XCTAssertEqual(serviceUnderTest.transactionState,
                       .channelSelection(transactionInformation: response,
                                         supportedChannels: [.mobileMoney(.mtnFixture),
                                                             .mobileMoney(.vodafoneFixture)]))
    }

    func testShowsChannelSelectionWhenCardAndMobileMoneyBothSupported() async {
        ChargeViewModel.supportedMobileMoneyProviders = ["MPESA"]
        let response = VerifyAccessCode.with(channels: [.card, .mobileMoney],
                                             mobileMoney: [.mpesaFixture])
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        XCTAssertEqual(serviceUnderTest.transactionState,
                       .channelSelection(transactionInformation: response,
                                         supportedChannels: [.card,
                                                             .mobileMoney(.mpesaFixture)]))
    }

    func testAllowlistFiltersOutUnknownProvidersAndResultsInError() async {
        ChargeViewModel.supportedMobileMoneyProviders = ["MPESA"]
        let response = VerifyAccessCode.with(channels: [.mobileMoney],
                                             mobileMoney: [.mtnFixture, .vodafoneFixture])
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        let expectedMessage = "No supported payment methods. " +
        "Please reach out to your merchant for further information"
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .error(.init(message: expectedMessage)))
    }

    func testAllowlistGatesAutoRouteWhenMerchantHasMoreProvidersThanSdkSupports() async {
        ChargeViewModel.supportedMobileMoneyProviders = ["MPESA"]
        let response = VerifyAccessCode.with(channels: [.mobileMoney],
                                             mobileMoney: [.mpesaFixture, .mtnFixture])
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        XCTAssertEqual(serviceUnderTest.transactionState,
                       .payment(type: .mobileMoney(transactionInformation: response,
                                                   provider: .mpesaFixture)))
    }

    func testNilAllowlistAcceptsEveryMobileMoneyProvider() async {
        ChargeViewModel.supportedMobileMoneyProviders = nil
        let response = VerifyAccessCode.with(channels: [.mobileMoney],
                                             mobileMoney: [.mtnFixture, .vodafoneFixture])
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        XCTAssertEqual(serviceUnderTest.transactionState,
                       .channelSelection(transactionInformation: response,
                                         supportedChannels: [.mobileMoney(.mtnFixture),
                                                             .mobileMoney(.vodafoneFixture)]))
    }

    func testTransactionDetailsIsSetAfterResolvingMobileMoneyAutoRoute() async {
        // Regression guard: pre-PR-2 the MM branch never set `transactionDetails`,
        // so downstream UI checks (inTestMode, chargeCancelled) saw nil.
        ChargeViewModel.supportedMobileMoneyProviders = ["MPESA"]
        let response = VerifyAccessCode.with(channels: [.mobileMoney],
                                             mobileMoney: [.mpesaFixture])
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        XCTAssertEqual(serviceUnderTest.transactionDetails, response)
    }

    func testViewShouldBeCenteredForSpecifiedStates() {
        serviceUnderTest.transactionState = .loading()
        XCTAssertFalse(serviceUnderTest.centerView)

        serviceUnderTest.transactionState = .success(
            amount: .init(amount: 100, currency: "USD"),
            merchant: "Test",
            details: .init(reference: "test"))
        XCTAssertTrue(serviceUnderTest.centerView)
    }

    func testCloseButtonConfirmationShouldNotBePresentOnCertainViews() {
        serviceUnderTest.transactionState = .loading()
        XCTAssertTrue(serviceUnderTest.displayCloseButtonConfirmation)

        serviceUnderTest.transactionState = .success(
            amount: .init(amount: 100, currency: "USD"),
            merchant: "Test", details: .init(reference: "test"))
        XCTAssertFalse(serviceUnderTest.displayCloseButtonConfirmation)
    }

    func testPaymentIsInTestModeWhenDomainIsSetToTest() {
        serviceUnderTest.transactionDetails = .init(amount: 10000, currency: "USD",
                                                    accessCode: "test_access",
                                                    paymentChannels: [], domain: .test,
                                                    merchantName: "Test Merchant",
                                                    publicEncryptionKey: "test_encryption_key",
                                                    reference: "test_reference", channelOptions: .example)
        XCTAssertTrue(serviceUnderTest.inTestMode)
    }

    func testPaymentIsNotInTestModeWhenDomainIsSetToLive() {
        serviceUnderTest.transactionDetails = .init(amount: 10000, currency: "USD",
                                                    accessCode: "test_access",
                                                    paymentChannels: [], domain: .live,
                                                    merchantName: "Test Merchant",
                                                    publicEncryptionKey: "test_encryption_key",
                                                    reference: "test_reference", channelOptions: .example)
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
        case (.success(let firstAmount, let firstMerchant, let firstDetails), .success(let secondAmount, let secondMerchant, let secondDetails)):
            return firstAmount == secondAmount && firstMerchant == secondMerchant && firstDetails == secondDetails
        case (.payment(let first), .payment(let second)):
            return first == second
        case (.channelSelection(let firstInfo, let firstChannels), .channelSelection(let secondInfo, let secondChannels)):
            return firstInfo == secondInfo && firstChannels == secondChannels
        case (.error(let first), .error(let second)):
            return first.localizedDescription == second.localizedDescription
        default:
            return false
        }
    }

}

extension ChargeCompletionDetails: Equatable {
    public static func == (lhs: ChargeCompletionDetails, rhs: ChargeCompletionDetails) -> Bool {
        lhs.reference == rhs.reference
    }
}

// MARK: - Test fixtures

private extension MobileMoneyChannel {
    static let mpesaFixture = MobileMoneyChannel(key: "MPESA",
                                                 value: "M-PESA",
                                                 isNew: true,
                                                 phoneNumberRegex: "")
    static let mtnFixture = MobileMoneyChannel(key: "MTN",
                                               value: "MTN",
                                               isNew: false,
                                               phoneNumberRegex: "")
    static let vodafoneFixture = MobileMoneyChannel(key: "VOD",
                                                    value: "Vodafone",
                                                    isNew: false,
                                                    phoneNumberRegex: "")
}

private extension VerifyAccessCode {
    /// Compact helper for building `VerifyAccessCode` fixtures for resolver tests.
    /// Most fields are irrelevant to channel resolution and get sensible defaults.
    static func with(channels: [PaystackCore.Channel],
                     mobileMoney: [MobileMoneyChannel]? = nil) -> Self {
        VerifyAccessCode(amount: 10000,
                         currency: "USD",
                         accessCode: "test_access",
                         paymentChannels: channels,
                         domain: .test,
                         merchantName: "Test Merchant",
                         publicEncryptionKey: "test_encryption_key",
                         reference: "test_reference",
                         channelOptions: mobileMoney.map { PaystackUI.ChannelOptions(mobileMoney: $0) })
    }
}
