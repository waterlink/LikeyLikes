class DslInterpreter {
    private let messageBus: MessageBus
    private let actions: [String: Action]
    
    init(messageBus: MessageBus, actions: [String: Action]) {
        self.messageBus = messageBus
        self.actions = actions
    }
    
    func run(_ dsl: [String: Any]) {
        guard let subscription = dsl["subscribe"] as? [String: Any],
            let topic = subscription["event"] as? String,
            let actionName = subscription["action"] as? String,
            let options = subscription["options"] as? [String: Any] else {
                print("[DslInterpreter] DSL has to have 'event', 'action' and 'options' parameters")
                return
        }
        
        guard let action = actions[actionName] else {
            print("[DslInterpreter] action '\(actionName)' is not implemented")
            return
        }
        
        let eventAs = subscription["eventAs"] as? String ?? "rawEvent"
        
        messageBus.subscribe(topic: topic) { event in
            let data = options.merged(with: [eventAs: event])
            action.execute(data: data)
        }
    }
}
