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
            liveList = []
            notLiveList = []
            filterList()
        }
    }
    var liveList: [Place]? {
        didSet {
            // DEBUG:
            print("liveList now has \(liveList!.count) elements")
        }
    }
    var notLiveList: [Place]? {
        didSet {
            // DEBUG:
            print("notLiveList now has \(notLiveList!.count) elements")
        }
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        getUserLocation(); //Makes a call to determine user location on launch
        
        FirebaseApp.configure()
        
        // DEBUG: when reading from DB, comment out this line
        // DEBUG: when writing to DB, uncomment this line
        //DatabaseRecord.writeToDB()
        
        // TODO: make work with async call to CoreLocations
        // TODO: need to make 'forNeighborhood' not static
        
        // DEBUG: when writing to DB, comment out this line
        // DEBUG: when reading from DB, uncomment this line
        DatabaseController.readFromDB(fromNeighborhood: "Pacific Beach")
        
        while true {
            if notLiveList == nil {
                continue
            } else if notLiveList!.count != 0 {
                break
            }
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
    
    func filterList() {
        let current = Date()
        let currentDate = DateInRegion(absoluteDate: current)
        
        for bar in masterList! {
            // TODO: this doesn't account for happy hours starting/ending not on the hour:
            // 5 PM -> all good
            // 5:30 PM -> need to fix
            if let happyHourString = bar.record.happyHours["\(current.weekdayName)"] {
                
                let (dayOffset, startTime, startTimeMinutes, endTime, endTimeMinutes): (Int, String, String, String, String) = computeTimes(for: happyHourString)
                
                var startingDate = DateComponents()
                startingDate.year = currentDate.year
                startingDate.timeZone = TimeZoneName.americaLosAngeles.timeZone
                startingDate.calendar = CalendarName.gregorian.calendar
                startingDate.month = currentDate.month
                startingDate.day = currentDate.day
                startingDate.hour = Int(startTime)!
                startingDate.minute = Int(startTimeMinutes)
                let happyHourStartingDate = DateInRegion(components: startingDate)
                
                var endingDate = DateComponents()
                endingDate.year = currentDate.year
                endingDate.timeZone = TimeZoneName.americaLosAngeles.timeZone
                endingDate.calendar = CalendarName.gregorian.calendar
                endingDate.month = currentDate.month
                endingDate.day = currentDate.day + dayOffset
                endingDate.hour = Int(endTime)!
                endingDate.minute = Int(endTimeMinutes)
                let happyHourEndingDate = DateInRegion(components: endingDate)
                
                if currentDate > happyHourStartingDate! && currentDate < happyHourEndingDate! {
                    liveList!.append(bar)
                    
                    // DEBUG:
                    print("\tAdding \(bar.record.name) to live list")
                } else {
                    notLiveList!.append(bar)
                    
                    // DEBUG:
                    print("\tAdding \(bar.record.name) to not live list")
                }
                
            } else {
                notLiveList!.append(bar)
                print("\tAdding \(bar.record.name) to not live list")
            }
        }
        
//        //let listViewController = self.window?.ListViewController as! UIViewController
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        
//        let listViewController = UIApplication.shared.
//        
//        listViewController.liveList = self.liveList
//        listViewController.notLiveList = self.notLiveList
    }
    
    func computeTimes(for happyHourString: String) -> (Int, String, String, String, String) {
        let components = happyHourString.components(separatedBy: " ")
        var dayOffset = 0
        var startInMorning: Bool = true
        var startTime: Int
        var startTimeMinutes: Int
        var endTime: Int
        var endTimeMinutes: Int
        guard components.count == 5 else {
            print("ERROR: incompatible time")
            return (0, "", "", "", "")
        }
        
        // compute starting time
        if components[0].contains(":") {
            let startComponents = components[0].components(separatedBy: ":")
            startTime = Int(startComponents[0])!
            startTimeMinutes = Int(startComponents[1])!
        } else {
            startTime = Int(components[0])!
            startTimeMinutes = 0
        }
        
        if components[1] == "pm" || components[1] == "Pm" || components[1] == "PM" || components[1] == "pM" {
            startTime += 12
            startInMorning = false
        }
        
        // compute ending time
        if components[1].contains(":") {
            let endComponents = components[1].components(separatedBy: ":")
            endTime = Int(endComponents[0])!
            endTimeMinutes = Int(endComponents[1])!
        } else {
            endTime = Int(components[3])!
            endTimeMinutes = 0
        }
        
        if components[4] == "pm" || components[4] == "Pm" || components[4] == "PM" || components[4] == "pM" {
            endTime += 12
        } else if components[4] == "am" || components[4] == "Am" || components[4] == "AM" || components[4] == "aM" {
            if !startInMorning {
                dayOffset += 1
            }
        }
        
        return (dayOffset, String(startTime), String(startTimeMinutes), String(endTime), String(endTimeMinutes))
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

