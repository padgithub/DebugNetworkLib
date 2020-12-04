//
//  AppDelegate.swift
//  DebugNetworkLibExample
//
//  Created by Phung Anh Dung on 11/14/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DNL.sharedInstance().start()
        return true
    }
}

