//
//  AppDelegate.swift
//  Cheers
//
//  Created by Will on 3/6/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Firebase
import Lyft
import LyftSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var userLocation: CLLocationCoordinate2D? //Holds UserLocation Coordinates
    var locationManager: CLLocationManager!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // set up Firebase
        FirebaseApp.configure()
        UserLocations.instantiateSharedInstance()
        
        // set up Lyft API
        LyftConfiguration.developer = (
            token: "QqBquxy3I6dOq/12Qd9LWGt0yhNtYeozqWaUq/AcZM/19ULc8M0SkM6tpHYRNLrBXqKpMyIT9hBqIbMPaLmQIe3tzjc83x6PLHfQDEtF3zCMPQzeGTMewQA=",
            clientId: "GfL8zotV5-nr"
        )
        
        // set up CoreLocations
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // load history and favorites from disk
        FavoritesSingleton.shared.loadFavorites()
        HistoryQueue.shared.loadHistory()
        
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

