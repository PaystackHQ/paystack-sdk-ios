import XCTest
@testable import PaystackUI

final class MobileMoneyChannelTests: XCTestCase {

    // MARK: - expectedCountryCode

    func testExpectedCountryCodeReturnsKenyaCodeForMPesa() {
        XCTAssertEqual(MobileMoneyChannel(key: "MPESA",
                                          value: "",
                                          isNew: false,
                                          phoneNumberRegex: "").expectedCountryCode,
                       "254")
    }

    func testExpectedCountryCodeReturnsGhanaCodeForGhanaianProviders() {
        for key in ["MTN", "ATL", "VOD"] {
            XCTAssertEqual(MobileMoneyChannel(key: key,
                                              value: "",
                                              isNew: false,
                                              phoneNumberRegex: "").expectedCountryCode,
                           "233",
                           "Expected \(key) to map to Ghana (233)")
        }
    }

    func testExpectedCountryCodeReturnsIvoryCoastCodeForOrangeAndMoov() {
        for key in ["ORANGE", "MOOV"] {
            XCTAssertEqual(MobileMoneyChannel(key: key,
                                              value: "",
                                              isNew: false,
                                              phoneNumberRegex: "").expectedCountryCode,
                           "225",
                           "Expected \(key) to map to Côte d'Ivoire (225)")
        }
    }

    func testExpectedCountryCodeReturnsRwandaCodeForAirtel() {
        XCTAssertEqual(MobileMoneyChannel(key: "AIRTEL",
                                          value: "",
                                          isNew: false,
                                          phoneNumberRegex: "").expectedCountryCode,
                       "250")
    }

    func testExpectedCountryCodeReturnsEmptyForUnknownProvider() {
        XCTAssertEqual(MobileMoneyChannel(key: "SOMETHING_NEW",
                                          value: "",
                                          isNew: false,
                                          phoneNumberRegex: "").expectedCountryCode,
                       "")
    }

    func testExpectedCountryCodeIsCaseInsensitive() {
        XCTAssertEqual(MobileMoneyChannel(key: "mpesa",
                                          value: "",
                                          isNew: false,
                                          phoneNumberRegex: "").expectedCountryCode,
                       "254")
        XCTAssertEqual(MobileMoneyChannel(key: "Mtn",
                                          value: "",
                                          isNew: false,
                                          phoneNumberRegex: "").expectedCountryCode,
                       "233")
    }

    // MARK: - phoneInputAccessory

    func testPhoneInputAccessoryReturnsViewForMPesa() {
        let mpesa = MobileMoneyChannel(key: "MPESA",
                                       value: "M-PESA",
                                       isNew: false,
                                       phoneNumberRegex: "")
        XCTAssertNotNil(mpesa.phoneInputAccessory)
    }

    func testPhoneInputAccessoryReturnsNilForProviderWithoutShippedAsset() {
        let unknown = MobileMoneyChannel(key: "SOMETHING_NEW",
                                         value: "",
                                         isNew: false,
                                         phoneNumberRegex: "")
        XCTAssertNil(unknown.phoneInputAccessory)
    }
}
