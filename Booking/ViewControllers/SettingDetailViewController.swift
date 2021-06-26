import UIKit
import ProgressHUD
import Toast

class SettingDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var settingOption: SettingOption!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SettingService.shared.update(settingOption: settingOption)
        SettingService.shared.save()
    }
    
    func configure() {
        tableView.register(ProfileCell.self, forCellReuseIdentifier: ProfileCell.reuseIdentifier)
        tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = createHeaderView()
        tableView.tableFooterView = UIView(frame: .zero)
        
        switch settingOption.settingType {
        case .Category:
            addButton.isEnabled = true
        default:
            addButton.tintColor = .clear
        }
    }
    
    private func createHeaderView()-> UIView? {
        switch settingOption.settingType {
        case .Profile:
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.backgroundColor = .systemGray3
            imageView.layer.cornerRadius = imageView.frame.width / 2
            imageView.image = SettingService.shared.getImage(name: Const.PROFILE_IMG)
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewTouch)))
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
            headerView.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.heightAnchor.constraint(equalToConstant: imageView.frame.height),
                imageView.widthAnchor.constraint(equalToConstant: imageView.frame.width),
                imageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
            ])
            return headerView
        default:
            return nil
        }
    }
    
    @objc func imageViewTouch() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            pickerController.allowsEditing = true
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func handleAdd(_ sender: Any) {
        AlertUtil.showAlertWithTextField(msg: Const.MSG_ADD_CATEGORY) { category in
            if category.isEmpty {
                self.view.makeToast(Const.MSG_INPUT_NOT_EMPTY, duration: 3.0, position: .top)
                return
            }
            
            if self.settingOption.preset.contains(where: { $0.caseInsensitiveCompare(category) == .orderedSame }) {
                return
            }
            self.settingOption.preset.append(category)
            self.tableView.reloadData()
        }
    }
}

extension SettingDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] != nil {
            guard let image = info[.originalImage] as? UIImage else { return }
            guard let fileURL = info[.imageURL] as? URL else { return }
            
            SettingService.shared.saveImage(img: image, tmpFile: fileURL, name: Const.PROFILE_IMG) {
                self.settingOption.args[0] = Const.PROFILE_IMG
                self.tableView.tableHeaderView = self.createHeaderView()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SettingDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        
        switch settingOption.settingType {
        case .Category:
            changeCategory(cell, indexPath)
        case .Indicator:
            changeIndicator(cell, indexPath)
        default:
            return
        }
    }
    
    private func changeCategory(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        let data = settingOption.preset[indexPath.row]
        
        if settingOption.datas.contains(data) {
            cell.accessoryType = .none
            settingOption.datas.removeAll(where: { $0 == data })
        } else {
            cell.accessoryType = .checkmark
            settingOption.datas.append(data)
        }
    }
    
    private func changeIndicator(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        let indicator = IndicatorType.allCases[indexPath.row]
        settingOption.datas.removeAll();
        settingOption.datas.append(indicator.rawValue)
        ProgressHUD.animationType = indicator.type
        ProgressHUD.show(interaction: false)
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {_ in
            ProgressHUD.dismiss()
            self.tableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch settingOption.settingType {
        case .Category:
            return true
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let data = settingOption.preset[indexPath.row]
        if (editingStyle == .delete) {
            settingOption.preset.removeAll(where: { $0.caseInsensitiveCompare(data) == .orderedSame })
            settingOption.datas.removeAll(where: { $0.caseInsensitiveCompare(data) == .orderedSame })
            tableView.reloadData()
        }
    }
}

extension SettingDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch settingOption.settingType {
        case .Profile:
            return settingOption.datas.count
        case .Indicator:
            return IndicatorType.allCases.count
        case .Category:
            return settingOption.preset.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setting-detail-cell", for: indexPath)
        
        configureCell(cell, indexPath)
        
        return cell
    }
    
    private func configureCell(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        switch settingOption.settingType {
        case .Profile:
            configureProfileCell(cell, indexPath)
        case .Indicator:
            configureIndicatorCell(cell, indexPath)
        case .Category:
            configureCategoryCell(cell, indexPath)
        default:
            return
        }
    }
    
    private func configureProfileCell(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        let data = settingOption.datas[indexPath.row]
        let textField = UITextField(frame: CGRect(x: 10, y: 0, width: cell.frame.width, height: cell.frame.height))
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.text = data
        textField.tag = indexPath.row
        textField.addTarget(self, action: #selector(valueChange(_:)), for: .editingChanged)
        cell.addSubview(textField)
    }
    
    @objc func valueChange(_ sender: UITextField) {
        switch sender.tag {
        case 0:
            settingOption.datas[0] = sender.text!
        default:
            settingOption.datas[1] = sender.text!
        }
    }
    
    private func configureIndicatorCell(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        let indicator = IndicatorType.allCases[indexPath.row]
        cell.textLabel?.text = indicator.rawValue
        
        if indicator == IndicatorType.init(rawValue: settingOption.datas[0]){
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
    
    private func configureCategoryCell(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        let data = settingOption.preset[indexPath.row]
        cell.textLabel?.text = data
        
        if settingOption.datas.contains(data) {
            cell.accessoryType = .checkmark
        }
    }
}
