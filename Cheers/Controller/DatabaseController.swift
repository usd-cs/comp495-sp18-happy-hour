//
//  DatabaseController.swift
//  Cheers
//
//  Created by Meelad Dawood on 3/15/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation
import Firebase
import Alamofire
import SwiftyJSON

class DatabaseController {
    

    static func getPlaceData(url: String, parameters: [String: String]) {
        let heada: HTTPHeaders = [
            "Authorization": "Bearer Mxkbvkgu6VYllYtDz5Oppicd1FiPg2G6QBj2yiKw3nUlIaB1BUCSHAThlEMb_vF4Np5iNpYjNLuC_clWi-2yXAo_WTLzabGmeoAaNHwehd2MTOZwyYRX5fu741WsWnYx"
        ]
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: heada).responseJSON { (response) in
            if response.result.isSuccess{
                
                
                let bar : JSON = JSON(response.result.value!)
                print(bar)
                
                
            } else {
                print("Error \(String(describing: response.result.error))")
                
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
