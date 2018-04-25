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
    var liveList: [Place] = []
    var notLiveList: [Place] = []
    
    func filterLive() {
        let current = Date()
        let currentDate = DateInRegion(absoluteDate: current)
        
        for bar in masterList {
            
            print(bar.record.name)
            
            //
            
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
          //BUG          //liveList.append(bar)
                    print("Adding \(bar.record.name) to liveList...")
                    SharedListsSingleton.shared.liveList.append(bar)
                } else {
          //BUG          //notLiveList.append(bar)
                    print("Adding \(bar.record.name) to notLiveList...")
                    SharedListsSingleton.shared.notLiveList.append(bar)
                }
                
            } else {
          //BUG      //notLiveList.append(bar)
                print("Adding \(bar.record.name) to notLiveList...")
                SharedListsSingleton.shared.notLiveList.append(bar)
            }
        }
        
        print("The shared live list is this" , SharedListsSingleton.shared.liveList)
        
        SVProgressHUD.dismiss()
        filterWithSettings()
        
    }
    
    func filterWithSettings() {
        if let ratingMinimum = FilterSettingsSingleton.shared.ratingMinimum {
            liveList = liveList.filter { $0.record.rating >= ratingMinimum }
            notLiveList = notLiveList.filter { $0.record.rating >= ratingMinimum }
            print("Adding rating filter...")
        }
        if let priceMaximum = FilterSettingsSingleton.shared.priceMaximum {
            liveList = liveList.filter {Int($0.record.price.count) <= priceMaximum}
            notLiveList = notLiveList.filter {Int($0.record.price.count) <= priceMaximum}
            print("Adding price filter...")
        }
        if FilterSettingsSingleton.shared.favorited {
            print("Adding favorites filter...")
            // TODO: needs to work with FavoritesSingleton
        }
        // TODO: account for distance filter setting
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
            // TODO: fix this
            //This is crashing so Meelad added the next line
            //endTimeHours = 1
            //endTimeMinutes = 0
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
