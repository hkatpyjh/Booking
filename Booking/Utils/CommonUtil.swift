import UIKit

struct CommonUtil {
    static func caculateTextWidth(text:String, size: CGFloat = 12, spacing: CGFloat = 50, completionblock: @escaping (CGFloat, CGFloat)->()) {
        let font = UIFont.systemFont(ofSize: size)
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: fontAttributes)
        completionblock(size.width + spacing, spacing / 2)
    }
    
    static func createEmptyView(frame: CGRect)-> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 80))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.text = Const.MSG_NO_DATA_FIND
        
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        emptyView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor)
        ])
        
        return emptyView
    }
    
    static func createDisclosureButton(width: CGFloat, height: CGFloat, title: String)-> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: height))
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        button.setTitleColor(.black, for: .normal)
        button.setTitle(title, for: .normal)
        button.setBackgroundColor(.white, forState: .normal)
        button.setBackgroundColor(.systemGray3, forState: .highlighted)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0);
        
        let disclosure = UITableViewCell()
        disclosure.frame = CGRect(x: 0, y: 0, width: width - 10, height: height)
        disclosure.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal))
        disclosure.isUserInteractionEnabled = false
        button.addSubview(disclosure)
        
        return button
    }
}
