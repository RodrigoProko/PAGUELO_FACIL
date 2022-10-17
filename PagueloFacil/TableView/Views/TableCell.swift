import Foundation
import UIKit

class TableCell: UITableViewCell {

    @IBOutlet weak var id: UILabel!
    
    @IBOutlet weak var amount: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        id.text = "ID"
        amount.text = "Monto"
    }

    func configurateTheCell(_ transaction: Transaction) {
        id.text = "ID#:" + String(transaction.idTransaction ?? 0)
        amount.text = "$"+String(transaction.amount ?? 0)
    }

}
