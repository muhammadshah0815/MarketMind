import UIKit

struct Theme {

    static let attributes = [ NSAttributedString.Key.foregroundColor: color ]

    static var closeButton: UIBarButtonItem {
        let image = UIImage(systemName: "xmark")
        let button = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        button.tintColor = Theme.color

        return button
    }

    static let color = UIColor.systemBlue

    static let separator = " · "

}
