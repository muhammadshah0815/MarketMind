import UIKit

protocol SelectStock {
    func didSelect(_ stock: String?)
}

class AddStockViewController: UIViewController {

    var delegate: SelectStock?
    var provider: Provider?
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var dataSource: [AddSection] = []
    private var query: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        config()
        loadPopularStocks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

private extension AddStockViewController {

    func config() {
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = .black
        tableView.separatorColor = .darkGray
        view.addSubview(tableView)
    }

    func loadPopularStocks() {
        let popularSymbols: [String] = ["AAPL", "TSLA", "NVDA", "MSFT", "SNAP", "UBER", "TWTR", "AMD", "META", "AMZN", "SHOP"]
        dataSource = popularSymbols.dataSource
        tableView.reloadData()
    }

    func setup() {
        title = "Add a Stock"
        view.backgroundColor = .black

        tableView.dataSource = self
        tableView.delegate = self
        tableView.indicatorStyle = .white

        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.styleForDarkMode()
        navigationItem.searchController = search

        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        button.tintColor = .white
        navigationItem.rightBarButtonItem = button
    }
}

extension UISearchBar {
    func styleForDarkMode() {
        self.tintColor = .white
        self.barTintColor = .black
        self.backgroundColor = .black
        if let textField = self.value(forKey: "searchField") as? UITextField {
            textField.textColor = .white
            textField.backgroundColor = .darkGray
        }
    }
}

extension AddStockViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else { return }
        query = text
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(loadSearch), object: nil)
        perform(#selector(loadSearch), with: nil, afterDelay: 0.5)
    }
}

private extension AddStockViewController {
    @objc func loadSearch() {
        print("load search with \(query)")
        provider?.search(query) { items in
            if let items = items {
                self.dataSource = [AddSection(header: "Search", items: items)]
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension AddStockViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if let item = dataSource[indexPath.section].items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.subtitle
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .lightGray
            cell.backgroundColor = .black
            cell.accessoryType = item.alreadyInList ? .checkmark : .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if var item = dataSource[indexPath.section].items?[indexPath.row], !item.alreadyInList {
            delegate?.didSelect(item.title)
            item.alreadyInList.toggle()
            dataSource[indexPath.section].items?[indexPath.row] = item
            tableView.reloadData()
        }
    }
}

struct AddSection {
    var header: String?
    var items: [AddItem]?
}

struct AddItem {
    var title: String?
    var subtitle: String?
    var alreadyInList: Bool
}

private extension Sequence where Iterator.Element == String {
    var dataSource: [AddSection] {
        let items = self.map { AddItem(title: $0, subtitle: nil, alreadyInList: MyStocks().symbols.contains($0)) }
        return [AddSection(header: "Popular Stocks", items: items)]
    }
}
