import Foundation
import RealmSwift

class SearchHistory: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var type = ""
    @objc dynamic var key = ""
    @objc dynamic var createAt = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
