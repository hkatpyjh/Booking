import UIKit
import Combine
import ObjectMapper
import SwiftyJSON
import ProgressHUD

class FavoriteViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var cancellableSet: Set<AnyCancellable> = []
    private var sectionDict: [BookSection: [LocalBook]] = [:]
    private lazy var dataSource = { configureDataSource() }()
    private lazy var emptyView = { CommonUtil.createEmptyView(frame: view.frame) }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sectionDict[.Category] = Array(LocalService.shared.localBooks)
        
        var snapshot = NSDiffableDataSourceSnapshot<BookSection, LocalBook>()
        snapshot.appendSections([.Category])
        for (section, result) in sectionDict {
            snapshot.appendItems(result, toSection: section)
        }
        dataSource.apply(snapshot)
        
        configureEmptyView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dataSource.replaceItems([], in: .Category)
    }
    
    private func configureEmptyView() {
        if sectionDict[.Category]?.count == 0 {
            collectionView.isHidden = true
            view.addSubview(emptyView)
        } else {
            collectionView.isHidden = false
            emptyView.removeFromSuperview()
        }
    }
}

extension FavoriteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!
        // #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        cell.contentView.backgroundColor = #colorLiteral(red: 0.7019608021, green: 0.8431372643, blue: 1, alpha: 1)
        
        let selectedBook = sectionDict[.Category]![indexPath.row]
        let detailViewController = storyboard?.instantiateViewController(withIdentifier: "BookDetailViewController") as! BookDetailViewController
        
        ProgressHUD.show(interaction: false)
        WebService.shared.createPublisher(.book(isbn: selectedBook.isbn13))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { status in
                ProgressHUD.dismiss()
                cell.contentView.backgroundColor = .clear
                self.navigationController?.pushViewController(detailViewController, animated: true)
            }) { result in
                detailViewController.book = Mapper<Book>().map(JSONString: result.rawString()!)!
            }.store(in: &self.cancellableSet)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = .clear
        }
    }
}

extension FavoriteViewController {
    func configureLayout() {
        collectionView.collectionViewLayout = self.createCompositionalLayout()
        collectionView.delegate = self
    }
        
    func configureDataSource() -> UICollectionViewDiffableDataSource<BookSection, LocalBook> {
        let cellRegistration = UICollectionView.CellRegistration<FavoriteCell, LocalBook> { cell, indexPath, localBook in
            cell.configure(with: localBook, indexPath)
        }
        
        let dataSource = UICollectionViewDiffableDataSource<BookSection, LocalBook>(collectionView: collectionView) { collectionView, indexPath, localBook in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: localBook)
            return cell
        }
        
        return dataSource
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)

        config.trailingSwipeActionsConfigurationProvider = { indexPath in
            guard let localBook = self.dataSource.itemIdentifier(for: indexPath) else {return nil}
            return UISwipeActionsConfiguration(
                actions: [UIContextualAction(
                    style: .destructive,
                    title: Const.DELETE,
                    handler: { [weak self] _, _, completion in
                        guard let self = self else {return}
                        self.sectionDict[.Category]?.remove(at: indexPath.row)
                        self.dataSource.replaceItems(self.sectionDict[.Category]!, in: .Category)
                        self.configureEmptyView()
                        LocalService.shared.delete(isbn: localBook.isbn13)
                        completion(true)
                    }
                )]
            )
        }

        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        return layout
    }
}
