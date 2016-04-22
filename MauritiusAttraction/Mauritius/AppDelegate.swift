//
//  AppDelegate.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 17/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import UIKit
import Parse

var APP_DEFAULT_LANGUAGE: Language = .English //Lanaguage for app

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var viewController: UIViewController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        // Override point for customization after application launch.
        UINavigationBar.appearance().barStyle = .Black
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        if userDefaults.integerForKey("currentLanguage") != 0{
            APP_DEFAULT_LANGUAGE = Language(rawValue: userDefaults.integerForKey("currentLanguage"))!
        }
        
        //Parse Connection
        Parse.setApplicationId("PMipl2gmbDK4b1UTaBBb9XTU8VADHnpPtiZxoVEo",
            clientKey: "12DLcXOAgsqNZLn6lp7oYwKsSoqWPNdi3WjDJ6T2")
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let mainVC = MainViewController()
        let rearVC = RearViewController()
        
        let frontNavController = UINavigationController(rootViewController: mainVC)
        let rearNavController = UINavigationController(rootViewController: rearVC)
        
        let revealVC: SWRevealViewController = SWRevealViewController(rearViewController: rearNavController, frontViewController: frontNavController)
        self.viewController = revealVC
        
        self.window?.rootViewController = self.viewController
        self.window?.makeKeyAndVisible()
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

