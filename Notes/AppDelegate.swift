//
//  AppDelegate.swift
//  Notes
//
//  Created by Christopher J Moore on 9/1/17.
//  Copyright © 2017 FarmLogs. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        coordinator = AppCoordinator(window: window!)
        coordinator?.start()

        return true
    }
}

