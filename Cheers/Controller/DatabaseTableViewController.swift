//
//  DatabaseTableViewController.swift
//  Cheers
//
//  Created by Will Carhart on 4/19/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import Alamofire
import SwiftyJSON
import SVProgressHUD

class DatabaseTableViewController: UITableViewController {
    
    static var refHandle: DatabaseHandle?
    
    var uploads: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Uploaded Bars"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Uploaded Bars"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SVProgressHUD.show()
        DispatchQueue.global(qos: .background).async {
            self.writeToDB()
            SVProgressHUD.dismiss()
            print("\nAll uploads completed successfully.")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uploads.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UploadedBarCell", for: indexPath)
        cell.textLabel?.text = uploads[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section:Int) -> String? {
        return "Uploaded Bars"
    }
    
    func getPlaceData(url: String, parameters: [String: String], happyHours: [String: String], neighborhood: Neighborhood) {
        let header: HTTPHeaders = [
            "Authorization": "Bearer Mxkbvkgu6VYllYtDz5Oppicd1FiPg2G6QBj2yiKw3nUlIaB1BUCSHAThlEMb_vF4Np5iNpYjNLuC_clWi-2yXAo_WTLzabGmeoAaNHwehd2MTOZwyYRX5fu741WsWnYx"
        ]
        
        print("Pulling \(parameters["term"]!) from Yelp...")
        
        var json: JSON? {
            didSet {
                continueWriting(bar: json, happyHours: happyHours, neighborhood: neighborhood)
            }
        }
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: header).responseJSON { (response) in
            if response.result.isSuccess{
                json = JSON(response.result.value!)
            } else {
                print("Error \(String(describing: response.result.error))")
                
            }
        }
    }
    
    func upload(record: DatabaseRecord) {
        let barToUpload = Database.database().reference()
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
        
        barToUpload.child("Verified").child(record.name).setValue(barRecord) { (error, reference) in
            if error != nil {
                print("Error in writing \(record.name) to DB! Here is the error:")
                print(error!)
                print("Attempting to continue...")
            } else {
                print("\(record.name) saved successfully to DB.")
                self.uploads.append(record.name)
            }
        }
    }
    
    func writeToDB() {
        SVProgressHUD.show()
        let file = Bundle.main.path(forResource: "records", ofType: "txt")
        var fileToString = ""
        do {
            fileToString = try String(contentsOfFile: file!, encoding: .utf8)
        } catch let error as NSError {
            print("Failed to read from text file")
            print(error)
        }
        
        var stringArray: [String] = []
        fileToString.enumerateLines { line, _  in
            stringArray.append(line)
        }
        
        var happyHours: [String: String] = [:]
        var neighborhood: Neighborhood = .unknown
        var name: String = ""
        var count: Int = 0
        while !stringArray.isEmpty {
            if count == 0 {
                name = stringArray[0]
                count += 1
                stringArray.remove(at: 0)
            } else if count == 1 {
                if let isValidHood = Neighborhood(rawValue: stringArray[0]) {
                    neighborhood = isValidHood
                }
                count += 1
                stringArray.remove(at: 0)
            } else {
                if stringArray[0].lowercased() == "end of record" {
                    let url = "https://api.yelp.com/v3/businesses/search"
                    let parameters: [String: String] = [
                        "term": "\(name)",
                        "location": "San Diego",
                        "limit": "1"
                    ]
                    getPlaceData(url: url, parameters: parameters, happyHours: happyHours, neighborhood: neighborhood)
                    sleep(1)
                    neighborhood = .unknown
                    count = 0
                    stringArray.remove(at: 0)
                    happyHours = [:]
                } else {
                    let day = stringArray[0]
                    let time = stringArray[1]
                    stringArray.remove(at: 0)
                    stringArray.remove(at: 0)
                    happyHours[day] = time
                }
            }
        }
        
    }
    
