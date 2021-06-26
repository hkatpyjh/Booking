import UIKit

class SegmentalSectionHeader: UICollectionReusableView, SelfConfiguringHeader {
    static let reuseIdentifier = "segmental-section-header-reuse-id"
    
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
    
    let segment = ScrollableSegmentedControl()

    private var section: BookSection!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let horizonStackView = UIStackView(arrangedSubviews: [titleLabel, moreButton])
        horizonStackView.translatesAutoresizingMaskIntoConstraints = false
        horizonStackView.axis = .horizontal
        
        segment.segmentStyle = .textOnly
        segment.underlineSelected = true
        segment.backgroundColor = .systemGray6
        segment.translatesAutoresizingMaskIntoConstraints = false

        let topStackView = UIStackView(arrangedSubviews: [separator, horizonStackView])
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.axis = .vertical
        
        addSubview(topStackView)
        addSubview(segment)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 60),
            
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            topStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topStackView.topAnchor.constraint(equalTo: topAnchor),
            
            segment.topAnchor.constraint(equalTo: topStackView.bottomAnchor),
            segment.leadingAnchor.constraint(equalTo: leadingAnchor),
            segment.trailingAnchor.constraint(equalTo: trailingAnchor),
            segment.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with section: BookSection) {
        self.section = section
        
        titleLabel.text = section.rawValue
        
        let settingOption = SettingService.shared.find(settingType: .Category)
        segment.removeAll()
        for i in 0..<settingOption.datas.count {
            segment.insertSegment(withTitle: settingOption.datas[i], at: i)
        }
        segment.selectedSegmentIndex = SettingService.shared.setting.categoryIndex
        
        segment.addTarget(self, action: #selector(self.segmentAction(_:)), for: .valueChanged)
        moreButton.addTarget(self, action: #selector(moreAction(_:)), for: .touchUpInside)
    }
    
    @objc func moreAction(_ sender: UIButton) {
        let uiStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let moreViewController = uiStoryboard.instantiateViewController(withIdentifier: "MoreViewController") as! MoreViewController
        moreViewController.section = section
        
        UIApplication.parentViewController()?.navigationController?.pushViewController(moreViewController, animated: true)
    }
    
    @objc func segmentAction(_ sender: ScrollableSegmentedControl) {
        let categoryName = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        SettingService.shared.setting.categoryIndex = sender.selectedSegmentIndex
        SettingService.shared.setting.categoryName = categoryName
        
        let viewController = UIApplication.parentViewController() as! HomeViewController
        viewController.callback(v: categoryName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}


