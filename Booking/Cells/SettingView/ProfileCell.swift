import UIKit

class ProfileCell: UITableViewCell, SelfConfiguringCell {
    static var reuseIdentifier: String = "profile-cell"
    
    var settingOption: SettingOption!
    
    let icon: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = view.frame.width / 2
        return view
    }()
    
    let user: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let email: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(icon)
        addSubview(user)
        addSubview(email)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 80),
            
            icon.heightAnchor.constraint(equalToConstant: icon.frame.height),
            icon.widthAnchor.constraint(equalToConstant: icon.frame.width),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            
            user.centerYAnchor.constraint(equalTo: icon.centerYAnchor, constant: -10),
            user.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20),
            email.centerYAnchor.constraint(equalTo: icon.centerYAnchor, constant: 10),
            email.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20)
        ])
        
        accessoryType = .disclosureIndicator
    }
    
    func configure<T>(with model: T, _ indexPath: IndexPath) {
        self.settingOption = model as? SettingOption
        user.text = settingOption.datas[0]
        email.text = settingOption.datas[1]
        icon.image = SettingService.shared.getImage(name: Const.PROFILE_IMG)
    }
    
    func configureButton() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
