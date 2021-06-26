import UIKit

struct AlertUtil {
    static func showAlert(msg: String, completionBlock: @escaping (Bool)->()) {
        let actionPositive = UIAlertAction(title: Const.YES, style: .default, handler:{ (ok) in
            completionBlock(true)
        })
        
        let alert: UIAlertController = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        alert.addAction(actionPositive)
        alert.addAction(UIAlertAction(title: Const.NO, style: .destructive))
        
        UIApplication.parentViewController()!.present(alert, animated: true, completion: nil)
    }
    
    static func showAlertWithTextField(_ title: String  = "", msg: String, completionBlock: @escaping (String)->()) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: Const.YES, style: .default, handler: { [weak alert] (_) in
            guard let text = alert?.textFields![0].text else {
                return
            }
            completionBlock(text)
        }))
        
        alert.addAction(UIAlertAction(title: Const.NO, style: .destructive))
        
        UIApplication.parentViewController()!.present(alert, animated: true, completion: nil)
    }
}
