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
    
    var bar: JSON? {
        didSet {
            
        }
    }
    
    static func getPlaceData(url: String, parameters: [String: String], happyHours: [String: String], neighborhood: Neighborhood) {
        let header: HTTPHeaders = [
            "Authorization": "Bearer Mxkbvkgu6VYllYtDz5Oppicd1FiPg2G6QBj2yiKw3nUlIaB1BUCSHAThlEMb_vF4Np5iNpYjNLuC_clWi-2yXAo_WTLzabGmeoAaNHwehd2MTOZwyYRX5fu741WsWnYx"
        ]
        
        var json: JSON? {
            didSet {
                DatabaseRecord.continueWriting(bar: json, happyHours: happyHours, neighborhood: neighborhood)
            }
        }
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: header).responseJSON { (response) in
            if response.result.isSuccess{
                
                json = JSON(response.result.value!)
                //print(json!)
                
            } else {
                print("Error \(String(describing: response.result.error))")
                
            }
        }
    }
    
    static func upload(record: DatabaseRecord) {
        
        let barToUpload = Database.database().reference().child(record.neighborhood.rawValue)
        var categoriesStrings = [String]()
        
        for cat in record.categories {
            categoriesStrings.append(cat.rawValue)
        }
        
        
        let barRecord: [String: Any] = [
            "id": record.id,
            "name": record.name,
            "longitude": record.longitude,
            "latitude": record.latitude,
            "rating:": record.rating,
            "price": record.price,
            "reviewCount": record.reviewCount,
            "phoneNumber": record.phoneNumber,
            "address": record.address,
            "city": record.city,
            "state": record.state,
            "zipCode": record.zipCode,
            "country": record.country,
            "images": record.images,
            "categories": categoriesStrings,
            "happyHours": record.happyHours,
            "neighborhood": record.neighborhood.rawValue
        ]
        
        barToUpload.child(record.name).setValue(barRecord) { (error, reference) in
            if error != nil {
                print("Error in writing to DB!")
                print(error!)
            } else {
                print("\(record.name) saved successfully to DB")
            }
        }
        
        
    }
    
}
