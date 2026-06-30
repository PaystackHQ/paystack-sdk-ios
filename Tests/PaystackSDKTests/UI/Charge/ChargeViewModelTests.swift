import XCTest
import PaystackCore
@testable import PaystackUI

final class ChargeViewModelTests: PSTestCase {

    var serviceUnderTest: ChargeViewModel!
    var mockRepo: MockChargeRepository!

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
        ChargeViewModel.supportedMobileMoneyProviders = ["MPESA"]
        let response = VerifyAccessCode.with(channels: [.mobileMoney],
                                             mobileMoney: [.mpesaFixture])
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        XCTAssertEqual(serviceUnderTest.transactionDetails, response)
    }

    func testAutoRoutesToBankTransferWhenItIsTheOnlyChannel() async {
        let response = VerifyAccessCode.with(
            channels: [.bankTransfer],
            bankTransferProviders: ["wema-bank", "titan-paystack"],
            fulfilLateNotification: true,
            transactionId: 1234)
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        let expectedConfig = BankTransferConfig(
            fulfilLateNotification: true,
            transactionId: 1234,
            availableProviders: ["wema-bank", "titan-paystack"])
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .payment(type: .bankTransfer(transactionInformation: response,
                                                    config: expectedConfig)))
    }

    func testShowsChannelSelectionWhenBankTransferAndCardBothSupported() async {
        let response = VerifyAccessCode.with(
            channels: [.card, .bankTransfer],
            bankTransferProviders: ["wema-bank"],
            fulfilLateNotification: false,
            transactionId: 1234)
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        let expectedConfig = BankTransferConfig(
            fulfilLateNotification: false,
            transactionId: 1234,
            availableProviders: ["wema-bank"])
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .channelSelection(transactionInformation: response,
                                         supportedChannels: [.card,
                                                             .bankTransfer(expectedConfig)]))
    }

    func testShowsChannelSelectionWhenBankTransferAndMobileMoneyAndCardSupported() async {
        ChargeViewModel.supportedMobileMoneyProviders = ["MPESA"]
        let response = VerifyAccessCode.with(
            channels: [.card, .mobileMoney, .bankTransfer],
            mobileMoney: [.mpesaFixture],
            bankTransferProviders: ["wema-bank"],
            fulfilLateNotification: false,
            transactionId: 1234)
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        let expectedConfig = BankTransferConfig(
            fulfilLateNotification: false,
            transactionId: 1234,
            availableProviders: ["wema-bank"])
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .channelSelection(transactionInformation: response,
                                         supportedChannels: [.card,
                                                             .mobileMoney(.mpesaFixture),
                                                             .bankTransfer(expectedConfig)]))
    }

    func testBankTransferConfigDefaultsFulfilLateNotificationToFalseWhenAbsent() async {
        let response = VerifyAccessCode.with(
            channels: [.bankTransfer],
            bankTransferProviders: ["titan-paystack"],
            fulfilLateNotification: nil,
            transactionId: 1234)
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        let expectedConfig = BankTransferConfig(
            fulfilLateNotification: false,
            transactionId: 1234,
            availableProviders: ["titan-paystack"])
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .payment(type: .bankTransfer(transactionInformation: response,
                                                    config: expectedConfig)))
    }

    // MARK: - Pesalink branding (PR K-B)

    /// KES currency → bank-transfer config resolves with `.pesalink`
    /// provider, which drives the Pesalink tile + Narration row.
    func testBankTransferResolvesToPesalinkProviderForKES() async {
        let response = VerifyAccessCode.with(
            channels: [.bankTransfer],
            currency: "KES",
            fulfilLateNotification: false,
            transactionId: 5678)
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        if case .payment(.bankTransfer(_, let config)) = serviceUnderTest.transactionState {
            XCTAssertEqual(config.provider, .pesalink)
        } else {
            XCTFail("Expected .payment(.bankTransfer(_, _)) state, got \(serviceUnderTest.transactionState)")
        }
    }

    /// NGN currency → standard PWT provider, not Pesalink.
    func testBankTransferResolvesToStandardProviderForNGN() async {
        let response = VerifyAccessCode.with(
            channels: [.bankTransfer],
            currency: "NGN",
            bankTransferProviders: ["wema-bank"],
            fulfilLateNotification: true,
            transactionId: 1234)
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        if case .payment(.bankTransfer(_, let config)) = serviceUnderTest.transactionState {
            XCTAssertEqual(config.provider, .standard)
        } else {
            XCTFail("Expected .payment(.bankTransfer(_, _)) state, got \(serviceUnderTest.transactionState)")
        }
    }

    /// Regression guard: USD (or any other non-KES currency) → standard.
    /// Catches accidental over-broadening of the Pesalink gate.
    func testBankTransferResolvesToStandardProviderForUSD() async {
        let response = VerifyAccessCode.with(
            channels: [.bankTransfer],
            currency: "USD",
            fulfilLateNotification: false,
            transactionId: 1234)
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        if case .payment(.bankTransfer(_, let config)) = serviceUnderTest.transactionState {
            XCTAssertEqual(config.provider, .standard)
        } else {
            XCTFail("Expected .payment(.bankTransfer(_, _)) state, got \(serviceUnderTest.transactionState)")
        }
    }

    /// The `pesalinkCurrencyCodes` static is runtime-mutable so the
    /// gate can be widened to a new currency without an SDK release.
    func testPesalinkCurrencyCodesStaticIsConfigurable() async {
        let originalCodes = ChargeViewModel.pesalinkCurrencyCodes
        defer { ChargeViewModel.pesalinkCurrencyCodes = originalCodes }
        ChargeViewModel.pesalinkCurrencyCodes = ["KES", "UGX"]

        let response = VerifyAccessCode.with(
            channels: [.bankTransfer],
            currency: "UGX",
            fulfilLateNotification: false,
            transactionId: 1234)
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        if case .payment(.bankTransfer(_, let config)) = serviceUnderTest.transactionState {
            XCTAssertEqual(config.provider, .pesalink)
        } else {
            XCTFail("Expected .payment(.bankTransfer(_, _)) state, got \(serviceUnderTest.transactionState)")
        }
    }

    /// Confirms `SupportedChannel.bankTransfer(.pesalink)` produces the
    /// Pesalink-branded display title.
    func testPesalinkProviderProducesPesalinkDisplayTitle() {
        let pesalinkConfig = BankTransferConfig(
            fulfilLateNotification: false,
            transactionId: 1234,
            availableProviders: [],
            provider: .pesalink)
        let standardConfig = BankTransferConfig(
            fulfilLateNotification: false,
            transactionId: 1234,
            availableProviders: [],
            provider: .standard)

        XCTAssertEqual(SupportedChannel.bankTransfer(pesalinkConfig).displayTitle,
                       "Pesalink")
        XCTAssertEqual(SupportedChannel.bankTransfer(standardConfig).displayTitle,
                       "Bank Transfer")
    }

    func testBankTransferDoesNotAppearWhenChannelArrayOmitsIt() async {
        let response = VerifyAccessCode.with(
            channels: [.card],
            bankTransferProviders: ["wema-bank"],
            fulfilLateNotification: true,
            transactionId: 1234)
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        XCTAssertEqual(serviceUnderTest.transactionState,
                       .payment(type: .card(transactionInformation: response)))
    }

    func testBankTransferDoesNotAppearWhenTransactionIdMissing() async {
        let response = VerifyAccessCode.with(
            channels: [.bankTransfer],
            bankTransferProviders: ["wema-bank"],
            fulfilLateNotification: true,
            transactionId: nil)
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        let expectedMessage = "No supported payment methods. " +
        "Please reach out to your merchant for further information"
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .error(.init(message: expectedMessage)))
    }

    func testAutoRoutesToZapWhenItIsTheOnlyChannel() async {
        let response = VerifyAccessCode.with(
            channels: [.bank],
            transactionId: 6222375579,
            supportedBanks: [.zapFixture])
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        let expectedConfig = ZapConfig(supportedBankId: 870,
                                       transactionId: 6222375579,
                                       walletEmail: "customer@example.com")
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .payment(type: .zap(transactionInformation: response,
                                           config: expectedConfig)))
    }

    func testZapDoesNotPromoteWhenBankChannelAbsent() async {
        let response = VerifyAccessCode.with(
            channels: [.card],
            transactionId: 6222375579,
            supportedBanks: [.zapFixture])
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        XCTAssertEqual(serviceUnderTest.transactionState,
                       .payment(type: .card(transactionInformation: response)))
    }

    func testZapDoesNotPromoteWhen00zapCodeMissingFromSupportedBanks() async {
        let response = VerifyAccessCode.with(
            channels: [.bank, .card],
            transactionId: 6222375579,
            supportedBanks: [.accessBankFixture])
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        XCTAssertEqual(serviceUnderTest.transactionState,
                       .payment(type: .card(transactionInformation: response)))
    }

    func testZapDoesNotPromoteWhenSupportedBanksIsNil() async {
        let response = VerifyAccessCode.with(
            channels: [.bank, .card],
            transactionId: 6222375579,
            supportedBanks: nil)
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        XCTAssertEqual(serviceUnderTest.transactionState,
                       .payment(type: .card(transactionInformation: response)))
    }

    func testZapDoesNotPromoteWhenTransactionIdMissing() async {
        let response = VerifyAccessCode.with(
            channels: [.bank],
            transactionId: nil,
            supportedBanks: [.zapFixture])
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        let expectedMessage = "No supported payment methods. " +
        "Please reach out to your merchant for further information"
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .error(.init(message: expectedMessage)))
    }

    func testShowsChannelSelectionWhenZapAndCardBothSupported() async {
        let response = VerifyAccessCode.with(
            channels: [.bank, .card],
            transactionId: 6222375579,
            supportedBanks: [.zapFixture, .accessBankFixture])
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        let expectedConfig = ZapConfig(supportedBankId: 870,
                                       transactionId: 6222375579,
                                       walletEmail: "customer@example.com")

        XCTAssertEqual(serviceUnderTest.transactionState,
                       .channelSelection(transactionInformation: response,
                                         supportedChannels: [.card,
                                                             .zap(expectedConfig)]))
    }

    func testZapConfigCarriesEmailFromVerifyAccessCode() async {
        let response = VerifyAccessCode.with(
            channels: [.bank],
            email: "alice@example.com",
            transactionId: 6222375579,
            supportedBanks: [.zapFixture])
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()

        if case .payment(.zap(_, let config)) = serviceUnderTest.transactionState {
            XCTAssertEqual(config.walletEmail, "alice@example.com")
        } else {
            XCTFail("Expected .payment(.zap(_, _)) state, got \(serviceUnderTest.transactionState)")
        }
    }

    func testRestartFromChannelSelectionRebuildsChannelSelectionFromCachedDetails() async {
        let response = VerifyAccessCode.with(
            channels: [.card, .bankTransfer],
            bankTransferProviders: ["wema-bank"],
            fulfilLateNotification: false,
            transactionId: 1234)
        mockRepo.expectedVerifyAccessCode = response

        await serviceUnderTest.verifyAccessCodeAndProceed()
        serviceUnderTest.transactionState = .payment(
            type: .card(transactionInformation: response))

        serviceUnderTest.restartFromChannelSelection()

        let expectedConfig = BankTransferConfig(
            fulfilLateNotification: false,
            transactionId: 1234,
            availableProviders: ["wema-bank"])
        XCTAssertEqual(serviceUnderTest.transactionState,
                       .channelSelection(transactionInformation: response,
                                         supportedChannels: [.card,
                                                             .bankTransfer(expectedConfig)]))
    }

    func testRestartFromChannelSelectionWithoutCachedDetailsSetsErrorState() {
        serviceUnderTest.transactionDetails = nil
        serviceUnderTest.restartFromChannelSelection()
        XCTAssertEqual(serviceUnderTest.transactionState, .error(.generic))
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
    static func with(channels: [PaystackCore.Channel],
                     email: String = "customer@example.com",
                     currency: String = "USD",
                     mobileMoney: [MobileMoneyChannel]? = nil,
                     bankTransferProviders: [String]? = nil,
                     fulfilLateNotification: Bool? = nil,
                     transactionId: Int? = 1234,
                     supportedBanks: [SupportedBank]? = nil) -> Self {
        let channelOptions: PaystackUI.ChannelOptions? = {
            if mobileMoney == nil && bankTransferProviders == nil { return nil }
            return PaystackUI.ChannelOptions(mobileMoney: mobileMoney,
                                             bankTransfer: bankTransferProviders)
        }()
        let settings: MerchantChannelSettings? = fulfilLateNotification.map {
            MerchantChannelSettings(
                bankTransfer: BankTransferMerchantSettings(fulfilLateNotification: $0))
        }
        return VerifyAccessCode(email: email,
                                amount: 10000,
                                currency: currency,
                                accessCode: "test_access",
                                paymentChannels: channels,
                                domain: .test,
                                merchantName: "Test Merchant",
                                publicEncryptionKey: "test_encryption_key",
                                reference: "test_reference",
                                transactionId: transactionId,
                                channelOptions: channelOptions,
                                merchantChannelSettings: settings,
                                supportedBanks: supportedBanks)
    }
}

extension SupportedBank {
    static let zapFixture = SupportedBank(id: 870, code: "00zap",
                                          name: "Zap by Paystack", slug: "zap")
    static let accessBankFixture = SupportedBank(id: 871, code: "044",
                                                 name: "Access Bank", slug: "access-bank")
}
