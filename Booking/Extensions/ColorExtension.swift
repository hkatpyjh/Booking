import UIKit

extension UIColor {
    convenience init(hexaString: String, alpha: CGFloat = 0.5) {
        let chars = Array(hexaString.dropFirst())
        self.init(red: .init(strtoul(String(chars[0...1]),nil,16))/255,
                  green: .init(strtoul(String(chars[2...3]),nil,16))/255,
                  blue: .init(strtoul(String(chars[4...5]),nil,16))/255,
                  alpha: alpha)}
    
    var hexString: String {
        cgColor.components![0..<3]
            .map { String(format: "%02lX", Int($0 * 255)) }
            .reduce("#", +)
    }
}
