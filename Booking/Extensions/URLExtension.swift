import Foundation

extension URL {
    private static let baseUrl = "https://api.itbook.store/1.0"
    
    static var new: URL {
        get {
            URL(string: "\(baseUrl)/new")!
        }
    }
    
    static func book(key: String, with page: Int = 1) -> URL {
        let param = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return URL(string: "\(baseUrl)/search/?q=\(param)&page=\(page)")!
    }
    
    static func book(isbn: String) -> URL {
        return URL(string: "\(baseUrl)/books/\(isbn)")!
    }
    
    static func book(page: Int = Int.random(in: 1...100)) -> URL {
        return book(key: "all", with: page)
    }
}
