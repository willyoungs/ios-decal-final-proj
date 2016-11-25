//
//  AppDelegate.swift
//
//
//  Created by William Youngs on 9/8/16.
//  Copyright © 2016 William Youngs. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let locationManager = CLLocationManager()

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        var nav1 = UINavigationController()
        var mainView = ViewController(nibName: nil, bundle: nil) //ViewController = Name of your controller
        nav1.viewControllers = [mainView]
        self.window?.backgroundColor = UIColor.white
        self.window!.rootViewController = nav1
        self.window?.makeKeyAndVisible()
        // Added this for notifications.... Done nothing with it, but will likely need to soon
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {granted, error in})
        //        UIApplication.shared.setMinimumBackgroundFetchInterval(
        //            UIApplicationBackgroundFetchIntervalMinimum)
        //
        return true
    }
    //    //Added to initiate background fetch ........ Maybe throw code into ^^^
    //    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    //        UIApplication.shared.setMinimumBackgroundFetchInterval(
    //            UIApplicationBackgroundFetchIntervalMinimum)
    //
    //        return true
    //    }
    // Support for background fetch
    //    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    //
    //        if let tabBarController = window?.rootViewController as? UINavigationController,
    //            let viewControllers = tabBarController.viewControllers as? [UIViewController] {
    //            for viewController in viewControllers {
    //                if let ViewController = viewController as? ViewController {
    //                    ViewController.fetch {
    //                        ViewController.checkTimeAlarms()
    //                        completionHandler(.newData)
    //                    }
    //                }
    //            }
    //        }
    //    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //        UIApplication.shared.setMinimumBackgroundFetchInterval(
        //            UIApplicationBackgroundFetchIntervalMinimum)
        //        if let tabBarController = window?.rootViewController as? UINavigationController,
        //            let viewControllers = tabBarController.viewControllers as? [UIViewController] {
        //            for viewController in viewControllers {
        //                if let ViewController = viewController as? ViewController {
        //                    ViewController.fetch {
        //                        ViewController.checkTimeAlarms()
        //                    }
        //                }
        //            }
        //        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

