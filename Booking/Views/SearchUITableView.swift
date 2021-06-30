import UIKit

class SearchUITableView: UITableView {
    private let shared = LocalService.shared
    private var datas: [[SearchHistory]] = []
    var navigationController: UINavigationController!
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .grouped)
        
        backgroundColor = .white
        separatorStyle = .none
        dataSource = self
        delegate = self
    }
    
    override func reloadData() {
        let recommends = shared.getSearchHistorys(type: SearchType.Recommend)
        let historys = shared.getSearchHistorys(type: SearchType.History)

        let lineWidth = frame.width - 50
        var recommendArray: [SearchHistory] = []
        var currentWidth: CGFloat = 0
        var str = ""
        
        for (index, recommend) in recommends.enumerated() {
            CommonUtil.caculateTextWidth(text: recommend.key) { width, _ in
                currentWidth += width
            }
            
            switch index {
            case recommends.count - 1:
                str = "\(str),\(recommend.key)"
            default:
                if currentWidth < lineWidth {
                    str = "\(str),\(recommend.key)"
                    continue
                }
            }

            str.removeFirst()

            let searchHistory = SearchHistory()
            searchHistory.key = str
            searchHistory.type = SearchType.Recommend.rawValue
            recommendArray.append(searchHistory)
            
            str.removeAll()
            str = "\(str),\(recommend.key)"
            currentWidth = 0
        }

        datas.removeAll()
        datas.append(recommendArray)
        datas.append(historys)
        
        tableFooterView = createFooterView()
        
        super.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func showSearchResult(key: String) {
        let uiStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let moreViewController = uiStoryboard.instantiateViewController(withIdentifier: "MoreViewController") as! MoreViewController
        moreViewController.section = .Free
        moreViewController.key = key
        
        LocalService.shared.saveSearchHistory(key: key, type: .History)
        navigationController.pushViewController(moreViewController, animated: true)
    }
    
    private func createFooterView()-> UIView? {
        if datas[1].count != 0 {
            return UIView(frame: .zero)
        }
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 21))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.text = Const.MSG_NO_SEARCH_HISTORY
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 31))
        footerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        return footerView
    }
}

extension SearchUITableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchHistory = datas[indexPath.section][indexPath.row]
        let searchType = SearchType.allCases[indexPath.section]
        let cell = UITableViewCell()
        
        switch searchType {
        case .Recommend:
            cell.contentView.isUserInteractionEnabled = false
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            var currentWith: CGFloat = 10
            for key in searchHistory.key.components(separatedBy: ",") {
                CommonUtil.caculateTextWidth(text: "#\(key)") { width, ajustWidth in
                    let button = UIButton(frame: CGRect(x: currentWith, y: 0, width: width - ajustWidth, height: cell.frame.height - 10))
                    button.setTitle("#\(key)", for: .normal)
                    button.setTitleColor(.gray, for: .disabled)
                    button.setTitleColor(.black, for: .normal)
                    button.setTitleColor(.gray, for: .highlighted)
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                    button.layer.borderWidth = 1
                    button.layer.borderColor = UIColor.systemGray5.cgColor
                    button.addTarget(self, action: #selector(self.handleButton(_:)), for: .touchUpInside)
                    cell.addSubview(button)
                    currentWith += width - ajustWidth + 10
                }
            }
        case .History:
            cell.textLabel?.text = searchHistory.key
            cell.accessoryType = .disclosureIndicator
            cell.addBorder(position: .bottom, color: .systemGray5, width: 1)
        }
        
        return cell
    }
    
    @objc func handleButton(_ sender: UIButton) {
        guard var key = sender.titleLabel?.text else {
            return
        }
        key.removeFirst()
        showSearchResult(key: key)
        reloadData()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let searchType = SearchType.allCases[indexPath.section]
        switch searchType {
        case .History:
            return true
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let searchHistory = datas[indexPath.section][indexPath.row]
        if (editingStyle == .delete) {
            shared.delete(searchHistory: searchHistory)
            reloadData()
        }
    }
}

extension SearchUITableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let searchType = SearchType.allCases[section]
        switch searchType {
        case .Recommend:
            return createSectionHeaderView(text: Const.SECTION_TITLE_RECOMMEND, showAdditional: false)
        case .History:
            return createSectionHeaderView(text: Const.SECTION_TITLE_SEARCH_HISTORY, showAdditional: true)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchType = SearchType.allCases[indexPath.section]

        switch searchType {
        case .Recommend:
            return
        default:
            let data = datas[indexPath.section][indexPath.row]
            showSearchResult(key: data.key)
            reloadData()
        }
    }
    
    private func createSectionHeaderView(text: String, showAdditional: Bool)-> UIView {
        let headerView = SectionHeaderView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 30))
        headerView.configure(text: text, showAdditional: showAdditional, buttonEnable: datas[1].count != 0)
        
        return headerView
    }
}
