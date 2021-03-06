//
//  PlaceMapAnnotationViewModel.swift
//  Cheers
//
//  Created by Will on 4/4/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation
import MapViewPlus

class PlaceMapAnnotationViewModel: CalloutViewModel {
    var name: String
    //var image: UIImage
    var happyHours: String
    var favorited: Bool
    
    var live: Bool
    
    var place: Place
    
    init(name: String,  happyHours: String, favorited: Bool, place: Place, live: Bool) {
        self.name = name
        //self.image = image
        self.happyHours = happyHours
        self.favorited = favorited
        self.place = place
        self.live = live
        
        
    }
}
