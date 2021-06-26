import UIKit
import Combine
import ObjectMapper
import Kingfisher
import WebKit
import QuickLook
import ProgressHUD

class BookDetailViewController: UIViewController {
    
    @IBOutlet weak var bookingButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var langLabel: UILabel!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var previewButton: UIButton!
    
    private var cancellableSet: Set<AnyCancellable> = []
    private lazy var webView: WKWebView = { self.configureWebView() }()
    private lazy var previewController: QLPreviewController = { self.configurePreviewController() }()
    private var previewURL: URL?
    var book: Book!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureButton()
    }
    
    @IBAction func bookingAction(_ sender: UIBarButtonItem) {
        if LocalService.shared.exists(isbn: book.isbn13) {
            AlertUtil.showAlert(msg: Const.MSG_DEL_CONFIRM) { (ok) in
                LocalService.shared.delete(isbn: self.book.isbn13)
                self.configureButton()
            }
            return
        }
        
        AlertUtil.showAlert(msg: Const.MSG_ADD_CONFIRM) { (ok) in
            LocalService.shared.save(book: self.book)
            self.configureButton()
        }
    }
    
    @IBAction func previewButton(_ sender: Any) {
        WebService.shared.fileExists(title: book.title) { result, docURL in
            if result! {
                self.previewURL = docURL
                self.preview()
            } else {
                ProgressHUD.show("Downloading", interaction: false)
                let request = URLRequest(url: URL(string: self.book.url)!)
                self.webView.load(request)
            }
        }
    }
    
    func configure() {
        titleLabel.text = book.title
        subtitleLabel.text = book.subtitle
        authorLabel.text = book.authors
        langLabel.text = "Language: \(book.language!)"
        pageLabel.text = "Pages: \(book.pages!)"
        yearLabel.text = "Year: \(book.year!)"
        publisherLabel.text = "Publisher: \(book.publisher!)"
        ratingLabel.text = "Rating: \(book.rating!)"
        textView.text = book.desc
        imageView.kf.setImage(with: URL(string: book.image))
        
        if Int.parse(from: book.price)! <= 0 {
            priceLabel.text = "Free"
            priceLabel.textColor = .systemGreen
        } else {
            priceLabel.text = "Price: \(book.price!)"
            priceLabel.textColor = .label
            previewButton.isEnabled = false
        }
        
        configureButton()
    }
    
    func configureButton() {
        if LocalService.shared.exists(isbn: book.isbn13) {
            bookingButton.image = UIImage(systemName: Const.HEART_FILL)
        } else {
            bookingButton.image = UIImage(systemName: Const.HEART)
        }
        
        let option = SettingService.shared.find(settingType: .Preview)
        previewButton.isHidden = !option.isOn
    }
}

extension BookDetailViewController: WKNavigationDelegate {
    func configureWebView() -> WKWebView {
        let wkWebView = WKWebView()
        wkWebView.navigationDelegate = self
        
        return wkWebView
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url!.absoluteString.hasPrefix("https://itbook.store/books") {
            webView.evaluateJavaScript("document.querySelector(\"[title='Free eBook']\").href") { value, error in
                if let downloadURL = value as? String {
                    print("redirect(\(downloadURL))")
                    webView.load(URLRequest(url: URL(string: downloadURL)!))
                } else {
                    ProgressHUD.showFailed("Failed to download file.", interaction: true)
                }
            }
            return
        }
        
        webView.evaluateJavaScript("document.querySelector(\"[title='Download PDF']\").href") { value, error in
            if let downloadURL = value as? String {
                print("download(\(downloadURL))")
                WebService.shared.download(url: downloadURL, title: self.book.title) { docURL in
                    self.previewURL = docURL
                    ProgressHUD.dismiss()
                    DispatchQueue.main.sync {
                        self.preview()
                    }
                }
            }
        }
    }
    
    func preview() {
        self.present(self.previewController, animated: true, completion: nil)
    }
}

extension BookDetailViewController: QLPreviewControllerDataSource {
    func configurePreviewController() -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = self
        return controller
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewURL! as QLPreviewItem
    }
}
