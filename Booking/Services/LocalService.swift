import UIKit
import RealmSwift
import ProgressHUD

struct LocalService {
    static let shared = LocalService()
    let realm = try! Realm()
    var localBooks = try! Realm().objects(LocalBook.self).sorted(byKeyPath: "createAt", ascending: false)
    
    private init(){}
    
    func saveConfirm(book: Book, _ cell: SelfConfiguringCell) {
        AlertUtil.showAlert(msg: Const.MSG_ADD_CONFIRM) { (ok) in
            save(book: book)
            cell.configureButton()
        }
    }
    
    func save(book: Book) {
        ProgressHUD.show(interaction: false)
        
        let localBook: LocalBook = LocalBook()
        try! realm.write {
            localBook.isbn13 = book.isbn13
            localBook.title = book.title
            localBook.subtitle = book.subtitle
            localBook.price = book.price
            localBook.image = book.image
            realm.create(LocalBook.self, value: localBook, update: .modified)
        }
        
        ProgressHUD.showSucceed(interaction: true)
        print("Favorite items count \(localBooks.count)")
    }
    
    func deleteConfirm(isbn: String, _ cell: SelfConfiguringCell) {
        AlertUtil.showAlert(msg: Const.MSG_DEL_CONFIRM) { (ok) in
            delete(isbn: isbn)
            cell.configureButton()
        }
    }
    
    func delete(isbn: String) {
        let localBook = localBooks.filter("isbn13 = %@", isbn)
        try! realm.write {
            realm.delete(localBook)
        }
        print("Favorite items count \(localBooks.count)")
    }
    
    func exists(isbn: String) -> Bool {
        return localBooks.contains(where: { $0.isbn13.elementsEqual(isbn) })
    }
    
    func saveSearchHistory(key: String, type: SearchType) {
        if getSearchHistorys(type: type).contains(where: { $0.key == key }) {
            return
        }
        
        let history = SearchHistory()
        try! realm.write {
            history.key = key
            history.type = type.rawValue
            realm.create(SearchHistory.self, value: history, update: .modified)
        }
    }
    
    func getSearchHistorys(type: SearchType)-> [SearchHistory] {
        let results = realm.objects(SearchHistory.self).filter("type = %@", type.rawValue)
                                .sorted(byKeyPath: "createAt", ascending: false)
        
        return results.toArray()
    }
    
    func clearSearchHistory() {
        let historys = getSearchHistorys(type: .History)
        try! LocalService.shared.realm.write {
            LocalService.shared.realm.delete(historys)
        }
    }
    
    func delete(searchHistory: SearchHistory) {
        try! realm.write {
            realm.delete(searchHistory)
        }
    }
    
    func saveMenu(menu: MainMenu) {
        try! realm.write {
            realm.create(MainMenu.self, value: menu, update: .modified)
        }
    }
    
    func getMenus(menuType: MenuType)-> [MainMenu] {
        let results = realm.objects(MainMenu.self).filter("menuType = %@", menuType.rawValue)
            .sorted(byKeyPath: "createAt", ascending: true)

        return results.toArray()
    }
}
