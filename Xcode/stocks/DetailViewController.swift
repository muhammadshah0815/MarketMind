import UIKit

class DetailViewController: UIViewController {

    var item: Item? {
        didSet {
            title = item?.symbol
            fetchData(item?.symbol)
        }
    }

    var provider: Provider?

    private var dataSource: [DetailSection] = []

    private let tableview = UITableView(frame: .zero, style: .insetGrouped)

    private let spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

}

private extension DetailViewController {

    @objc
    func close() {
        self.dismiss(animated: true, completion: nil)
    }

    func fetchData(_ symbol: String?) {
        spinner.startAnimating()

        let priceItems = item?.items

        provider?.getDetail(symbol, completion: { (sections, image) in
            self.spinner.stopAnimating()

            // Remove any image from the header, ensuring no logo is displayed
            self.tableview.tableHeaderView = nil

            var s = sections
            let priceSection = DetailSection(items: priceItems)
            let index = s.count > 1 ? 1 : 0
            s.insert(priceSection, at: index)

            self.dataSource = s
            self.tableview.reloadData()
        })
    }

    func setup() {
        view.backgroundColor = .darkGray // Dark gray background

        let button = Theme.closeButton
        button.target = self
        button.action = #selector(close)
        navigationItem.rightBarButtonItem = button

        tableview.dataSource = self
        tableview.delegate = self
        tableview.frame = view.bounds
        tableview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableview.backgroundColor = .darkGray // Dark gray table view background
        tableview.separatorColor = .lightGray // Light gray separator color between cells
        view.addSubview(tableview)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

extension DetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let section = dataSource[indexPath.section]

        return section.items?[indexPath.row].url != nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)

        let section = dataSource[indexPath.section]
        if let item = section.items?[indexPath.row], let url = item.url {
            UIApplication.shared.open(url)
        }
    }
}

extension DetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].header
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "detail")

        let section = dataSource[indexPath.section]
        if let item = section.items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.textLabel?.textColor = .white
            cell.textLabel?.numberOfLines = 0

            cell.detailTextLabel?.text = item.subtitle
            cell.detailTextLabel?.textColor = .white
            cell.detailTextLabel?.numberOfLines = 0

            cell.accessoryType = item.url == nil ? .none : .disclosureIndicator
            cell.selectionStyle = .none
        }

        return cell
    }
}

struct DetailSection {
    var header: String?
    var items: [DetailItem]?
}

struct DetailItem {
    var subtitle: String?
    var title: String?
    var url: URL?
}

private extension Item {
    var items: [DetailItem] {
        var items = [DetailItem]()
        items.append(DetailItem(subtitle: "Price", title: quote?.price.currency))
        items.append(DetailItem(subtitle: "Change", title: quote?.change.displaySign))
        items.append(DetailItem(subtitle: "Percent Change", title: quote?.percent.displaySign))
        return items
    }
}
