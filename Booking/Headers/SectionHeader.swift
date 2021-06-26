import UIKit

class SectionHeader: UICollectionReusableView, SelfConfiguringHeader {
    static let reuseIdentifier = "section-header-reuse-id"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 18, weight: .bold))
        return label
    }()
    
    let moreButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.systemGray, for: .highlighted)
        button.setTitle(Const.MORE, for: .normal)
        return button
    }()
    
    let separator: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternaryLabel
        return view
    }()
    
    private var section: BookSection!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let horizonStackView = UIStackView(arrangedSubviews: [titleLabel, moreButton])
        horizonStackView.translatesAutoresizingMaskIntoConstraints = false
        horizonStackView.axis = .horizontal
        
        let verticalStackView = UIStackView(arrangedSubviews: [separator, horizonStackView])
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalStackView.topAnchor.constraint(equalTo: topAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10)
        ])
    }
    
    func configure(with section: BookSection) {
        self.section = section
        
        if section == .Latest {
            separator.isHidden = true
        }
        
        titleLabel.text = section.rawValue
        
        moreButton.addTarget(self, action: #selector(moreAction(_:forEvent:)), for: .touchUpInside)
    }
    
    @objc func moreAction(_ sender: UIButton, forEvent event: UIEvent) {
        let uiStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let moreViewController = uiStoryboard.instantiateViewController(withIdentifier: "MoreViewController") as! MoreViewController
        moreViewController.section = section
        
        UIApplication.parentViewController()?.navigationController?.pushViewController(moreViewController, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
