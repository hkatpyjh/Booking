import UIKit

protocol SelfConfiguringCell {
    static var reuseIdentifier: String { get }
    func configure<T>(with model: T, _ indexPath: IndexPath)
    func configureButton()
}
