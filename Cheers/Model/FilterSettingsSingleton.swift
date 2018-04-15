//
//  filterSettings.swift
//  Cheers
//
//  Created by Will on 3/14/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation

class FilterSettingsSingleton {
    static let shared = FilterSettingsSingleton()
    
    // whether or not we are searching for bars in our favorites list
    // default is false
    var favorited: Bool = false
    
    // minimum user rating for search (i.e. more than 3 stars)
    // discrete element of [1,5]
    // default is 0
    var ratingMinimum: Int = 0
    
    // maximum price for search (i.e. less than two dollar signs)
    // discrete element of [1,5]
    // default is 5
    var priceMaximum: Int = 5
    
    // distance from my current location
    // default is 1.0 mile 1609.34
    //var distanceFromMe: Double = 1609.34
    var distanceFromMe: Double = 1609.34 * 5
    
}

