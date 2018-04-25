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
    static let filterMenu = FilterMenu()
    
    // whether or not we are searching for bars in our favorites list
    // default is false
    var favorited: Bool = false
    
    // minimum user rating for search (i.e. more than 3 stars)
    // continuous element of [1,5]
    var ratingMinimum: Double?
    
    // maximum price for search (i.e. less than two dollar signs)
    // discrete element of [1,5]
    var priceMaximum: Int?
    
    // distance from my current location
    // default is 1 mile
    //var distanceFromMe: Double = 1.0
    var distanceFromMe: Double = 5.0
    
}

