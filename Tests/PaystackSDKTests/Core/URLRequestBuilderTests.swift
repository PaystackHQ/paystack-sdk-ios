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

    // MARK: - setFormBody — application/x-www-form-urlencoded

    func testSetFormBodyBuildsURLRequestWithFormUrlencodedContentType() throws {
        let result = try builder
            .setMethod(.post)
            .setFormBody(["wallet_id": "test@example.com"])
            .build()

        XCTAssertEqual(result.value(forHTTPHeaderField: "Content-Type"),
                       "application/x-www-form-urlencoded")
    }

    func testSetFormBodyEncodesSimpleField() throws {
        let result = try builder
            .setMethod(.post)
            .setFormBody(["wallet_id": "alice"])
            .build()

        let body = try XCTUnwrap(result.httpBody)
        XCTAssertEqual(String(data: body, encoding: .utf8), "wallet_id=alice")
    }

    func testSetFormBodyPercentEncodesEmailValue() throws {
        let result = try builder
            .setMethod(.post)
            .setFormBody(["wallet_id": "customer@example.com"])
            .build()

        let body = try XCTUnwrap(result.httpBody)
        XCTAssertEqual(String(data: body, encoding: .utf8),
                       "wallet_id=customer%40example.com")
    }

    func testSetFormBodyPercentEncodesAmpersandsAndSpacesInValue() throws {
        let result = try builder
            .setMethod(.post)
            .setFormBody(["note": "hello & welcome"])
            .build()

        let body = try XCTUnwrap(result.httpBody)
        XCTAssertEqual(String(data: body, encoding: .utf8),
                       "note=hello%20%26%20welcome")
    }

    func testSetFormBodyJoinsMultipleFieldsWithAmpersand() throws {
        let result = try builder
            .setMethod(.post)
            .setFormBody(["a": "1", "b": "2"])
            .build()

        let body = try XCTUnwrap(result.httpBody)

        let text = String(data: body, encoding: .utf8)
        XCTAssertTrue(text == "a=1&b=2" || text == "b=2&a=1",
                      "Unexpected encoded body: \(text ?? "nil")")
    }
}
