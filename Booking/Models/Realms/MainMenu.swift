import Foundation
import RealmSwift

class MainMenu: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var menuType = ""
    @objc dynamic var menu = ""
    @objc dynamic var expanded = false
    @objc dynamic var color = ""
    @objc dynamic var createAt = Date()
    
    var submenus = List<SubMenu>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
