import UIKit

class SectionHeaderView: UIView {

    private let title: UILabel = {
        let title = UILabel(frame: .zero)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 18, weight: .bold))
        return title
    }()
    
    private let button: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Const.CLEAR, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        return button
    }()
    
    private let border: UIView = {
        let border = UIView(frame: .zero)
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .systemGray5
        return border
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        button.addTarget(self, action: #selector(handleClear(_:)), for: .touchUpInside)
        
        addSubview(title)
        addSubview(button)
        addSubview(border)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: frame.height),
            
            button.topAnchor.constraint(equalTo: topAnchor),
            button.heightAnchor.constraint(equalTo: heightAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            title.topAnchor.constraint(equalTo: topAnchor),
            title.heightAnchor.constraint(equalTo: heightAnchor),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            title.trailingAnchor.constraint(equalTo: button.leadingAnchor),
            
            border.heightAnchor.constraint(equalToConstant: 1),
            border.widthAnchor.constraint(equalTo: widthAnchor),
            border.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(text: String, showAdditional: Bool, buttonEnable: Bool) {
        title.text = text
        button.isEnabled = buttonEnable
        button.isHidden = !showAdditional
        border.isHidden = !showAdditional
    }
    
    @objc func handleClear(_ sender: UIButton) {
        LocalService.shared.clearSearchHistory()
        sender.isEnabled = false
        
        guard let tableView = superview as? SearchUITableView else {
            return
        }
        tableView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
