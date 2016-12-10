import XCTest
@testable import LikeyLikes

class MessageBusTests: XCTestCase {
    
    var messageBus = MessageBus()
    var received: [String] = []
    
    func testPubSub() {
        let asyncExpectation = expectation(description: "subscriber received something")
        
        self.messageBus.subscribe(topic: "event") { event in
            self.received.append(event)
            asyncExpectation.fulfill()
        }
        
        messageBus.publish(topic: "event", event: "hello world")
        messageBus.publish(topic: "other_topic", event: "---")
        
        waitForExpectations(timeout: 0.1) { error in
            XCTAssertEqual(["hello world"], self.received)
        }
    }
    
    func testPubSub_withDifferentTopic_andData() {
        let asyncExpectation = expectation(description: "subscriber received something")
        
        self.messageBus.subscribe(topic: "different") { event in
            self.received.append(event)
            asyncExpectation.fulfill()
        }
        
        messageBus.publish(topic: "different", event: "great text!")
        messageBus.publish(topic: "other_topic", event: "---")
        
        waitForExpectations(timeout: 0.1) { error in
            XCTAssertEqual(["great text!"], self.received)
        }
    }
    
    func testPubSub_multipleReceivers() {
        let expectationOne = expectation(description: "subscriber A")
        let expectationTwo = expectation(description: "subscriber B")
        
        self.messageBus.subscribe(topic: "event") { event in
            self.received.append(event)
            expectationOne.fulfill()
        }
        
        self.messageBus.subscribe(topic: "event") { event in
            self.received.append(event)
            expectationTwo.fulfill()
        }
        
        messageBus.publish(topic: "event", event: "hello world")
        messageBus.publish(topic: "other_topic", event: "---")
        
        waitForExpectations(timeout: 0.1) { error in
            XCTAssertEqual(["hello world", "hello world"],
                           self.received)
        }
    }
}
