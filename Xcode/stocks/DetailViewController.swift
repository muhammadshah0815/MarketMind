/*
 Updated Project Directory Structure for MarketMind:
 mathematica
 Copy code
 MarketMind/
 ├── stocks/
 │   ├── Info.swift
 │   ├── AddStockViewController.swift
 │   ├── AppDelegate.swift
 │   ├── DetailViewController.swift
 │   ├── Extension.swift
 │   ├── Item.swift
 │   ├── MyStocksViewController.swift
 │   ├── SceneDelegate.swift
 │   ├── Theme.swift
 │   ├── UpdateLabel.swift
 │   ├── UserDefault.swift
 ├── Assets/
 │   ├── LaunchScreen.storyboard
 │   ├── Main.storyboard
 ├── Model/
 │   ├── Finnhub.swift
 │   ├── MyQuote.swift
 │   ├── Provider.swift
 │   ├── SentimentFetcher.swift
 File Functionalities:
 Info.swift: Likely contains constants or configurations used across the app.
 AddStockViewController.swift: Manages the UI and logic for adding new stock entries by the user.
 AppDelegate.swift: Entry point of the app's lifecycle, handling initial setup.
 DetailViewController.swift: Manages the display of detailed information for a selected stock, including sentiment analysis.
 Extension.swift: Could include Swift extensions for enhancing existing types or classes.
 Item.swift: Likely defines the data structure for stock items.
 MyStocksViewController.swift: Controls the view that lists all the stocks the user is tracking.
 SceneDelegate.swift: Handles scene lifecycle events in iOS 13 and later.
 Theme.swift: Manages theming or styling for the app’s UI.
 UpdateLabel.swift: Possibly a custom UILabel for displaying updated information.
 UserDefault.swift: Manages saving and retrieving user preferences or settings.
 Finnhub.swift, MyQuote.swift, Provider.swift, SentimentFetcher.swift: Handle data modeling and fetching of stock and sentiment data.
 Assets:
 LaunchScreen.storyboard: Configures the launch screen of the app.
 Main.storyboard: Contains the main interface of the app.
 */

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

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        initializeDataSections()
        tableView.reloadData()  // Make sure to reload with the initial data
    }

    
    func initializeDataSections() {
        // Add a placeholder sentiment section from the start
        let placeholderSentimentItem = DetailItem(subtitle: "Loading...", title: "Sentiment Analysis", sentiment: "Awaiting data...")
        let sentimentSection = DetailSection(header: "Sentiments", items: [placeholderSentimentItem])
        dataSource.append(sentimentSection)
    }



    func fetchData(_ symbol: String?) {
        guard let symbol = symbol else { return }
        spinner.startAnimating()

        // Asynchronously fetch sentiment data
        fetchSentimentData(for: symbol)

        // Asynchronously fetch other details
        provider?.getDetail(symbol, completion: { [weak self] sections, image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.spinner.stopAnimating()

                // Prepare other sections
                let priceSection = DetailSection(header: "Stock Details", items: self.item?.items ?? [])
                var updatedSections = [self.dataSource.first!]  // Start with the sentiment section
                updatedSections.append(priceSection)  // Add price details
                updatedSections.append(contentsOf: sections)  // Add additional fetched sections

                self.dataSource = updatedSections
                self.tableView.reloadData()
            }
        })
    }

    func fetchSentimentData(for ticker: String) {
        provider?.getSentiment(for: ticker) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let sentimentIndex = self.dataSource.firstIndex(where: { $0.header == "Sentiments" })!

                switch result {
                case .success(let sentimentItem):
                    self.dataSource[sentimentIndex].items = [sentimentItem]
                case .failure(let error):
                    let errorItem = DetailItem(subtitle: "Error", title: "Failed to load sentiment data", sentiment: error.localizedDescription)
                    self.dataSource[sentimentIndex].items = [errorItem]
                }

                self.tableView.reloadSections([sentimentIndex], with: .automatic)
            }
        }
    }



    private func setup() {
        view.backgroundColor = .darkGray
        let button = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = button

        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = .darkGray
        tableView.separatorColor = .lightGray
        view.addSubview(tableView)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func close() {
        dismiss(animated: true, completion: nil)
    }

    


}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "detailCell")
        let section = dataSource[indexPath.section]
        if let item = section.items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.textLabel?.textColor = item.color ?? .white
            cell.detailTextLabel?.text = item.sentiment ?? item.subtitle
            cell.detailTextLabel?.textColor = .white
            cell.selectionStyle = .none
            cell.accessoryType = item.url != nil ? .disclosureIndicator : .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = dataSource[indexPath.section]
        if section.header == "Sentiments" {
            // Optionally add action on sentiment cell tap
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerText = dataSource[section].header
        let header = UILabel()
        
        // Configuring the header's appearance
        header.text = headerText
        header.textColor = .white
        header.backgroundColor = .darkGray
        header.textAlignment = .left
        header.font = UIFont.systemFont(ofSize: 13, weight: .semibold)  // Set font size and weight to match default

        // Applying padding
        header.frame = CGRect(x: 5, y: 0, width: tableView.bounds.width - 30, height: 28)
        
        // Wrapping the label in a UIView for better control
        let headerView = UIView()
        headerView.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .darkGray

        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            header.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),
            header.topAnchor.constraint(equalTo: headerView.topAnchor),
            header.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28  // Adjust height to match the default or your preferred size
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
    var color: UIColor?
    var sentiment: String? // New field for sentiment data
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
