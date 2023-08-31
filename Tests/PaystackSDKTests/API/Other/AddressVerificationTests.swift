import XCTest
@testable import PaystackCore

final class AddressVerificationTests: PSTestCase {

    let apiKey = "testsk_Example"

    var serviceUnderTest: Paystack!

    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceUnderTest = try PaystackBuilder.newInstance
            .setKey(apiKey)
            .build()
    }

    func testGetAddressStates() async throws {
        mockServiceExecutor
            .expectURL("https://api.paystack.co/address_verification/states?country=US")
            .expectMethod(.get)
            .expectHeader("Authorization", "Bearer \(apiKey)")
            .andReturn(json: "AddressStatesResponse")

        _ = try await serviceUnderTest.addressStates(for: "US").async()
    }
}
