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
    
}
