//
//  AppDelegate.swift
//  Cheers
//
//  Created by Will on 3/6/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var userLocation: CLLocationCoordinate2D? //Holds UserLocation Coordinates
    var locationManager: CLLocationManager!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        getUserLocation(); //Makes a call to determine user location on launch
        
        FirebaseApp.configure()
        
        let url = "https://api.yelp.com/v3/businesses/search"
        let parameters: [String: String] = ["term": "Firehouse",
                                            "location": "San Diego"]
        DatabaseController.getPlaceData(url: url, parameters: parameters)
        

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
    
    
    
//    //MARK: - Getting User Location
//    /***************************************************************/
    
    //Helper function
    func getUserLocation() {
        initLocationManager();
    }
    
    //inits all the required LocationManager settings
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        CLLocationManager.locationServicesEnabled()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //Pulls latest location and stops updating.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as? CLLocation
        let coord = locationObj?.coordinate
        userLocation = coord
        locationManager.stopUpdatingLocation()
        
    }
    


}