    func continueWriting(bar: JSON?, happyHours: [String: String], neighborhood: Neighborhood) {
        guard let bar = bar else { return }
        
        let id = bar["businesses"].arrayValue.map({$0["id"].stringValue})[0]
        let name = bar["businesses"].arrayValue.map({$0["name"].stringValue})[0]
        let longitude = Double(bar["businesses"].arrayValue.map({$0["coordinates"]}).map({$0["longitude"].stringValue})[0])!
        let latitude = Double(bar["businesses"].arrayValue.map({$0["coordinates"]}).map({$0["latitude"].stringValue})[0])!
        let rating = Double(bar["businesses"].arrayValue.map({$0["rating"].stringValue})[0])!
        let price = bar["businesses"].arrayValue.map({$0["price"].stringValue})[0]
        let reviewCount = Int(bar["businesses"].arrayValue.map({$0["review_count"].stringValue})[0])!
        let phoneNumber = bar["businesses"].arrayValue.map({$0["display_phone"].stringValue})[0]
        
        let addressLine1 = bar["businesses"].arrayValue.map({$0["location"]}).map({$0["address1"].stringValue})[0]
        let addressLine2 = bar["businesses"].arrayValue.map({$0["location"]}).map({$0["address2"].stringValue})[0]
        let addressLine3 = bar["businesses"].arrayValue.map({$0["location"]}).map({$0["address3"].stringValue})[0]
        let city = bar["businesses"].arrayValue.map({$0["location"]}).map({$0["city"].stringValue})[0]
        let state = bar["businesses"].arrayValue.map({$0["location"]}).map({$0["state"].stringValue})[0]
        let zipCode = bar["businesses"].arrayValue.map({$0["location"]}).map({$0["zip_code"].stringValue})[0]
        let country = bar["businesses"].arrayValue.map({$0["location"]}).map({$0["country"].stringValue})[0]
        
        let categoriesJSON = bar["businesses"].arrayValue.map({$0["categories"]})[0]
        var categories = [BarType]()
        for category in categoriesJSON {
            let rawValue = category.1["alias"].rawString()!
            if let enumValue = BarType(rawValue: rawValue) {
                categories.append(enumValue)
            }
        }
        
        var images = [String]()
        images.append(bar["businesses"].arrayValue.map({$0["image_url"].stringValue})[0])
        
        let newDBRecord = DatabaseRecord(id: id, name: name, longitude: longitude, latitude: latitude, rating: rating, price: price, reviewCount: reviewCount, phoneNumber: phoneNumber, addressLine1: addressLine1, addressLine2: addressLine2, addressLine3: addressLine3, city: city, state: state, zipCode: zipCode, country: country, images: images, categories: categories, happyHours: happyHours, neighborhood: neighborhood)
        
        upload(record: newDBRecord)
    }

}

struct DatabaseRecord {
    var id: String
    var name: String
    var longitude: Double
    var latitude: Double
    var rating: Double
    var price: String
    var reviewCount: Int
    var phoneNumber: String
    
    // address info
    var addressLine1: String
    var addressLine2: String    // might be ""
    var addressLine3: String    // might be ""
    var address: String {
        if addressLine2 == "" {
            return addressLine1
        } else if addressLine3 == "" {
            return
            """
            \(addressLine1)
            \(addressLine2)
            """
        } else {
            return
            """
            \(addressLine1)
            \(addressLine2)
            \(addressLine3)
            """
        }
    }
    var city: String
    var state: String
    var zipCode: String
    var country: String
    
    var images: [String]        // could be empty
    var categories: [BarType]   // could be .unknown
    
    var happyHours: [String: String]
    var neighborhood: Neighborhood
    
    init(id: String, name: String, longitude: Double, latitude: Double, rating: Double, price: String, reviewCount: Int, phoneNumber: String, address: String, city: String, state: String, zipCode: String, country: String, images: [String], categories: [BarType], happyHours: [String: String], neighborhood: Neighborhood) {
        
        var addressLines = [String]()
        address.enumerateLines { (line, _) in
            addressLines.append(line)
        }
        
        var addressLine1, addressLine2, addressLine3: String
        switch addressLines.count {
        case 1:
            addressLine1 = addressLines[0]
            addressLine2 = ""
            addressLine3 = ""
        case 2:
            addressLine1 = addressLines[0]
            addressLine2 = addressLines[1]
            addressLine3 = ""
        default:
            addressLine1 = addressLines[0]
            addressLine2 = addressLines[1]
            addressLine3 = addressLines[2]
        }
        
        self = DatabaseRecord(id: id, name: name, longitude: longitude, latitude: latitude, rating: rating, price: price, reviewCount: reviewCount, phoneNumber: phoneNumber, addressLine1: addressLine1, addressLine2: addressLine2, addressLine3: addressLine3, city: city, state: state, zipCode: zipCode, country: country, images: images, categories: categories, happyHours: happyHours, neighborhood: neighborhood)
        
    }
    
    init(id: String, name: String, longitude: Double, latitude: Double, rating: Double, price: String, reviewCount: Int, phoneNumber: String, addressLine1: String, addressLine2: String, addressLine3: String, city: String, state: String, zipCode: String, country: String, images: [String], categories: [BarType], happyHours: [String: String], neighborhood: Neighborhood) {
        self.id = id
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
        self.rating = rating
        self.price = price
        self.reviewCount = reviewCount
        self.phoneNumber = phoneNumber
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.addressLine3 = addressLine3
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
        self.images = images
        self.categories = categories
        self.happyHours = happyHours
        self.neighborhood = neighborhood
    }
}
