import UIKit

protocol SelfConfiguringHeader {
    static var reuseIdentifier: String { get }
    func configure(with section: BookSection)
}
