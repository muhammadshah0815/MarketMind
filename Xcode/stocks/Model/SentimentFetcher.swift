import Foundation

struct Sentiment: Codable {
    let ticker: String
    let score: Double
    let label: String
    let relevance: Double
}

class SentimentFetcher {
    static let shared = SentimentFetcher()
    let apiKey = "<ENTER_API_KEY>"

    private init() {}

    func fetchSentiment(for ticker: String, completion: @escaping (Result<[Sentiment], Error>) -> Void) {
        let urlString = "https://www.alphavantage.co/query?function=NEWS_SENTIMENT&tickers=\(ticker)&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let feed = jsonData?["feed"] as? [[String: Any]] ?? []
                var sentiments: [Sentiment] = []
                
                for article in feed {
                    if let tickerSentiment = article["ticker_sentiment"] as? [[String: Any]] {
                        for sentimentData in tickerSentiment {
                            let ticker = sentimentData["ticker"] as? String ?? "N/A"
                            let score = Double(sentimentData["ticker_sentiment_score"] as? String ?? "0") ?? 0.0
                            let label = sentimentData["ticker_sentiment_label"] as? String ?? "N/A"
                            let relevance = Double(sentimentData["relevance_score"] as? String ?? "0") ?? 0.0
                            let sentiment = Sentiment(ticker: ticker, score: score, label: label, relevance: relevance)
                            sentiments.append(sentiment)
                        }
                    }
                }
                completion(.success(sentiments))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
