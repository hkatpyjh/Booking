import UIKit

class TwoColumnCell: UITableViewCell, SelfConfiguringCell {
    static var reuseIdentifier: String = "twocolumn-cell"
    
    @IBOutlet weak var leftStackView: UIStackView!
    @IBOutlet weak var rightStackView: UIStackView!
    
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
    }

    private func createButton(stackView: UIStackView, subMenu: SubMenu, index: Int) {
        let button = CommonUtil.createDisclosureButton(width: stackView.frame.width, height: 45, title: subMenu.text)
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

