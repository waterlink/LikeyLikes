import Foundation

public class RequestAction {
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
                handleError(error: error, topic: topic)
                return
            }
            
            guard let json = Json.parse(response),
                let result = Json.dump(["response": json]) else {
                    print("[RequestAction] unable to parse/dump response")
                    return
            }
            
            messageBus.publish(topic: topic,
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

public protocol HttpClient {
    func get(url: String, handler: (String, Error?) -> Void)
}

class Json {
    static func parse(_ string: String) -> Any? {
        do {
            return try JSONSerialization.jsonObject(
                with: string.data(using: .utf8)!,
                options: .mutableContainers)
        } catch {
            print("[Json] unable to parse json: \(error)")
            return nil
        }
    }
    
    static func dump(_ data: Any) -> String? {
        do {
            let result = try JSONSerialization.data(
                withJSONObject: data,
                options: JSONSerialization.WritingOptions())
            
            return encode(data: result)
        } catch {
            print("[Json] unable to dump json: \(error)")
            return nil
        }
    }
    
    private static func encode(data: Data) -> String? {
        guard let string = String(
            data: data,
            encoding: String.Encoding.utf8) else {
                print("[Json] unable to encode json data to string")
                return nil
        }
        
        return string
    }
}
