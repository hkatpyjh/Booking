import UIKit

class FavoriteCell: UICollectionViewListCell, SelfConfiguringCell {
    static var reuseIdentifier: String = "favorite-cell"
    
    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13.5, weight: .bold)
        label.numberOfLines = 1
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

    var book: LocalBook!
    var indexPath: IndexPath!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let topContainer = UIStackView(arrangedSubviews: [title, subtitle])
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        topContainer.axis = .vertical
        
        let bottomContainer = UIStackView(arrangedSubviews: [isbn, price])
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.axis = .vertical

        addSubview(imageView)
        addSubview(topContainer)
        addSubview(bottomContainer)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 100),
            
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 90),
            imageView.heightAnchor.constraint(equalTo: heightAnchor),

            topContainer.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            topContainer.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            bottomContainer.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            bottomContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func configure<T>(with model: T, _ indexPath: IndexPath) {
        self.book = model as? LocalBook
        self.indexPath = indexPath
        
        title.text = book.title.uppercased()
        subtitle.text = book.subtitle
        isbn.text = "ISBN: \(book.isbn13)"
        imageView.kf.setImage(with: URL(string: book.image))
        
        if Int.parse(from: book.price)! <= 0 {
            price.text = "Free"
            price.textColor = .systemGreen
        } else {
            price.text = "Price: \(book.price)"
            price.textColor = .label
        }
    }
    
    func configureButton() {
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
