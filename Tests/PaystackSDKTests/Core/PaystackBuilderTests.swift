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

}
