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
    var image: UIImage
    var happyHours: String
    var favorited: Bool
    
    init(name: String, image: UIImage, happyHours: String, favorited: Bool) {
        self.name = name
        self.image = image
        self.happyHours = happyHours
        self.favorited = favorited
    }
}
