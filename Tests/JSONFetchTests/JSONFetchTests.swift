import XCTest
import JSONFetch

class JSONFetchTests: XCTestCase {


    override func setUp() {
        super.setUp()

    }

    func testGet() {

        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Download a Hello World JSON.")


        Fetch.new(host: "www.mocky.io")
                .contentType(.formURLEncoded)
                .set(path: "/v2/5185415ba171ea3a00704eed")
                .fetch(with: .GET) { result in

                    switch result {
                    case .error(let error, _):
                        XCTAssertNotNil(error, "Request failed: \(error)")
                    case .ok(let data, _):

                        XCTAssertNotNil(String(data: data, encoding: .utf8))

                        if let jsonString = String(data: data, encoding: .utf8) {
                            XCTAssert(jsonString == "{\"hello\": \"world\"}", "JSON Was not valid: \(jsonString)")
                        }


                    }


                    // Fulfill the expectation, this will tell our test end that the async task has finished.
                    expectation.fulfill()

                }


        wait(for: [expectation], timeout: 10.0)

    }

    override func tearDown() {
        super.tearDown()
    }
}