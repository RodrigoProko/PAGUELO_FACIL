import UIKit

class TransactionsTableViewController:  UITableViewController, UISearchResultsUpdating  {
    
    let searchController = UISearchController()
    @IBOutlet weak var searchBar: UISearchBar!
    private var transactions : [Transaction] = []
    private var filtered : [Transaction] = []
    private let cellIdentifier: String = "tableCell"
    private var transactionsCount: Int = 0
    private var searchText: String = ""
    private var filters: [[String: String]] = []
    private var sortBy: [String: String] = [:]
    private var showAll: Bool = true
    private var selectedBtn: String = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initSearchController()
    }
    
    func initSearchController()
    {
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        searchController.searchBar.placeholder = "Search by ID"
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchBar.scopeButtonTitles = [Filter.ALL, Filter.APPROVED, Filter.DATE, Filter.AMOUNT]
        searchController.searchBar.delegate = self
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.sizeToFit()
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {
        let searchBar = searchController.searchBar
        let scopeButton = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        let searchText = searchBar.text!
        
        filterForSearchTextAndScopeButton(searchText: searchText, scopeButton: scopeButton)
    }
    
    func filterForSearchTextAndScopeButton(searchText: String, scopeButton : String = Filter.ALL)
    {
        if(self.selectedBtn == scopeButton) {
            return
        }
        self.selectedBtn = scopeButton
        self.showAll = scopeButton == Filter.ALL
        if(self.searchText == "") {
            self.filters = []
        }
        switch scopeButton {
            case Filter.APPROVED:
                self.sortBy = [:]
                if(self.searchText != "") {
                    return
                }
                let loader = self.loader()
                self.filters = [Filter.APPROVED_FILTER]
                Task {
                    self.filtered = try await Transaction.searchTransactions(filters: self.filters, sortBy: self.sortBy)
                    self.stopLoader(loader: loader)
                    tableView.reloadData()
                }
            case Filter.DATE:
                self.sortBy = Filter.DATE_FILTER
                let loader = self.loader()
                Task {
                    self.filtered = try await Transaction.searchTransactions(filters: self.filters, sortBy: self.sortBy)
                    self.stopLoader(loader: loader)
                    tableView.reloadData()
                }
            case Filter.AMOUNT:
                let loader = self.loader()
                self.sortBy = Filter.AMOUNT_FILTER
                Task {
                    self.filtered = try await Transaction.searchTransactions(filters: self.filters, sortBy: self.sortBy)
                    self.stopLoader(loader: loader)
                    tableView.reloadData()
                }
            case Filter.ALL:
                self.sortBy = [:]
                if(self.searchText != "") {
                    return
                }
                let loader = self.loader()
                Task {
                    self.filtered =  try await Transaction.requestTransactions(offset: 0, params: "")
                    self.stopLoader(loader: loader)
                    tableView.reloadData()
                    return
                }
            default:
                return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "transactionDetail",
            let indexPath = tableView?.indexPathForSelectedRow,
            let destinationViewController: DetailViewController = segue.destination as? DetailViewController {
            destinationViewController.transaction = transactionDetails(transaction: self.filtered[indexPath.row])
        }
    }
    
    func transactionDetails(transaction: Transaction) -> [String: String] {
        var details: [String: String] = [:]
        details["Amount"] =  "$"+String(transaction.amount ?? 0)
        details["ID"] = String(transaction.idTransaction ?? 0)
        details["Status"] = String(transaction.status ?? 0)
        details["Name"] = String(transaction.merchantName ?? "")
        details["Country"] = String(transaction.ipCountry ?? "")
        details["Email"] = String(transaction.email ?? "")
        details["Phone"] = String(transaction.phone ?? "")
        details["CardType"] = String(transaction.cardType ?? "")
        details["DateTms"] = String(transaction.dateTms ?? "")
        details["Address"] = String(transaction.address ?? "")
        details["Concept"] = String(transaction.txConcept ?? "")
        return details
    }

}

extension TransactionsTableViewController {

    private func setupUI() {
        let loader = self.loader()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: nil)
        navigationItem.title = "Transactions"
        Task {
            self.transactionsCount = try await Transaction.countItems()
            self.transactions = try await Transaction.requestTransactions(offset: 0, params: "")
            self.filtered = self.transactions
            self.stopLoader(loader: loader)
            tableView.reloadData()
        }
        
    }

}

extension TransactionsTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? TableCell {
            cell.configurateTheCell(filtered[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }

}

extension TransactionsTableViewController {

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (self.filtered.count == self.transactionsCount
            || self.searchText != "" || !self.showAll
        ) {
            return
        }
        if (indexPath.row  == self.filtered.count - 1 && self.filtered.count != self.transactionsCount) {
            Task {
                self.filtered.append(contentsOf: try await Transaction.requestTransactions(offset: indexPath.row + 1, params: ""))
                tableView.reloadData()
            }
        }
    }

}


extension TransactionsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let loader = loader()
        if(self.searchText != "" && searchText == "" && self.showAll) {
            Task {
                self.filtered =  try await Transaction.requestTransactions(offset: 0, params: searchText)
                self.searchText = searchText
                tableView.reloadData()
                stopLoader(loader: loader)
                return
            }
        }
        self.filters = [[
            "field": "idTransaction",
            "operator": "$eq",
            "value": searchText,
            "isNumber": "1"
        ]]
        if(self.selectedBtn != Filter.ALL && searchText == "") {
            self.filters = []
        }
        if(self.selectedBtn == Filter.APPROVED) {
            self.filters.append(Filter.APPROVED_FILTER)
        }
        if(self.selectedBtn == Filter.DATE) {
            self.sortBy = Filter.DATE_FILTER
        }
        if(self.selectedBtn == Filter.AMOUNT) {
            self.sortBy = Filter.AMOUNT_FILTER
        }
        Task {
            self.filtered = try await Transaction.searchTransactions(filters: self.filters, sortBy: self.sortBy)
            self.searchText = searchText
            stopLoader(loader: loader)
            tableView.reloadData()
        }
    }
}

extension TransactionsTableViewController {
    func loader() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.large
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        return alert
    }
    func stopLoader(loader: UIAlertController) {
        DispatchQueue.main.async {
            loader.dismiss(animated: true, completion: nil)
        }
    }
}
