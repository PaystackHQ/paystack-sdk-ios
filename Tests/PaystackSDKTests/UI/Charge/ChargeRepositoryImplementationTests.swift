import XCTest
import PaystackCore
@testable import PaystackUI

final class ChargeRepositoryImplementationTests: PSTestCase {

    let apiKey = "testsk_Example"
    var serviceUnderTest: ChargeRepositoryImplementation!
    var paystack: Paystack!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paystack = try PaystackBuilder.newInstance.setKey(apiKey).build()
        PaystackContainer.instance.store(paystack)
        serviceUnderTest = ChargeRepositoryImplementation()
    }

    func testVerifyAccessCodeRetrievesAccessCodeAndMapsToModel() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/transaction/verify_code/access_code_test")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "VerifyAccessCode")

        let result = try await serviceUnderTest.verifyAccessCode("access_code_test")
        let expectedResult = VerifyAccessCode(amount: 10000,
                                              currency: "NGN",
                                              accessCode: "Access_Code_Test",
                                              paymentChannels: [.card, .qr, .ussd],
                                              domain: .test,
                                              merchantName: "Test Merchant",
                                              publicEncryptionKey: "test_encryption_key",
                                              reference: "203520101")

        XCTAssertEqual(result, expectedResult)
    }

}
