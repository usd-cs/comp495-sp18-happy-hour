//
//  SharedListsSingleton.swift
//  Cheers
//
//  Created by Will on 4/4/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation
import SwiftDate
import SVProgressHUD

class SharedListsSingleton {
    static let shared = SharedListsSingleton()
    var masterList: [Place] = [] {
        didSet {
            filterLive()
        }
    }
    
    var preFilteredAllList: [Place] = []
    var preFilteredLiveList: [Place] = []
    var preFilteredNotLiveList: [Place] = []
    var allList: [Place] = []
    var liveList: [Place] = []
    var notLiveList: [Place] = []
    
    func filterLive() {
        let current = Date()
        let currentDate = DateInRegion(absoluteDate: current)
        
        for bar in masterList {
            
            if let happyHourString = bar.record.happyHours["\(current.weekdayName)"] {
                
                let (dayOffset, startTimeHours, startTimeMinutes, endTimeHours, endTimeMinutes): (Int, String, String, String, String) = computeTimes(for: happyHourString)
                
                var startingDate = DateComponents()
                startingDate.year = currentDate.year
                startingDate.timeZone = TimeZoneName.americaLosAngeles.timeZone
                startingDate.calendar = CalendarName.gregorian.calendar
                startingDate.month = currentDate.month
                startingDate.day = currentDate.day
                
                startingDate.hour = Int(startTimeHours)!
                startingDate.minute = Int(startTimeMinutes)
                let happyHourStartingDate = DateInRegion(components: startingDate)
                
                var endingDate = DateComponents()
                endingDate.year = currentDate.year
                endingDate.timeZone = TimeZoneName.americaLosAngeles.timeZone
                endingDate.calendar = CalendarName.gregorian.calendar
                endingDate.month = currentDate.month
                endingDate.day = currentDate.day + dayOffset
                endingDate.hour = Int(endTimeHours)!
                endingDate.minute = Int(endTimeMinutes)
                let happyHourEndingDate = DateInRegion(components: endingDate)
                
                if currentDate > happyHourStartingDate! && currentDate < happyHourEndingDate! {
                    preFilteredLiveList.append(bar)
                } else {
                    preFilteredNotLiveList.append(bar)
                    SharedListsSingleton.shared.notLiveList.append(bar)
                }
                
            } else {
                preFilteredNotLiveList.append(bar)
            }
            preFilteredAllList.append(bar)
        }
        
        SVProgressHUD.dismiss()
        liveList = preFilteredLiveList
        notLiveList = preFilteredNotLiveList
        allList = preFilteredAllList
        filterWithSettings()
        
    }
    
