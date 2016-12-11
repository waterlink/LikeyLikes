import UIKit

class RenderAction: Action {
    private let viewController: ViewController
    
    init(viewController: ViewController) {
        self.viewController = viewController
    }
    
    func execute(data: [String : Any]) {
        guard let params = data["params"] as? [String: Any],
            let header = params["header"] as? String else {
            print("[RenderAction] data[params][header] is required")
            return
        }
        
        DispatchQueue.main.async {
            print("UPDATING!!")
            self.viewController.updateHeader(header)
        }
    }
}
