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
import SwiftDate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var userLocation: CLLocationCoordinate2D? //Holds UserLocation Coordinates
    var locationManager: CLLocationManager!
    
    var masterList: [Place]? {
        didSet {
            filterList()
        }
    }
    var liveList: [Place]? {
        didSet {
            print("liveList has been calculated")
        }
    }
    var notLiveList: [Place]? {
        didSet {
            print("notLiveList has been calculated")
        }
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        getUserLocation(); //Makes a call to determine user location on launch
        
        FirebaseApp.configure()
        
        //DatabaseController.getPlaceData(url: url, parameters: parameters)
        DatabaseRecord.writeToDB()
        
        // TODO: make work with async call to CoreLocations
        // TODO: need to make 'forNeighborhood' not static
        //masterList = DatabaseController.readFromDB(fromNeighborhood: "Pacific Beach")
        DatabaseController.readFromDB(fromNeighborhood: "Pacific Beach")
        //filterList()

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
    
    // TODO: Need to finish this
    func filterList() {
        let current = Date()
        print("\(current.hour):\(current.minute)")
        
        for bar in masterList! {
            // TODO: this doesn't account for happy hours starting/ending not on the hour:
            // 5 PM -> all good
            // 5:30 PM -> need to fix
            if let happyHourString = bar.record.happyHours["\(current.weekdayName)"] {
                let (dayOffset, startTime, endTime): (Int, String, String) = computeTimes(for: happyHourString)
                let happyHourStartingDate = "\(current.year)-\(current.month)-\(current.day) \(startTime):00)".date(format: .custom("yyyy-MM-dd HH:MM"))
                let happyHourEndingDate = "\(current.year)-\(current.month)-\(current.day+dayOffset) \(endTime):00)".date(format: .custom("yyyy-MM-dd HH:MM"))
                
                let currentDate = DateInRegion(absoluteDate: current)
                
                if currentDate > happyHourStartingDate! && currentDate < happyHourEndingDate! {
                    liveList!.append(bar)
                } else {
                    notLiveList!.append(bar)
                }
                
            } else {
                notLiveList!.append(bar)
            }
        }
    }
    
    func computeTimes(for happyHourString: String) -> (Int, String, String) {
        let components = happyHourString.components(separatedBy: " ")
        var dayOffset = 0
        guard components.count == 5 else {
            print("ERROR: incompatible time")
            return (0, "", "")
        }
        
        var startTime = Int(components[0])!
        if components[1] == "pm" || components[1] == "Pm" || components[1] == "PM" || components[1] == "pM" {
            startTime += 12
        }
        var endTime = Int(components[3])!
        if components[4] == "am" || components[4] == "Am" || components[4] == "AM" || components[4] == "aM" {
            endTime += 12
            if endTime >= 24 {
                dayOffset += 1
                endTime -= 24
            }
        }
        
        return (dayOffset, String(startTime), String(endTime))
    }
    
    
    
    // MARK: - Getting User Location
    
    // Helper function
    func getUserLocation() {
        initLocationManager();
    }
    
    // inits all the required LocationManager settings
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        CLLocationManager.locationServicesEnabled()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Pulls latest location and stops updating.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as? CLLocation
        let coord = locationObj?.coordinate
        userLocation = coord
        locationManager.stopUpdatingLocation()
        
    }
    


}

