import XCTest
import PaystackCore

class PaystackBuilderTests: XCTestCase {

    var builder: PaystackBuilder!

    override func setUpWithError() throws {
        try super.setUpWithError()
        builder = .newInstance
    }

    func testBuildReturnsPaystackInstance() throws {
        XCTAssertNoThrow(try builder
                            .setKey("testsk_exampleKey")
                            .build())
    }

    func testBuildThrowsErrorWhenNoAPIKeyProvided() throws {
        do {
            _ = try builder.build()
            XCTFail("Builder did not throw noAPIKey error")
        } catch {
            XCTAssertEqual(PaystackError.noAPIKey, error as? PaystackError)
        }
    }

    func testDisplayAudienceDefaultsToCustomerFacing() throws {
        let paystack = try builder
            .setKey("testsk_exampleKey")
            .build()
        XCTAssertEqual(paystack.config.displayAudience, .customerFacing)
    }

    func testSetDisplayAudienceSetsMerchantFacingOnConfig() throws {
        let paystack = try builder
            .setKey("testsk_exampleKey")
            .setDisplayAudience(.merchantFacing)
            .build()
        XCTAssertEqual(paystack.config.displayAudience, .merchantFacing)
    }

    func testSetDisplayAudienceLastCallWins() throws {
        let paystack = try builder
            .setKey("testsk_exampleKey")
            .setDisplayAudience(.merchantFacing)
            .setDisplayAudience(.customerFacing)
            .build()
        XCTAssertEqual(paystack.config.displayAudience, .customerFacing)
    }

    func testDisplayAudienceValuesAreDistinct() {
        XCTAssertNotEqual(DisplayAudience.customerFacing, DisplayAudience.merchantFacing)
    }

}
