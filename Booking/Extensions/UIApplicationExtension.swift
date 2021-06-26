import UIKit

extension UIApplication {
    class func parentViewController(base: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return parentViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return parentViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return parentViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return parentViewController(base: presented)
        }
        
        return base
    }
}
