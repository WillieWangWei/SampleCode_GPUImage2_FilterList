//
//  AppDelegate.swift
//  SampleCode_GPUImage2_FilterList
//
//  Created by 王炜 on 2017/2/13.
//  Copyright © 2017年 Willie. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: FilterListTableViewController())
        window?.makeKeyAndVisible()
        
        return true
    }
}

