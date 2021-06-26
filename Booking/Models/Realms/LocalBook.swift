import Foundation
import RealmSwift

class LocalBook: Object {
    @objc dynamic var isbn13 = ""
    @objc dynamic var title = ""
    @objc dynamic var subtitle = ""
    @objc dynamic var price = ""
    @objc dynamic var image = ""
    @objc dynamic var createAt = Date()
    
    override static func primaryKey() -> String? {
        return "isbn13"
    }
}
