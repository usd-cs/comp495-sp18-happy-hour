//
//  DatabaseRecord.swift
//  Cheers
//
//  Created by Will on 3/20/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation
import SwiftyJSON

struct DatabaseRecord: Codable {
    var id: String
    var name: String
    var longitude: Double
    var latitude: Double
    var rating: Double
    var price: String
    var reviewCount: Int
    var phoneNumber: String
    
    // address info
    var addressLine1: String
    var addressLine2: String    // might be ""
    var addressLine3: String    // might be ""
    var address: String {
        if addressLine2 == "" {
            return addressLine1
        } else if addressLine3 == "" {
            return
                """
                \(addressLine1)
                \(addressLine2)
                """
        } else {
            return
                """
                \(addressLine1)
                \(addressLine2)
                \(addressLine3)
                """
        }
    }
    var city: String
    var state: String
    var zipCode: String
    var country: String
    
    var images: [String]        // could be empty
    var categories: [BarType]   // could be .unknown
    
    var happyHours: [String: String]
    var neighborhood: Neighborhood
    
    init(id: String, name: String, longitude: Double, latitude: Double, rating: Double, price: String, reviewCount: Int, phoneNumber: String, address: String, city: String, state: String, zipCode: String, country: String, images: [String], categories: [BarType], happyHours: [String: String], neighborhood: Neighborhood) {
        
        var addressLines = [String]()
        address.enumerateLines { (line, _) in
            addressLines.append(line)
        }
        
        var addressLine1, addressLine2, addressLine3: String
        switch addressLines.count {
        case 1:
            addressLine1 = addressLines[0]
            addressLine2 = ""
            addressLine3 = ""
        case 2:
            addressLine1 = addressLines[0]
            addressLine2 = addressLines[1]
            addressLine3 = ""
        default:
            addressLine1 = addressLines[0]
            addressLine2 = addressLines[1]
            addressLine3 = addressLines[2]
        }
        
        self = DatabaseRecord(id: id, name: name, longitude: longitude, latitude: latitude, rating: rating, price: price, reviewCount: reviewCount, phoneNumber: phoneNumber, addressLine1: addressLine1, addressLine2: addressLine2, addressLine3: addressLine3, city: city, state: state, zipCode: zipCode, country: country, images: images, categories: categories, happyHours: happyHours, neighborhood: neighborhood)
    
    }
    
    
    
    init(id: String, name: String, longitude: Double, latitude: Double, rating: Double, price: String, reviewCount: Int, phoneNumber: String, addressLine1: String, addressLine2: String, addressLine3: String, city: String, state: String, zipCode: String, country: String, images: [String], categories: [BarType], happyHours: [String: String], neighborhood: Neighborhood) {
        self.id = id
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
        self.rating = rating
        self.price = price
        self.reviewCount = reviewCount
        self.phoneNumber = phoneNumber
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.addressLine3 = addressLine3
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
        self.images = images
        self.categories = categories
        self.happyHours = happyHours
        self.neighborhood = neighborhood
    }
    
    static func writeToDB() {
        let file = Bundle.main.path(forResource: "NorthParkBars", ofType: "txt")
        var fileToString = ""
        do {
            fileToString = try String(contentsOfFile: file!, encoding: .utf8)
        } catch let error as NSError {
            print("Failed to read from text file")
            print(error)
        }
        
        var stringArray: [String] = []
        fileToString.enumerateLines { line, _  in
            stringArray.append(line)
        }
        
        var happyHours: [String: String] = [:]
        var neighborhood: Neighborhood = .unknown
        var name: String = ""
        var count: Int = 0
        while !stringArray.isEmpty {
            if count == 0 {
                name = stringArray[0]
                count += 1
                stringArray.remove(at: 0)
            } else if count == 1 {
                if let isValidHood = Neighborhood(rawValue: stringArray[0]) {
                    neighborhood = isValidHood
                }
                count += 1
                stringArray.remove(at: 0)
            } else {
                if stringArray[0].lowercased() == "end of record" {
                    let url = "https://api.yelp.com/v3/businesses/search"
                    let parameters: [String: String] = ["term": "\(name)",
                        "location": "San Diego",
                        "limit": "1"
                    ]
                    DatabaseController.getPlaceData(url: url, parameters: parameters, happyHours: happyHours, neighborhood: neighborhood)
                    neighborhood = .unknown
                    count = 0
                    stringArray.remove(at: 0)
                    happyHours = [:]
                    //break
                } else {
                    let day = stringArray[0]
                    let time = stringArray[1]
                    stringArray.remove(at: 0)
                    stringArray.remove(at: 0)
                    happyHours[day] = time
                }
            }
        }
        
    }
    
    static func continueWriting(bar: JSON?, happyHours: [String: String], neighborhood: Neighborhood) {
        guard let bar = bar else { return }
        
        print(bar)
        
        let id = bar["businesses"].arrayValue.map({$0["id"].stringValue})[0]
        let name = bar["businesses"].arrayValue.map({$0["name"].stringValue})[0]
        let longitude = Double(bar["businesses"].arrayValue.map({$0["coordinates"]}).map({$0["longitude"].stringValue})[0])!
        let latitude = Double(bar["businesses"].arrayValue.map({$0["coordinates"]}).map({$0["latitude"].stringValue})[0])!
        let rating = Double(bar["businesses"].arrayValue.map({$0["rating"].stringValue})[0])!
        let price = bar["businesses"].arrayValue.map({$0["price"].stringValue})[0]
        let reviewCount = Int(bar["businesses"].arrayValue.map({$0["review_count"].stringValue})[0])!
        let phoneNumber = bar["businesses"].arrayValue.map({$0["display_phone"].stringValue})[0]
        
        let addressLine1 = bar["businesses"].arrayValue.map({$0["location"]}).map({$0["address1"].stringValue})[0]
        let addressLine2 = bar["businesses"].arrayValue.map({$0["location"]}).map({$0["address2"].stringValue})[0]
        let addressLine3 = bar["businesses"].arrayValue.map({$0["location"]}).map({$0["address3"].stringValue})[0]
        let city = bar["businesses"].arrayValue.map({$0["location"]}).map({$0["city"].stringValue})[0]
        let state = bar["businesses"].arrayValue.map({$0["location"]}).map({$0["state"].stringValue})[0]
        let zipCode = bar["businesses"].arrayValue.map({$0["location"]}).map({$0["zip_code"].stringValue})[0]
        let country = bar["businesses"].arrayValue.map({$0["location"]}).map({$0["country"].stringValue})[0]
        
        let categoriesJSON = bar["businesses"].arrayValue.map({$0["categories"]})[0]
        var categories = [BarType]()
        for category in categoriesJSON {
            let rawValue = category.1["alias"].rawString()!
            if let enumValue = BarType(rawValue: rawValue) {
                categories.append(enumValue)
            }
        }
        
        var images = [String]()
        images.append(bar["businesses"].arrayValue.map({$0["image_url"].stringValue})[0])
        
        let newDBRecord = DatabaseRecord(id: id, name: name, longitude: longitude, latitude: latitude, rating: rating, price: price, reviewCount: reviewCount, phoneNumber: phoneNumber, addressLine1: addressLine1, addressLine2: addressLine2, addressLine3: addressLine3, city: city, state: state, zipCode: zipCode, country: country, images: images, categories: categories, happyHours: happyHours, neighborhood: neighborhood)
        
        DatabaseController.upload(record: newDBRecord)
    }
    
}
