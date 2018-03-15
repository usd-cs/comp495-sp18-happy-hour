//
//  filterSettings.swift
//  Cheers
//
//  Created by Will on 3/14/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation

struct filterSettings: Equatable {
    // whether or not we are searching for bars in our favorites list
    var favorited: Bool
    
    // minimum user rating for search (i.e. more than 3 stars)
    // discrete element of [1,5]
    var ratingMinimum: Int
    
    // maximum price for search (i.e. less than two dollar signs)
    // discrete element of [1,5]
    var priceMaximum: Int
    
    // distance from my current location
    var distanceFromMe: Double
    
    static func ==(lhs: filterSettings, rhs: filterSettings) -> Bool {
        return lhs.favorited == rhs.favorited && lhs.ratingMinimum == rhs.ratingMinimum && lhs.priceMaximum == rhs.priceMaximum && lhs.distanceFromMe == rhs.distanceFromMe
    }
    
}
