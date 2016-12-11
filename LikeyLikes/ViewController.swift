import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var items = [[String: Any]]()
    
    var messageBus: MessageBus!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateHeader(_ header: String) {
        headerLabel.text = header
    }
    
    func updateItems(_ items: [[String: Any]]) {
        self.items = items
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let id = "ItemCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: id)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: id)
        }
        
        let title = items[indexPath.row]["title"] as? String ?? ""
        
        cell?.textLabel?.text = title
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        
        let id = item["id"] as? Int ?? -1
        let selectMeaning = item["selectMeaning"] as? String ?? "selected"
        
        guard let event = Json.dump(["id": id]) else {
            print("[ViewController] unable to dump selected item data")
            return
        }
        
        messageBus.publish(topic: "item_\(selectMeaning)", event: event)
    }


}
