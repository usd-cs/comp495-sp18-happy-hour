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
    
    static var refHandle: DatabaseHandle?
    
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
            "rating": record.rating,
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
    
    static func readFromDB(fromNeighborhood neighborhood: String) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        var places = [Place]()
        
        refHandle = ref.child("\(neighborhood)").observe(.value, with: { (snapshot) in
            
            let records = snapshot.value as? [String: AnyObject]
            for record in records! {
                let recordInfo = record.value as! [String: Any]
                
                let id = recordInfo["id"] as! String
                let name = recordInfo["name"] as! String
                let longitude = recordInfo["longitude"] as! Double
                let latitude = recordInfo["latitude"] as! Double
                let rating = recordInfo["rating"] as! Double
                let price = recordInfo["price"] as! String
                let reviewCount = recordInfo["reviewCount"] as! Int
                let phoneNumber = recordInfo["phoneNumber"] as! String
                let address = recordInfo["address"] as! String
                let city = recordInfo["city"] as! String
                let state = recordInfo["state"] as! String
                let zipCode = recordInfo["zipCode"] as! String
                let country = recordInfo["country"] as! String
                let images = recordInfo["images"] as! [String]
                
                let categoriesArray = recordInfo["categories"] as! [String]
                var categories = [BarType]()
                for category in categoriesArray {
                    categories.append(BarType(rawValue: category)!)
                }
                
                let happyHours = recordInfo["happyHours"] as! [String: String]
                
                let neighborhoodName = Neighborhood(rawValue: neighborhood)!
                
                let newRecord = DatabaseRecord(id: id, name: name, longitude: longitude, latitude: latitude, rating: rating, price: price, reviewCount: reviewCount, phoneNumber: phoneNumber, address: address, city: city, state: state, zipCode: zipCode, country: country, images: images, categories: categories, happyHours: happyHours, neighborhood: neighborhoodName)
                
                places.append(Place(record: newRecord, favorited: false))
          
            }
            
            returnPlaceArray(places: places)
        })
    }
    
    static func returnPlaceArray(places: [Place]) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.masterList = places
    }
    
}
