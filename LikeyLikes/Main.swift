import Foundation

class Main {
    private let messageBus: MessageBus
    private let dslInterpreter: DslInterpreter
    private let actions: [String: Action]
    
    init(messageBus: MessageBus,
         dslInterpreter: DslInterpreter,
         actions: [String: Action]) {
        
        self.messageBus = messageBus
        self.dslInterpreter = dslInterpreter
        self.actions = actions
    }
    
    func run() {
        
        dslInterpreter.run(
            ["name": "builtin.RequestServicesDefinitions",
             "subscribe":
                ["event": "start",
                 "action": "request",
                 "options":
                    ["url": "/services.json",
                     "publish": "rcv_services"]
                ]
            ]
        )
        
        dslInterpreter.run(
            ["name": "builtin.ExtractServiceUrls",
             "subscribe":
                ["event": "rcv_services",
                 "action": "for_each",
                 "options":
                    ["target": ".response.services",
                     "publish": "rcv_service_url"]]]
        )
        
        dslInterpreter.run(
            ["name": "builtin.RequestServiceDefinition",
             "subscribe":
                ["event": "rcv_service_url",
                 "action": "request",
                 "eventAs": "url",
                 "options": ["publish": "rcv_service"]]]
        )
        
        dslInterpreter.run(
            ["name": "builtin.ServiceDefinitionLogger",
             "subscribe":
                ["event": "rcv_service",
                 "action": "log",
                 "options": [
                    "appendEvent": true,
                    "message": "got service definition: "]]]
        )
        
        messageBus.subscribe(topic: "rcv_service_error") { error in
            print("[main] unable to get service definition: \(error)")
        }
        
        messageBus.subscribe(topic: "rcv_services_error") { error in
            print("[main] unabel to get list of services: \(error)")
        }
        
        messageBus.publish(topic: "start", event: "")
        
    }
}
