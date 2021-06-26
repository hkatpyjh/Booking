import UIKit
import Combine
import ObjectMapper
import ProgressHUD

class MoreViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var cancellableSet: Set<AnyCancellable> = []
    private var sectionResult: SectionResult!
    private var isPaginating: Bool = false
    var section: BookSection!
    var key: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ProgressHUD.show(interaction: false)
        WebService.shared.createMorePublisher(with: section, key: key)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { status in
                self.configure()
                ProgressHUD.dismiss()
            }) { result in
                self.sectionResult = Mapper<SectionResult>().map(JSONString: result.rawString()!)!
            }.store(in: &self.cancellableSet)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.separatorStyle = .none
    }
    
    func configure() {
        tableView.register(MoreCell.self, forCellReuseIdentifier: MoreCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = createFooterView()
        tableView.separatorStyle = .singleLine
        tableView.reloadData()
    }
    
    private func createFooterView()-> UIView? {
        if Int.parse(from: sectionResult.total) != 0 {
            return UIView(frame: .zero)
        }
        
        let footerView = CommonUtil.createEmptyView(frame: tableView.frame)
        return footerView
    }
}

extension MoreViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionResult.books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoreCell.reuseIdentifier, for: indexPath) as? MoreCell else {
            fatalError("Unable to dequeue cell")
        }
        
        let book = sectionResult.books[indexPath.row]
        cell.configure(with: book, indexPath)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = sectionResult.books[indexPath.row]
        let detailViewController = storyboard?.instantiateViewController(withIdentifier: "BookDetailViewController") as! BookDetailViewController

        ProgressHUD.show(interaction: false)
        WebService.shared.createPublisher(.book(isbn: book.isbn13))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { status in
                ProgressHUD.dismiss()
                self.navigationController?.pushViewController(detailViewController, animated: true)
            }) { result in
                detailViewController.book = Mapper<Book>().map(JSONString: result.rawString()!)!
            }.store(in: &self.cancellableSet)
    }
}

extension MoreViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        
        if position > tableView.contentSize.height + 30 - scrollView.frame.height {
            guard !isPaginating else {
                return
            }
            
            isPaginating = true
            
            if sectionResult.hasMore {
                tableView.tableFooterView = createSpinnerFooter()
                WebService.shared.createMorePublisher(with: section, key: key, page: sectionResult.nextpage)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { status in
                        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {_ in
                            self.configure()
                            self.tableView.tableFooterView = nil
                            self.isPaginating = false
                        })
                    }) { result in
                        let tmp = Mapper<SectionResult>().map(JSONString: result.rawString()!)!
                        self.sectionResult.append(result: tmp)
                    }.store(in: &self.cancellableSet)
            } else {
                tableView.tableFooterView = self.createNoDataFooter()
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: {_ in
                    self.tableView.tableFooterView = UIView(frame: .zero)
                    self.tableView.reloadData()
                    self.isPaginating = false
                })
            }
        }
    }
    
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        return footerView
    }
    
    private func createNoDataFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        label.textAlignment = .center
        label.text = Const.MSG_NO_MORE_DATA
        label.textColor = .secondaryLabel
        footerView.addSubview(label)
        
        return footerView
    }
}
