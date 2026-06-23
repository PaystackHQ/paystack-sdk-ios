import XCTest
@testable import PaystackCore

class TransactionsTests: PSTestCase {

    let apiKey = "testsk_Example"

    var serviceUnderTest: Paystack!

    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceUnderTest = try PaystackBuilder.newInstance
            .setKey(apiKey)
            .build()
    }

    func testVerifyAccessCode() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/verify_code/access_code_test")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "VerifyAccessCode")

        _ = try await serviceUnderTest.verifyAccessCode("access_code_test").async()
    }

    func testCheckPendingCharge() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/charge/access_code_test")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "ChargeAuthenticationResponse")

        _ = try await serviceUnderTest.checkPendingCharge(forAccessCode: "access_code_test").async()
    }

    func testVerifyAccessCodeDecodesSupportedBanksFromResponse() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/verify_code/access_code_test")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "VerifyAccessCode")

        let result = try await serviceUnderTest
            .verifyAccessCode("access_code_test").async()

        let supportedBanks = try XCTUnwrap(result.data.supportedBanks)
        XCTAssertEqual(supportedBanks.count, 2)
        XCTAssertEqual(supportedBanks[0].id, 870)
        XCTAssertEqual(supportedBanks[0].code, "00zap")
        XCTAssertEqual(supportedBanks[0].name, "Zap by Paystack")
        XCTAssertEqual(supportedBanks[0].slug, "zap")
        XCTAssertEqual(supportedBanks[1].code, "044")
    }

}
