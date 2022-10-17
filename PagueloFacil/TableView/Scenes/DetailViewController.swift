import Foundation
import UIKit

class DetailViewController:  UIViewController {
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    var transaction: [String: String] = [:]

    override func viewDidLoad() {
        tableView.register(UINib(nibName: "DetailViewCell", bundle: nil), forCellReuseIdentifier: "detailViewCell")
        super.viewDidLoad()
        self.amount.text = transaction["Amount"] ?? "Amount"
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailViewCell", for: indexPath) as! DetailViewCell
        cell.title?.text = Array(transaction.keys)[indexPath.row]
        cell.value?.text = Array(transaction.values)[indexPath.row]
        return cell
    }

}
