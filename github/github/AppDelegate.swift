//
//  AppDelegate.swift
//  github
//
//  Created by krawiecp on 09/03/2016.
//  Copyright © 2016 Pawel Krawiec. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            let provider = GitHubProvider
            
            let tabBarController = UITabBarController()
            
            let discoverViewController = UIStoryboard.main.discoverViewController
            discoverViewController.viewModel = DiscoverViewModel(provider: provider)
            
            let searchViewController = UIStoryboard.main.searchViewController
            searchViewController.viewModel = SearchViewModel(provider: provider)
            
            tabBarController.viewControllers = [
                UINavigationController(rootViewController: discoverViewController),
                UINavigationController(rootViewController: searchViewController)
            ]
            
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
            
            let appToken = Token()
            if !appToken.tokenExists {
                let loginViewController = UIStoryboard.main.loginViewController
                loginViewController.viewModel = LoginViewModel(provider: provider)
                window.rootViewController?.present(loginViewController, animated: false, completion: nil)
            }
        }
        return true
    }
}

