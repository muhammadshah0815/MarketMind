import Foundation

struct Item: Codable {

    var symbol: String?
    var quote: MyQuote?

}

extension Item: Equatable {

    static func ==(lhs: Item, rhs: Item) -> Bool {
        return lhs.symbol == rhs.symbol
    }

}
