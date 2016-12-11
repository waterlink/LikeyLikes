import Foundation

class DslInterpreter: Action {
    private let messageBus: MessageBus
    private var actions: [String: Action]
    
    init(messageBus: MessageBus, actions: [String: Action]) {
        self.messageBus = messageBus
        self.actions = actions
        
        self.actions["interpret"] = self
    }
    
    func run(_ dsl: [String: Any]) {
        guard let subscription = dsl["subscribe"] as? [String: Any],
            let serviceName = dsl["name"] as? String else {
                print("[DslInterpreter] DSL has to have 'name' and 'subscribe' fields: dsl='\(dsl)'")
                return
        }
        
        guard let topic = subscription["event"] as? String,
            let actionName = subscription["action"] as? String,
            let options = subscription["options"] as? [String: Any] else {
                print("[DslInterpreter] DSL subscription has to have 'event', 'action' and 'options' fields: dsl='\(dsl)'")
                return
        }
        
        guard let action = actions[actionName] else {
            print("[DslInterpreter] action '\(actionName)' is not implemented")
            return
        }
        
        let interpolateOptions = subscription["interpolateOptions"] as? [String] ?? [];
        
        let eventAs = subscription["eventAs"] as? String ?? "_rawEvent"
        
        messageBus.subscribe(topic: topic) { event in
            var data = options.merged(with:
                [eventAs: event,
                 "_serviceName": serviceName])
            
            if let parsedEvent = Json.parse(event) {
                interpolateOptions.forEach { option in
                    if let string = data[option] as? String {
                        data[option] = self.interpolate(string: string, event: parsedEvent)
                    }
                }
            }
            
            action.execute(data: data)
        }
    }
    
    private func interpolate(string: String, event: Any) -> String {
        do {
            
            var result = string
            
            let regex = try NSRegularExpression(pattern: "\\$\\{(\\.[a-zA-Z0-9_\\.]+)\\}", options: [])
            
            let nsString = NSString(string: string)
            
            let matches = regex.matches(
                in: string,
                options: [],
                range: NSRange(location: 0, length: nsString.length))
            
            let expressions = matches.map { match in
                nsString.substring(with: match.rangeAt(1))
            }
            
            print("[DEBUG] expressions='\(expressions)'")
            
            expressions.forEach { expression in
                if let value = Json.query(event, at: expression) {
                    result = result.replacingOccurrences(of: "${\(expression)}", with: "\(value)")
                }
            }
            
            print("[DEBUG] interpolated '\(string)' to '\(result)' using data '\(event)'")
            return result
            
        } catch {
            print("[DslInterpreter] invalid regex: \(error)")
            return string
        }
    }
    
    func execute(data: [String : Any]) {
        guard let raw = data["_rawEvent"] as? String,
            let dsl = Json.parse(raw) as? [String: Any] else {
                print("[DslInterpreter Action] raw event was not found or is not a valid JSON: data=\(data)")
                return
        }
        
        run(dsl)
        
        if let serviceName = dsl["name"] as? String {
            messageBus.publish(topic: "\(serviceName)_start", event: "")
        }
    }
}
