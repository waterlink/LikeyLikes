import Foundation

public class MessageBus {
    var topics: [String: [(String) -> Void]] = [:]
    var subscriber: ((String) -> Void)?
    
    public func publish(topic: String, event: String) {
        (topics[topic] ?? []).forEach { subscriber in
            DispatchQueue.global().async {
                subscriber(event)
            }
        }
    }
    
    public func subscribe(topic: String,
                          handler: @escaping (String) -> Void) {
        
        if topics[topic] == nil {
            topics[topic] = []
        }
        
        topics[topic]?.append(handler)
    }
}
