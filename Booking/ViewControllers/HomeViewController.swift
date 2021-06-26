import UIKit
import Combine
import ObjectMapper
import ProgressHUD

class HomeViewController: UIViewController, UICollectionViewDelegate, ActionCallback  {
    @IBOutlet weak var collectionView: UICollectionView!
    private lazy var searchController = { createSearchController() }()
    private lazy var tableView = { createTableView() }()
    
    private var cancellableSet: Set<AnyCancellable> = []
    private lazy var dataSource = { configureDataSource() }()
    private var sectionDict: [BookSection: SectionResult] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()

        ProgressHUD.show(interaction: false)
        WebService.shared.createSectionPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { status in
                self.configureData()
                ProgressHUD.dismiss()
            }) { (latest, category, random) in
                self.sectionDict[.Latest] = Mapper<SectionResult>().map(JSONString: latest.rawString()!)!
                self.sectionDict[.Category] = Mapper<SectionResult>().map(JSONString: category.rawString()!)!
                self.sectionDict[.Random] = Mapper<SectionResult>().map(JSONString: random.rawString()!)!
            }.store(in: &self.cancellableSet)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        tableView.reloadData()
        navigationItem.titleView = searchController.searchBar
        navigationItem.titleView?.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance.shadowColor = .clear
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBook = sectionDict[BookSection.allCases[indexPath.section]]!.books[indexPath.row]
        let detailViewController = storyboard?.instantiateViewController(withIdentifier: "BookDetailViewController") as! BookDetailViewController
        
        ProgressHUD.show(interaction: false)
        WebService.shared.createPublisher(.book(isbn: selectedBook.isbn13))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { status in
                ProgressHUD.dismiss()
                self.navigationController?.pushViewController(detailViewController, animated: true)
            }) { result in
                detailViewController.book = Mapper<Book>().map(JSONString: result.rawString()!)!
            }.store(in: &self.cancellableSet)
    }
    
    func callback<V>(v: V) {
        ProgressHUD.show(interaction: false)
        WebService.shared.createPublisher(.book(key: v as! String))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { status in
                self.dataSource.replaceItems(self.sectionDict[.Category]!.books, in: .Category)
            }) { result in
                let sectionResult = Mapper<SectionResult>().map(JSONString: result.rawString()!)!
                if Int.parse(from: sectionResult.total) == 0 {
                    ProgressHUD.showFailed(Const.MSG_UNABLE_FETCH_DATA, interaction: false)
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {_ in
                        ProgressHUD.dismiss()
                    })
                    return
                }
                self.sectionDict[.Category] = sectionResult
                ProgressHUD.dismiss()
            }.store(in: &self.cancellableSet)
    }
}

extension HomeViewController: UISearchBarDelegate, UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        collectionView.isHidden = true
        tableView.reloadData()
        view.addSubview(tableView)
        searchController.searchBar.placeholder = Const.MSG_SEARCH_PLACEHOLDER
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        collectionView.isHidden = false
        tableView.removeFromSuperview()
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

extension HomeViewController {
    func configureLayout() {
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseIdentifier)
        collectionView.register(SegmentalSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SegmentalSectionHeader.reuseIdentifier)
        collectionView.register(UINib(nibName: "LatestCell", bundle: nil), forCellWithReuseIdentifier: LatestCell.reuseIdentifier)
        collectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        collectionView.register(RandomCell.self, forCellWithReuseIdentifier: RandomCell.reuseIdentifier)
        
        collectionView.collectionViewLayout = self.createCompositionalLayout()
        collectionView.delegate = self
        
        self.setSafeAreaColor(color: .white)
        self.definesPresentationContext = true
    }
    
    private func configure<T: SelfConfiguringCell>(_ cellType: T.Type, with book: Book, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(cellType)")
        }
        
        cell.configure(with: book, indexPath)
        
        return cell
    }
    
    private func configure<T: SelfConfiguringHeader>(_ headerType: T.Type, _ kind: String, with section: BookSection, for indexPath: IndexPath) -> T {
        guard  let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(headerType)")
        }
        
        header.configure(with: section)
        
        return header
    }
    
    func configureDataSource() -> UICollectionViewDiffableDataSource<BookSection, Book> {
        let dataSource = UICollectionViewDiffableDataSource<BookSection, Book>(collectionView: collectionView) { collectionView, indexPath, book in
            switch BookSection.allCases[indexPath.section] {
            case .Latest:
                return self.configure(LatestCell.self, with: book, for: indexPath)
            case .Category:
                return self.configure(CategoryCell.self, with: book, for: indexPath)
            case .Random:
                return self.configure(RandomCell.self, with: book, for: indexPath)
            case .Free:
                return nil
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let first = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
            guard let section = self.dataSource.snapshot().sectionIdentifier(containingItem: first) else { return nil }
            
            switch section {
            case .Latest, .Random:
                return self.configure(SectionHeader.self, kind, with: section, for: indexPath)
            case .Category:
                return self.configure(SegmentalSectionHeader.self, kind, with: section, for: indexPath)
            case .Free:
                return nil
            }
        }
        
        return dataSource
    }
    
    func configureData() {
        var snapshot = NSDiffableDataSourceSnapshot<BookSection, Book>()
        snapshot.appendSections(BookSection.allCases)
        for (section, result) in sectionDict {
            snapshot.appendItems(result.books, toSection: section)
        }
        dataSource.apply(snapshot)
    }
}

extension HomeViewController {
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let section = BookSection.allCases[sectionIndex]
            switch section {
            case .Latest:
                return self.createLatestSection()
            case .Category:
                return self.createCategorySection()
            case .Random:
                return self.createRandomSection()
            case .Free:
                return nil
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        return layout
    }
    
    func createLatestSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 10)
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.28))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        
        layoutSection.boundarySupplementaryItems = [createSectionHeader()]
        return layoutSection
    }
    
    func createCategorySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
        
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 0)
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.6))
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        
        let layoutSectionHeader = createSectionHeader()
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        
        return layoutSection
    }
    
    func createRandomSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(130))
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        let layoutSectionHeader = createSectionHeader()
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        
        return layoutSection
    }
    
    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .estimated(10))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        return layoutSectionHeader
    }
}
