//
//  AppDelegate.swift
//  SampleApp
//
//  Created by Cameron Ollivierre on 12/22/21.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().barTintColor = .systemBlue
        UINavigationBar.appearance().tintColor = .white
        return true
    }
}
