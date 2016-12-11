class LogAction: Action {
    func execute(data: [String : Any]) {
        guard let message = data["message"] as? String else {
            print("[LogAction] data[message] is required")
            return
        }
        
        guard let serviceName = data["_serviceName"] as? String else {
            print("[LogAction] service is required to be named")
            return
        }
        
        let appendEvent = data["appendEvent"] as? Bool ?? false
        
        if appendEvent {
            let rawEvent = data["_rawEvent"]
            
            print("[\(serviceName)] \(message) event='\(rawEvent)'")
        } else {
            print("[\(serviceName)] \(message)")
        }
    }
}
