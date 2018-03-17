//
//  DatabaseController.swift
//  Cheers
//
//  Created by Meelad Dawood on 3/15/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation
import Firebase
import CDYelpFusionKit
import Alamofire
import SwiftyJSON

class DatabaseController {
    
    let yelpAPIKey = "Mxkbvkgu6VYllYtDz5Oppicd1FiPg2G6QBj2yiKw3nUlIaB1BUCSHAThlEMb_vF4Np5iNpYjNLuC_clWi-2yXAo_WTLzabGmeoAaNHwehd2MTOZwyYRX5fu741WsWnYx"
    let yelpClientID = "jGMy2UMn7d3FOwtbUPHaVQ"
    
    let headers: HTTPHeaders = [
        "Authorization": "Bearer Mxkbvkgu6VYllYtDz5Oppicd1FiPg2G6QBj2yiKw3nUlIaB1BUCSHAThlEMb_vF4Np5iNpYjNLuC_clWi-2yXAo_WTLzabGmeoAaNHwehd2MTOZwyYRX5fu741WsWnYx"
    ]

    
    static func getPlaceData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers) {
            response in
            if response.result.isSuccess {
                
                let barJSON : JSON = JSON(response.result.value!)
                print(barJSON)
                
            } else {
                print("error")
            }
        }
    }
    
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
