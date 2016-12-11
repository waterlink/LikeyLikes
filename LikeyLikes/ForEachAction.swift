class ForEachAction: Action {
    let messageBus: MessageBus
    
    init(messageBus: MessageBus) {
        self.messageBus = messageBus
    }
    
    func execute(data: [String : Any]) {
        guard let target = data["target"] as? String else {
            print("[ForEachAction] data[target] is required")
            return
        }
        
        guard let topic = data["publish"] as? String else {
            print("[ForEachAction] data[publish] is required")
            return
        }
        
        guard let rawEvent = data["_rawEvent"] as? String else {
            print("[ForEachAction] was not able to find event")
            return
        }
        
        guard var json = Json.parse(rawEvent) else {
            print("[ForEacAction] couldn't parse the event: \(rawEvent)")
            return
        }
        
        let parts = target.components(separatedBy: ".")
        
        parts.forEach { part in
            if part != "" {
                json = (json as? [String: Any])?[part] as Any
            }
        }
        
        guard let list = json as? [Any] else {
            print("[ForEachAction] can't traverse '\(json)' as a list")
            return
        }
        
        list.forEach { value in
            guard let event = Json.dump(value) else {
                print("[ForEachAction] can't dump '\(value)' to JSON")
                return
            }
            
            messageBus.publish(topic: topic, event: event)
        }
    }
}
