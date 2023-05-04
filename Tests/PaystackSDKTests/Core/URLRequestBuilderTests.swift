import XCTest
@testable import PaystackCore

class URLRequestBuilderTests: XCTestCase {

    let testEndpoint: String = "https://api.paystack.co"

    var builder: URLRequestBuilder!

    override func setUpWithError() throws {
        try super.setUpWithError()
        builder = URLRequestBuilder(endpoint: testEndpoint)
    }

    func testSetMethodBuildsURLRequestWithMethod() throws {
        let result = try builder
            .setMethod(.delete)
            .build()

        XCTAssertEqual("DELETE", result.httpMethod)
    }

    func testBuildThrowsErrorWhenMethodNotProvided() throws {
        XCTAssertThrowsError(try builder.build())
    }

    func testSetHeadersBuildsURLRequestWithHeaders() throws {
        let result = try builder
            .setMethod(.get)
            .setHeaders(["test": "example"])
            .build()

        XCTAssertEqual(["test": "example"], result.allHTTPHeaderFields)
    }

    func testAddHeaderBuildsURLRequestWithHeaderAppended() throws {
        let result = try builder
            .setMethod(.get)
            .addHeader("test", "example")
            .build()

        XCTAssertEqual(["test": "example"], result.allHTTPHeaderFields)
    }

    func testSetPathBuildsURLRequestWithPathAppendedToEndpoint() throws {
        let result = try builder
            .setMethod(.get)
            .setPath("/test")
            .build()

        XCTAssertEqual("\(testEndpoint)/test", result.url?.absoluteString)
    }

    func testSetQueryItemsBuildsURLRequestWithQueryItems() throws {
        let result = try builder
            .setMethod(.get)
            .setQueryItems(["test": "example"])
            .build()

        XCTAssertEqual("\(testEndpoint)?test=example", result.url?.absoluteString)
    }

    func testSetQueryItemsUsingTuplesBuildsURLRequestWithQueryItems() throws {
        let result = try builder
            .setMethod(.get)
            .setQueryItems([("test", "example")])
            .build()

        XCTAssertEqual("\(testEndpoint)?test=example", result.url?.absoluteString)
    }

    func testAddQueryItemBuildsURLRequestWithQueryItems() throws {
        let result = try builder
            .setMethod(.get)
            .addQueryItem("test", "example")
            .build()

        XCTAssertEqual("\(testEndpoint)?test=example", result.url?.absoluteString)
    }

    func testSetEncodableBodyBuildsURLRequestWithBody() throws {
        let result = try builder
            .setMethod(.post)
            .setBody("test")
            .build()

        let encoded = try JSONEncoder().encode("test")
        XCTAssertEqual(encoded, result.httpBody)
    }

    func testSetEncodableBodyBuildsURLRequestWithContentTypeSetToJSON() throws {
        let result = try builder
            .setMethod(.post)
            .setBody("test")
            .build()

        XCTAssertEqual(["Content-Type": "application/json"], result.allHTTPHeaderFields)
    }

    func testSetBodyBuildsURLRequestWithBody() throws {
        let data = try JSONEncoder().encode("test")
        let result = try builder
            .setMethod(.post)
            .setBody(data)
            .build()

        XCTAssertEqual(data, result.httpBody)
    }

    func testAddBearerAuthorizationBuildsURLRequestWithAuthHeader() throws {
        let result = try builder
            .setMethod(.post)
            .addBearerAuthorization("Example")
            .build()

        XCTAssertEqual(["Authorization": "Bearer Example"], result.allHTTPHeaderFields)
    }

    func testAddLoggingBuildsURLRequestWithLoggingHeaders() throws {
        let result = try builder
            .setMethod(.get)
            .addLoggingHeaders()
            .build()

        XCTAssertNotNil(result.value(forHTTPHeaderField: "x-platform"))
        XCTAssertNotNil(result.value(forHTTPHeaderField: "x-sdk-version"))
        XCTAssertNotNil(result.value(forHTTPHeaderField: "x-platform-version"))
        XCTAssertNotNil(result.value(forHTTPHeaderField: "x-device"))
    }
}
