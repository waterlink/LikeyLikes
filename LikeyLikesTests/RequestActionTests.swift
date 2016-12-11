import XCTest
@testable import LikeyLikes

class RequestActionTests: XCTestCase {
    let messageBus = MessageBus()
    let httpClient = FakeHttpClient()
    var requestAction: RequestAction!
    var receivedData: String?
    
    override func setUp() {
        requestAction = RequestAction(
            messageBus: messageBus,
            httpClient: httpClient)
    }
    
    func testMakesRequest_andPublishesToBus() {
        let asyncExpectation = expectation(description: "rcv_items")
        
        messageBus.subscribe(topic: "rcv_items") { data in
            self.receivedData = data
            asyncExpectation.fulfill()
        }
        
        httpClient.preparedResponse = "{\"items\": []}"
        
        requestAction.execute(data: [
            "url": "/items",
            "publish": "rcv_items"])
        
        waitForExpectations(timeout: 0.1) { error in
            XCTAssertEqual("/items", self.httpClient.repliedToUrl)
            XCTAssertEqual(
                "{\"response\":{\"items\":[]}}",
                self.receivedData)
        }
    }
    
    func testDifferentInputs() {
        let asyncExpectation = expectation(description: "rcv_users")
        
        messageBus.subscribe(topic: "rcv_users") { data in
            self.receivedData = data
            asyncExpectation.fulfill()
        }
        
        httpClient.preparedResponse = "{\"users\": []}"
        
        requestAction.execute(data: [
            "url": "/users",
            "publish": "rcv_users"])
        
        waitForExpectations(timeout: 0.1) { error in
            XCTAssertEqual("/users", self.httpClient.repliedToUrl)
            XCTAssertEqual(
                "{\"response\":{\"users\":[]}}",
                self.receivedData)
        }
    }
    
    func testError() {
        let asyncExpectation = expectation(description: "rcv_users_error")
        
        messageBus.subscribe(topic: "rcv_users_error") { data in
            self.receivedData = data
            asyncExpectation.fulfill()
        }
        
        httpClient.preparedError = DummyError()
        
        requestAction.execute(data: [
            "url": "/users",
            "publish": "rcv_users"])
        
        waitForExpectations(timeout: 0.1) { error in
            XCTAssertEqual("/users", self.httpClient.repliedToUrl)
            XCTAssertEqual(
                "{\"error\":\"LikeyLikesTests.DummyError\"}",
                self.receivedData)
        }
    }
}

class FakeHttpClient: HttpClient {
    var preparedResponse: String = ""
    var preparedError: Error?
    var repliedToUrl: String?
    
    func get(url: String, handler: @escaping (String, Error?) -> Void) {
        repliedToUrl = url
        handler(preparedResponse, preparedError)
    }
}

class DummyError: Error {
    
}
