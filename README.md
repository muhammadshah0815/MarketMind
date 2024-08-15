# MarketMind

MarketMind is an iOS application that provides detailed insights into stock performance and sentiment analysis, leveraging real-time financial data from Finnhub and Alpha Vantage.


## Prerequisites

Before you begin, ensure you have the following installed:
- Xcode 12 or later
- Swift 5.2 or later
- An iOS device or simulator running iOS 14 or later


## API Keys

You will need to obtain API keys from the following services:
- Finnhub: Register at [Finnhub](https://finnhub.io/) to get your API key.
- Alpha Vantage: Register at [Alpha Vantage](https://www.alphavantage.co/) to get your API key.


## Setup Instructions

1. **Clone the Repository**
   
   Clone the project to your local machine using the following command:
   ```bash
   git clone https://github.com/muhammadshah0815/MarketMind.git
   cd MarketMind
   ```
   
3. **Open the Project**
   
   Open the project by navigating to the cloned directory and opening the workspace file in Xcode:
   ```bash
   open stocks.xcworkspace
   ```
   
5. **Enter API Keys**
   
   In Finnhub.swift:
   ```
   static let apiKey = "<ENTER_API_KEY>"
   ```
   In SentimentFetcher.swift:
   ```
   let apiKey = "<ENTER_API_KEY>"
   ```

7. **Build and Run**
   
   Build and run the application in Xcode by selecting your target device and clicking the 'Run' button.


## Usage

Use the application to:
- View real-time stock prices.
- Analyze stock sentiment.
- Read latest financial news related to the stocks.


## Acknowledgments

- **Finnhub** for providing the financial data API.
- **Alpha Vantage** for the sentiment analysis API.
