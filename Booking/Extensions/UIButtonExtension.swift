import UIKit

extension UIButton {
    func setBackgroundColor(_ color: UIColor, forState controlState: UIControl.State) {
        let colorImage = UIGraphicsImageRenderer(size: CGSize(width: frame.width, height: frame.height)).image { _ in
            color.setFill()
            UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height)).fill()
        }
        setBackgroundImage(colorImage, for: controlState)
    }
}
