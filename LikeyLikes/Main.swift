import Foundation

class Main {
    private let messageBus: MessageBus
    private let dslInterpreter: DslInterpreter
    
    init(messageBus: MessageBus,
         dslInterpreter: DslInterpreter) {
        
        self.messageBus = messageBus
        self.dslInterpreter = dslInterpreter
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
        
        dslInterpreter.run(
            ["name": "builtin.ServiceDefinitionParser",
             "subscribe":
                ["event": "rcv_service",
                 "action": "for_each",
                 "options":
                    ["target": ".response",
                     "publish": "service_definition_parsed"]]]
        )
        
        dslInterpreter.run(
            ["name": "builtin.ServiceDefinitionInterpreter",
             "subscribe":
                ["event": "service_definition_parsed",
                 "action": "interpret",
                 "options": [:]]]
        )
        
        dslInterpreter.run(
            ["name": "builtin.ServiceDefinitionErrorLogger",
             "subscribe":
                ["event": "rcv_service_error",
                 "action": "log",
                 "options":
                    ["appendEvent": true,
                     "message": "unable to get service definition: "]]]
        )
        
        dslInterpreter.run(
            ["name": "builtin.ServicesDefinitionsErrorLogger",
             "subscribe":
                ["event": "rcv_services_error",
                 "action": "log",
                 "options":
                    ["appendEvent": true,
                     "message": "unable to get list of services: "]]]
        )
        
        messageBus.publish(topic: "start", event: "")
        
    }
}
