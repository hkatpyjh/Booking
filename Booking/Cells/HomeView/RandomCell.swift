import UIKit
import Kingfisher

class RandomCell: UICollectionViewCell, SelfConfiguringCell {
    static let reuseIdentifier = "random-cell"
    
    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13.5, weight: .bold)
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()
    
    let subtitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        return label
    }()
    
    let isbn: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .label
        return label
    }()
    
    let price: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .label
        return label
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return imageView
    }()
    
    let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: Const.HEART), for: .normal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let separator: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternaryLabel
        return view
    }()

    var book: Book!
    var indexPath: IndexPath!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        favoriteButton.addTarget(self, action: #selector(handleFavoriteButton(_:)), for: .touchUpInside)
        
        let topContainer = UIStackView(arrangedSubviews: [title, subtitle])
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        topContainer.axis = .vertical
        
        let bottomContainer = UIStackView(arrangedSubviews: [isbn, price])
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.axis = .vertical
        
        let rightContainer = UIView(frame: .zero)
        rightContainer.translatesAutoresizingMaskIntoConstraints = false
        rightContainer.addSubview(topContainer)
        rightContainer.addSubview(bottomContainer)

        addSubview(imageView)
        addSubview(rightContainer)
        addSubview(favoriteButton)
        addSubview(separator)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 90),
            imageView.heightAnchor.constraint(equalTo: heightAnchor),
            
            favoriteButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            favoriteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 50),
            favoriteButton.heightAnchor.constraint(equalToConstant: 50),
            
            topContainer.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            topContainer.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -10),
            
            bottomContainer.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: favoriteButton.trailingAnchor, constant: -10),
            bottomContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),

            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
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
        
        configureButton()
    }
    
    func configureButton() {
        if LocalService.shared.exists(isbn: book.isbn13) {
            favoriteButton.setImage(UIImage(systemName: Const.HEART_FILL), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(systemName: Const.HEART), for: .normal)
        }
    }
    
    @objc func handleFavoriteButton(_ sender: UIButton) {
        if LocalService.shared.exists(isbn: book.isbn13) {
            LocalService.shared.deleteConfirm(isbn: book.isbn13, self)
            return
        }
        
        LocalService.shared.saveConfirm(book: book, self)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