    func filterWithSettings() {
        var tempLiveList: [Place] = preFilteredLiveList
        var tempNotLiveList: [Place] = preFilteredNotLiveList
        var tempAllList: [Place] = preFilteredAllList
        
        if let ratingMinimum = FilterSettingsSingleton.shared.ratingMinimum {
            if ratingMinimum != 1.0 {
                tempLiveList = tempLiveList.filter { $0.record.rating >= ratingMinimum }
                tempNotLiveList = tempNotLiveList.filter { $0.record.rating >= ratingMinimum }
                tempAllList = tempAllList.filter { $0.record.rating >= ratingMinimum }
                print("Adding rating filter...")
            }
        }
        if let priceMaximum = FilterSettingsSingleton.shared.priceMaximum {
            if priceMaximum != 0 {
                tempLiveList = tempLiveList.filter { Int($0.record.price.count) <= priceMaximum }
                tempNotLiveList = tempNotLiveList.filter { Int($0.record.price.count) <= priceMaximum }
                tempAllList = tempAllList.filter { Int($0.record.price.count) <= priceMaximum }
                print("Adding price filter...")
            }
        }
        if FilterSettingsSingleton.shared.favorited {
            print("Adding favorites filter...")
            // TODO: needs to work with FavoritesSingleton
            tempLiveList = tempLiveList.filter { FavoritesSingleton.shared.favorites.contains($0) }
            tempNotLiveList = tempNotLiveList.filter { FavoritesSingleton.shared.favorites.contains($0) }
            tempAllList = tempAllList.filter { FavoritesSingleton.shared.favorites.contains($0) }
        }
        
        // distance calculations
        print("Adding distance filter...")
        tempLiveList = tempLiveList.filter { calculateDistance(myLat: (UserLocations.shared.currentLocation?.coordinate.latitude)!, myLong: (UserLocations.shared.currentLocation?.coordinate.longitude)!, placeLat: $0.record.latitude, placeLong: $0.record.longitude) < FilterSettingsSingleton.shared.distanceFromMe }
        tempNotLiveList = tempNotLiveList.filter { calculateDistance(myLat: (UserLocations.shared.currentLocation?.coordinate.latitude)!, myLong: (UserLocations.shared.currentLocation?.coordinate.longitude)!, placeLat: $0.record.latitude, placeLong: $0.record.longitude) < FilterSettingsSingleton.shared.distanceFromMe }
        tempAllList = tempAllList.filter { calculateDistance(myLat: (UserLocations.shared.currentLocation?.coordinate.latitude)!, myLong: (UserLocations.shared.currentLocation?.coordinate.longitude)!, placeLat: $0.record.latitude, placeLong: $0.record.longitude) < FilterSettingsSingleton.shared.distanceFromMe }
        
        if let sortBy = FilterSettingsSingleton.shared.sortBy {
            if sortBy != 0 {
                switch(sortBy){
                case 1:
                    tempLiveList = tempLiveList.sorted { $0.record.rating < $1.record.rating }
                    tempNotLiveList = tempNotLiveList.sorted { $0.record.rating < $1.record.rating }
                    tempAllList = tempAllList.sorted { $0.record.rating < $1.record.rating }
                case 2:
                    tempLiveList = tempLiveList.sorted { $0.record.price < $1.record.price }
                    tempNotLiveList = tempNotLiveList.sorted { $0.record.price < $1.record.price }
                    tempAllList = tempAllList.sorted { $0.record.price < $1.record.price }
                case 3:
                    tempLiveList = tempLiveList.sorted { calculateDistance(myLat: (UserLocations.shared.currentLocation?.coordinate.latitude)!, myLong: (UserLocations.shared.currentLocation?.coordinate.longitude)!, placeLat: $0.record.latitude, placeLong: $0.record.longitude) < calculateDistance(myLat: (UserLocations.shared.currentLocation?.coordinate.latitude)!, myLong: (UserLocations.shared.currentLocation?.coordinate.longitude)!, placeLat: $1.record.latitude, placeLong: $1.record.longitude) }
                    tempNotLiveList = tempNotLiveList.sorted { calculateDistance(myLat: (UserLocations.shared.currentLocation?.coordinate.latitude)!, myLong: (UserLocations.shared.currentLocation?.coordinate.longitude)!, placeLat: $0.record.latitude, placeLong: $0.record.longitude) < calculateDistance(myLat: (UserLocations.shared.currentLocation?.coordinate.latitude)!, myLong: (UserLocations.shared.currentLocation?.coordinate.longitude)!, placeLat: $1.record.latitude, placeLong: $1.record.longitude) }
                    tempAllList = tempAllList.sorted { calculateDistance(myLat: (UserLocations.shared.currentLocation?.coordinate.latitude)!, myLong: (UserLocations.shared.currentLocation?.coordinate.longitude)!, placeLat: $0.record.latitude, placeLong: $0.record.longitude) < calculateDistance(myLat: (UserLocations.shared.currentLocation?.coordinate.latitude)!, myLong: (UserLocations.shared.currentLocation?.coordinate.longitude)!, placeLat: $1.record.latitude, placeLong: $1.record.longitude) }
                default:
                    print("Not Sorted")
                }
            }
        }
        
        liveList = tempLiveList
        notLiveList = tempNotLiveList
        allList = tempAllList
    }
    
    func calculateDistance(myLat: Double, myLong: Double, placeLat: Double, placeLong: Double) -> Double {
        let radius: Double = 6371.0
        let deltaLat: Double = toRadians(placeLat - myLat)
        let deltaLong: Double = toRadians(placeLong - myLong)
        
        let a: Double =
            sin(deltaLat / 2.0) * sin(deltaLat / 2.0) +
            cos(toRadians(myLat)) * cos(toRadians(placeLat)) *
            sin(deltaLong / 2.0) * sin(deltaLong / 2.0)
        
        let c: Double = 2.0 * atan2(sqrt(a), sqrt(1.0 - a))
        let d: Double = radius * c * 0.621371
        return d
    }
    
    func toRadians(_ degrees: Double) -> Double {
        return degrees * (Double.pi / 180.0)
    }
    
    func computeTimes(for happyHourString: String) -> (Int, String, String, String, String) {
        let components = happyHourString.components(separatedBy: " ")
        var dayOffset = 0
        var startInMorning: Bool = true
        var startTimeHours: Int
        var startTimeMinutes: Int
        var endTimeHours: Int
        var endTimeMinutes: Int
        guard components.count == 5 else {
            print("ERROR: incompatible time")
            return (0, "", "", "", "")
        }
        
        // compute starting time
        if components[0].contains(":") {
            let startComponents = components[0].components(separatedBy: ":")
            startTimeHours = Int(startComponents[0])!
            startTimeMinutes = Int(startComponents[1])!
        } else {
            startTimeHours = Int(components[0])!
            startTimeMinutes = 0
        }
        
        if components[1] == "pm" || components[1] == "Pm" || components[1] == "PM" || components[1] == "pM" {
            startTimeHours += 12
            startInMorning = false
        }
        
        // compute ending time
        if components[3].contains(":") {
            let endComponents = components[3].components(separatedBy: ":")
            endTimeHours = Int(endComponents[0])!
            endTimeMinutes = Int(endComponents[1])!
        } else {
            endTimeHours = Int(components[3])!
            endTimeMinutes = 0
        }
        
        if components[4] == "pm" || components[4] == "Pm" || components[4] == "PM" || components[4] == "pM" {
            endTimeHours += 12
        } else if components[4] == "am" || components[4] == "Am" || components[4] == "AM" || components[4] == "aM" {
            if !startInMorning {
                dayOffset += 1
            }
        }
        
        return (dayOffset, String(startTimeHours), String(startTimeMinutes), String(endTimeHours), String(endTimeMinutes))
    }
}


