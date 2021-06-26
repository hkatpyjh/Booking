import UIKit

class SettingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let setting: Setting = SettingService.shared.setting
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func configure() {
        tableView.register(ProfileCell.self, forCellReuseIdentifier: ProfileCell.reuseIdentifier)
        tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = SettingSection.allCases[section]
        
        switch section {
        case .User:
            return 0
        default:
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = SettingSection.allCases[indexPath.section]
        let settingOption = setting.settingOptions.filter{ $0.section == section }[indexPath.row]
        
        if settingOption.cellType == .SwitchCell {
            return
        }
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "SettingDetailViewController") as! SettingDetailViewController
        controller.settingOption = settingOption
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = SettingSection.allCases[section]
        
        return setting.settingOptions.filter{ $0.section == section }.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = SettingSection.allCases[indexPath.section]
        let settingOption = setting.settingOptions.filter{ $0.section == section }[indexPath.row]
        
        switch section {
        case .User:
            return self.configure(ProfileCell.self, with: settingOption, for: indexPath)
        default:
            return self.configure(SettingCell.self, with: settingOption, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .systemGray6
    }
    
    private func configure<T: SelfConfiguringCell>(_ cellType: T.Type, with setting: SettingOption, for indexPath: IndexPath) -> T {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(cellType)")
        }
        
        cell.configure(with: setting, indexPath)
        
        return cell
    }
}
