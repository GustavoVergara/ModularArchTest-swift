//
//  AppDelegate.swift
//  ModularArchTestTests
//
//  Created by Gustavo Vergara Garcia on 25/02/19.
//  Copyright © 2019 Gustavo Vergara. All rights reserved.
//

import UIKit

public class AppDelegate: UIResponder, UIApplicationDelegate {
    
    public static var shared: AppDelegate! {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    public var window: UIWindow? = UIWindow()
    let mainRouter = TargetContainer.target.mainRouter
    
    public func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.window.map(self.mainRouter.setRoot)
        return true
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        #if INJECTION_III_ENABLED
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection10.bundle")?.load()
        #endif
        return true
    }

}
