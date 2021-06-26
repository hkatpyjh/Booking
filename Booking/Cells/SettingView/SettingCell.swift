import UIKit

class SettingCell: UITableViewCell, SelfConfiguringCell {
    static var reuseIdentifier: String = "setting-cell"
    
    var settingOption: SettingOption!
    
    let icon: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let fieldText: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let cellSwitch: UISwitch = {
        let cellSwitch = UISwitch()
        cellSwitch.translatesAutoresizingMaskIntoConstraints = false
        return cellSwitch
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        cellSwitch.addTarget(self, action: #selector(handleSwitch(_:)), for: .valueChanged)
        addSubview(icon)
        addSubview(fieldText)
        addSubview(cellSwitch)
        
        NSLayoutConstraint.activate([            
            icon.heightAnchor.constraint(equalToConstant: icon.frame.height),
            icon.widthAnchor.constraint(equalToConstant: icon.frame.width),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            
            cellSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            cellSwitch.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            
            fieldText.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
            fieldText.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20),
            fieldText.rightAnchor.constraint(equalTo: cellSwitch.leftAnchor, constant: -10)
        ])
    }
    
    func configure<T>(with model: T, _ indexPath: IndexPath) {
        self.settingOption = model as? SettingOption
        fieldText.text = settingOption.args[0]
        icon.image = UIImage(systemName: settingOption.args[1])
        
        configureButton()
    }
    
    func configureButton() {
        switch settingOption.cellType {
        case .StaticCell:
            accessoryType = .disclosureIndicator
            cellSwitch.isHidden = true
        case .SwitchCell:
            contentView.isUserInteractionEnabled = false
            cellSwitch.isOn = settingOption.isOn
            cellSwitch.isHidden = false
            selectionStyle = .none
        }
    }
    
    @objc func handleSwitch(_ sender: UIEvent) {
        settingOption.isOn = cellSwitch.isOn
        SettingService.shared.update(settingOption: settingOption)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
