//
//  AppDelegate.swift
//  BasicAppTemplate-iOS
//
//  Created by Ali Hajjaj on 3/18/18.
//  Copyright © 2018 Imagine Technologies. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIFont.familyNames.forEach({ familyName in
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            print(familyName, fontNames)
        })
        
        GMSServices.provideAPIKey(APIKeys.GoogleMaps)
        
        // In order for the following code to run properly. You must have
        // a valid GoogleService-Info.plist in your project.
        // Please download one from https://console.firebase.google.com/.'
        // The uncomment it.
        
        // FirebaseApp.configure()
        
        // Sample firebase event logging. Also uncomment this when you setup the above properly.
        // Analytics.logEvent(AnalyticsEventAppOpen, parameters: [:])
        
        // Do something when user launch app by tapping on a remote notification
        if let _ = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
            
            // Example on notification names
            NotificationCenter.default.post(name: NotificationNames.AppOpenedByTappingPushNotification, object: nil)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

