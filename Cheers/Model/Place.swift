//
//  Place.swift
//  Cheers
//
//  Created by Will on 3/7/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation

extension String {
    var lines: [String] {
        var result: [String] = []
        enumerateLines { line, _ in result.append(line) }
        return result
    }
}

struct Place: Equatable{
    var record: DatabaseRecord
    var favorited: Bool
    
    static func ==(lhs: Place, rhs: Place) -> Bool {
        return lhs.record.id == rhs.record.id
    }
    
    /*
    // name of bar/restaurant/location
    var name: String
    
    // full address of Place
    var address: String
    
    // coordinates of Place
    var longitude: Double
    var latitude: Double
    
    // happy hours are organized in a dictionary:
    // key: String = day that happy hour occurs (i.e. "Monday")
    // value: tuple with two Dates = first Date is starting time of happy hour
    //                             = second Date is ending time of happy hour
    var happyHours: [String: (Int, Int)]
    //var happyHours: [String: String]
    
    // whether or not Place has been favorited
    var favorited: Bool
    
    // how pricy the Place is -- $ to $$$$ (Int between 1 and 4)
    var priciness: Int
    
    // star rating, in [0, 5]
    var averageUserRating: Double
    
    // neighborhood that bar is in
    var neighborhood: Neighborhood
    
    
    //Reads from BarInfoCheersApp.txt and returns an array of Place structs
    static func readFromTextFile() -> [Place] {
        //Read file into single string
        let file = Bundle.main.path(forResource: "BarInfoCheersApp", ofType: "txt")
        print(file!)
        var fileToString = ""
        var begin = 0
        var end = 0
        var placeStrings = [[String]]()
        var placeArray = [Place]()
        
        do {
            fileToString = try String(contentsOfFile: file!, encoding: .utf8)
        } catch let error as NSError {
            print("failed to read from text file")
            print(error)
        }
        
        var stringArray: [String] = []
        fileToString.enumerateLines { line, _ in
            stringArray.append(line)
        }
        
        //Split into array of strings for each bar
        for line in stringArray {
            print(line)
            if line.count == 0 { //separation between bars
                placeStrings.append(Array(stringArray[begin...end]))
                end += 1
                begin = end
            } else {
                end += 1
            }
        }
        
        //convert each array of strings into a struct
        for array in placeStrings {
            
            // read in fields that don't need to be manipulated
            let name = array[0]
            let address = array[1]
            let longitude = Double(array[3])!
            let latitude = Double(array[2])!
            let area = Neighborhood(rawValue: array[4])
            var favorited: Bool = false
            var priciness: Int = 1
            let averageUserRating = 4.0
            var happyHours = [String: (Int, Int)]()
            
            for i in 5..<array.count {
                
                guard i % 2 != 0 else {
                    continue
                }
                
                if let favTry = Bool(array[i].lowercased()) {
                    favorited = favTry
                    priciness = Int(array[i+1])!
                    break
                } else {
                    let days = array[i].components(separatedBy: ", ")
                    let drop = array[i+1].dropFirst(2)
                    let dropBoth = drop.dropLast(2)
                    let times = dropBoth.components(separatedBy: ", ")
                    
                    for day in days {
                        happyHours[day] = (Int(times[0])!,Int(times[1])!)
                    }
                    
                }
            }
            
            let newPlace = Place(name: name, address: address, longitude: longitude, latitude: latitude, happyHours: happyHours, favorited: favorited, priciness: priciness, averageUserRating: averageUserRating, neighborhood: area!)
            
            //add to array of structs
            placeArray.append(newPlace)
        }
        
        return placeArray
    } */
}

