//
//  AppDelegate.swift
//  AirQuality
//
//  Created by Richard Moult on 31/12/19.
//  Copyright © 2019 RichardMoult. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appNavigator: AppNavigator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
        // Short-circuit starting app if running unit tests
        let isUnitTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        guard !isUnitTesting else {
            return true
        }
        #endif

        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else { return true }

        let viewControllerFactory = ViewControllerFactory()
        
        let navigationController = UINavigationController()

        appNavigator = AppNavigator(window: window,
                              navigationController: navigationController,
                              viewControllerFactory: viewControllerFactory,
                              informationAlert: InformationAlert(),
                              animateTransitions: true)

        appNavigator?.start()

        return true
    }
}

// MARK: - App life cycle

extension AppDelegate {
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
}
