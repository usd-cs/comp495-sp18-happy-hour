//
//  DatabaseController.swift
//  Cheers
//
//  Created by Meelad Dawood on 3/15/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation
import Firebase

class DatabaseController {
    
    static func upload() {
        let barList = Place.readFromTextFile()
        
        for bar in barList {
            let barToUpload = Database.database().reference().child(bar.neighborhood.rawValue)
            let barRecord: [String: Any] = ["Name": bar.name,
                             "Address": bar.address,
                             "Latitude": bar.latitude,
                             "Longitude": bar.longitude,
                             /*"Happy Hours": bar.happyHours,*/
                             "Favorited": bar.favorited,
                             "Priciness": bar.priciness,
                             "AverageUserRating": bar.averageUserRating,
                             "Neighborhood": bar.neighborhood.rawValue]
            barToUpload.child(bar.name).setValue(barRecord) { (error, reference) in
                if error != nil {
                    print("error")
                    print(error!)
                } else {
                    print("Message saved successfully")
                }
            }
        }
        
    }
    
}
