/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */
import UIKit

struct Alert {
    static func show(title: String = CAlert.messageDefTitle, message: String, needCancel: Bool = false, handler: ((UIAlertAction)->())? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: CAlert.okButtonTitle, style: .default, handler: handler))
            
            if needCancel {
                alert.addAction(UIAlertAction(title: CAlert.cancelButtonTitle, style: .cancel, handler: nil))
            }
            
            self.getCurrentController().present(alert, animated: true, completion: nil)
        }
    }
    
    static private func getCurrentController() -> UIViewController {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
        } else { fatalError("No root ViewController") }
    }
}
