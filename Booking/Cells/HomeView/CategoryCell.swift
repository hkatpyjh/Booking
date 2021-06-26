import UIKit
import Kingfisher

class CategoryCell: UICollectionViewCell, SelfConfiguringCell {
    static let reuseIdentifier = "category-cell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var isbn: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var separator: UIView!
    
    fileprivate var book: Book!
    fileprivate var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure<T>(with model: T, _ indexPath: IndexPath) {
        self.book = model as? Book
        self.indexPath = indexPath
        
        title.text = book.title.uppercased()
        subtitle.text = book.subtitle
        isbn.text = "ISBN: \(book.isbn13!)"
        imageView.kf.setImage(with: URL(string: book.image))
        
        if Int.parse(from: book.price)! <= 0 {
            price.text = "Free"
            price.textColor = .systemGreen
        } else {
            price.text = "Price: \(book.price!)"
            price.textColor = .label
        }
        
        if indexPath.row % 2 == 1 {
            separator.isHidden = true
        } else {
            separator.isHidden = false
        }
        
        configureButton()
    }
    
    func configureButton() {
        if LocalService.shared.exists(isbn: book.isbn13) {
            favoriteButton.setImage(UIImage(systemName: Const.HEART_FILL), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(systemName: Const.HEART), for: .normal)
        }
    }
    
    @IBAction func handleFavoriteButton(_ sender: Any) {
        if LocalService.shared.exists(isbn: book.isbn13) {
            LocalService.shared.deleteConfirm(isbn: book.isbn13, self)
            return
        }
        
        LocalService.shared.saveConfirm(book: book, self)
    }
}
