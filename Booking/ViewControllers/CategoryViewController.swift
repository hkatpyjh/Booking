import UIKit

class CategoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private lazy var searchController = { createSearchController() }()
    private lazy var searchTableView = { createTableView() }()
    
    var menuDict: [MenuType: [MainMenu]] = [:]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.definesPresentationContext = true
        self.setSafeAreaColor(color: .white)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        menuDict[.Collasable] = LocalService.shared.getMenus(menuType: .Collasable)
        menuDict[.Twocolumn] = LocalService.shared.getMenus(menuType: .Twocolumn)
        
        tableView.reloadData()
        tableView.tableFooterView = UIView(frame: .zero)
        searchTableView.reloadData()

        navigationItem.titleView = searchController.searchBar
        navigationController?.navigationBar.standardAppearance.shadowColor = .clear
    }
}

extension CategoryViewController: UISearchBarDelegate, UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        tableView.isHidden = true
        searchTableView.reloadData()
        view.addSubview(searchTableView)
        searchController.searchBar.placeholder = Const.MSG_SEARCH_PLACEHOLDER
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        tableView.isHidden = false
        searchTableView.removeFromSuperview()
        searchController.searchBar.placeholder = Const.MSG_DEFAULT_SEARCH_PLACEHOLDER
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        
        let moreViewController = storyboard?.instantiateViewController(withIdentifier: "MoreViewController") as! MoreViewController
        moreViewController.section = .Free
        moreViewController.key = text
        
        LocalService.shared.saveSearchHistory(key: text, type: .History)
        navigationController?.pushViewController(moreViewController, animated: true)
    }
    
    private func createTableView()-> SearchUITableView {
        let tableView = SearchUITableView(frame: view.frame)
        tableView.navigationController = navigationController
        return tableView
    }
    
    private func createSearchController()-> UISearchController {
        let searchController = UISearchController()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.delegate = self
        
        return searchController
    }
}

extension CategoryViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuType = MenuType.allCases[indexPath.section]
        let menu = menuDict[menuType]![indexPath.row]
        
        switch menuType {
        case .Collasable:
            let isExpanded = menu.expanded
            try! LocalService.shared.realm.write({
                menu.expanded = !isExpanded
            })
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        default:
            print("aa")
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SectionHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let menuType = MenuType.allCases[section]
        
        switch menuType {
        case .Collasable:
            headerView.configure(text: Const.SECTION_TITLE_CATEGORY, showAdditional: false, buttonEnable: false)
        case .Twocolumn:
            headerView.configure(text: Const.SECTION_TITLE_OTHERS, showAdditional: false, buttonEnable: false)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

extension CategoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuDict.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let menuType = MenuType.allCases[section]
        return menuDict[menuType]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuType = MenuType.allCases[indexPath.section]
        let menu = menuDict[menuType]![indexPath.row]
        
        switch menuType {
        case .Collasable:
            return self.configure(CollasableCell.self, with: menu, for: indexPath)
        case .Twocolumn:
            return self.configure(TwoColumnCell.self, with: menu, for: indexPath)
        }
    }
    
    private func configure<T: SelfConfiguringCell>(_ cellType: T.Type, with menu: MainMenu, for indexPath: IndexPath) -> T {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(cellType)")
        }
        
        cell.configure(with: menu, indexPath)
        
        return cell
    }
}
