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

        title.text = data.text

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
                createButton(stackView: leftStackView, subMenu: data, index: index)
            default:
                createButton(stackView: rightStackView, subMenu: data, index: index)
            }
        }
        
        if data.submenus.count % 2 != 0 {
            let view = UIView(frame: .zero)
            rightStackView.addArrangedSubview(view)
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: nil))
        }
        
        let ipimage = IPImage(text: data.text, radius: 20, font: nil, textColor: .black, backgroundColor: UIColor(hexaString: data.color))
        icon.image = ipimage.generateImage()
        icon.layer.cornerRadius = icon.frame.width / 2
        icon.backgroundColor = .systemGray5
    }

    private func createButton(stackView: UIStackView, subMenu: SubMenu, index: Int) {
        guard let width = UIApplication.parentViewController()?.view.frame.width else {
            fatalError("Unable get width from parentview")
        }
        
        let button = CommonUtil.createDisclosureButton(width: width / 2, height: 45, title: subMenu.text)
        if index == 0 || index == 1 {
            button.addBorder(position: .top, color: .systemGray5, width: 1)
        }
        button.addBorder(position: .bottom, color: .systemGray5, width: 1)
        button.addBorder(position: .right, color: .systemGray5, width: 1)
        button.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(button)
    }
    
    @objc func handleButton(_ sender: UIButton) {
        let uiStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let moreViewController = uiStoryboard.instantiateViewController(withIdentifier: "MoreViewController") as! MoreViewController
        moreViewController.section = .Free
        moreViewController.key = sender.titleLabel?.text
        
        UIApplication.parentViewController()?.navigationController?.pushViewController(moreViewController, animated: true)
    }
}
