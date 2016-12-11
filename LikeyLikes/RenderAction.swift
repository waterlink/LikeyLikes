import UIKit

class RenderAction: Action {
    private let viewController: ViewController
    private let messageBus: MessageBus
    
    init(viewController: ViewController,
         messageBus: MessageBus) {
        self.viewController = viewController
        self.messageBus = messageBus
    }
    
    func execute(data: [String : Any]) {
        var items = [[String: Any]]()
        
        guard let params = data["params"] as? [String: Any],
            let header = params["header"] as? String,
            let dataAt = params["dataAt"] as? String else {
                print("[RenderAction] data[params][header] and data[params][dataAt] are required")
                return
        }
        
        guard let rawEvent = data["_rawEvent"] as? String else {
            print("[RenderAction] was not able to find event")
            return
        }
        
        guard var json = Json.parse(rawEvent) else {
            print("[RenderAction] couldn't parse the event: \(rawEvent)")
            return
        }
        
        let parts = dataAt.components(separatedBy: ".")
        
        parts.forEach { part in
            if part != "" {
                json = (json as? [String: Any])?[part] as Any
            }
        }
        
        if let list = json as? [[String: Any]] {
            items = list
        } else {
            print("[RenderAction] can't traverse '\(json)' as a list")
            return
        }

        
        DispatchQueue.main.async {
            self.viewController.updateHeader(header)
            self.viewController.updateItems(items)
            
            if let topic = data["publish"] as? String {
                self.messageBus.publish(topic: topic, event: "")
            }
        }
    }
}
