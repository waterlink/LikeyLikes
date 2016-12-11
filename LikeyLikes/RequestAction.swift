import Foundation

public class RequestAction: Action {
    private let messageBus: MessageBus
    private let httpClient: HttpClient
    
    public init(
        messageBus: MessageBus,
        httpClient: HttpClient) {
        
        self.messageBus = messageBus;
        self.httpClient = httpClient;
    }
    
    public func execute(data: [String: Any]) {
        guard let topic = data["publish"] as? String else {
            print("[RequestAction] data[publish] is not a string")
            return
        }
        
        guard let url = data["url"] as? String else {
            print("[RequestAction] data[url] is not a string")
            return
        }
        
        httpClient.get(url: url) { response, error in
            
            if let error = error {
                self.handleError(error: error, topic: topic)
                return
            }
            
            guard let json = Json.parse(response),
                let result = Json.dump(["response": json]) else {
                    print("[RequestAction] unable to parse/dump response")
                    return
            }
            
            self.messageBus.publish(topic: topic,
                               event: result)
            
        }
    }
    
    private func handleError(error: Error, topic: String) {
        print("[RequestAction] http error: \(error)")
        
        guard let result = Json.dump(["error": "\(error)"]) else {
            print("[RequestAction] unable to dump error response")
            return
        }
        
        messageBus.publish(
            topic: "\(topic)_error",
            event: result)
    }
}
