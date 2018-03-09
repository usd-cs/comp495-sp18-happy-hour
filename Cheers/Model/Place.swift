//
//  Place.swift
//  Cheers
//
//  Created by Will on 3/7/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation

struct Place {
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
    var happyHours: [String: (Date, Date)]
    
    // whether or not Place has been favorited
    var favorited: Bool
    
    // how pricy the Place is -- $ to $$$$ (Int between 1 and 4)
    var priciness: Int
    
    // star rating, in [0, 5]
    var averageUserRating: Double
}
