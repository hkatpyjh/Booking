import UIKit

class CollasableCell: UITableViewCell, SelfConfiguringCell {
    static var reuseIdentifier: String = "collasable-cell"
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var leftStackView: UIStackView!
    @IBOutlet weak var rightStackView: UIStackView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var accessory: UIImageView!
    
    var data: MainMenu!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leftStackView.arrangedSubviews.forEach({ view in
            view.removeFromSuperview()
        })
        
        rightStackView.arrangedSubviews.forEach({ view in
            view.removeFromSuperview()
        })
    }
    
    func configure<T>(with model: T, _ indexPath: IndexPath) {
        self.data = model as? MainMenu

        title.text = data.menu

        stackView.arrangedSubviews[1].isHidden = !data.expanded
        
        let chevron = UIImage(systemName: "chevron.up")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        accessory.image = chevron
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.data.expanded {
                self.accessory.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            } else {
                self.accessory.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 180)
            }
        })
        
        configureButton()
        
        layoutIfNeeded()
    }
    
    func configureButton() {
        for (index, data) in data.submenus.enumerated() {
            switch index % 2 {
            case 0:
                createButton(stackView: leftStackView, data: data)
            default:
                createButton(stackView: rightStackView, data: data)
            }
        }
        
        if data.submenus.count % 2 != 0 {
            let view = UIView(frame: .zero)
            rightStackView.addArrangedSubview(view)
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: nil))
        }
        
        let ipimage = IPImage(text: data.menu, radius: 20, font: nil, textColor: .black, backgroundColor: UIColor(hexaString: data.color))
        icon.image = ipimage.generateImage()
        icon.layer.cornerRadius = icon.frame.width / 2
        icon.backgroundColor = .systemGray5
    }

    private func createButton(stackView: UIStackView, data: SubMenu) {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: stackView.frame.width, height: 45))
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        button.setTitleColor(.black, for: .normal)
        button.setTitle(data.submenu, for: .normal)
        button.setBackgroundColor(.white, forState: .normal)
        button.setBackgroundColor(.systemGray3, forState: .highlighted)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0);
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(button)
        
        let disclosure = UITableViewCell()
        disclosure.frame = CGRect(x: 0, y: 0, width: stackView.frame.width - 10, height: 45)
        disclosure.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal))
        disclosure.isUserInteractionEnabled = false
        button.addSubview(disclosure)
    }
    
    @objc func handleButton(_ sender: UIButton) {
        let uiStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let moreViewController = uiStoryboard.instantiateViewController(withIdentifier: "MoreViewController") as! MoreViewController
        moreViewController.section = .Free
        moreViewController.key = sender.titleLabel?.text
        
        UIApplication.parentViewController()?.navigationController?.pushViewController(moreViewController, animated: true)
    }
}
