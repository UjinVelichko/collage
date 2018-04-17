/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setInitialViewController()
        
        return true
    }
    
    private func setInitialViewController() {
        let storyboard = UIStoryboard(name: CResources.Storyboard.main, bundle: nil)
        
        guard let navigation = storyboard.instantiateInitialViewController() as? UINavigationController,
            let captureVideoController = storyboard.instantiateViewController(withIdentifier: String(describing: CaptureVideoVC.self)) as? CaptureVideoVC else { return }
        
        navigation.viewControllers = [Injector.inject(to: captureVideoController, viewModel: CaptureVideoViewModel.self, model: CaptureVideoModel.self)]
        window?.rootViewController = navigation
    }
}


