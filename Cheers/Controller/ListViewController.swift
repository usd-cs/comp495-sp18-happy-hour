//
//  FirstViewController.swift
//  Cheers
//
//  Created by Will on 3/6/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import SwiftDate

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var isSearching = false
    var refHandle: DatabaseHandle?
    
    var places: [Place] = []
    var searchedData: [Place] = []
    
    // used to pull info from AppDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var masterList: [Place]? {
        didSet {
            liveList = []
            notLiveList = []
            filterList()
        }
    }
    var liveList: [Place]? {
        didSet {
            guard notLiveList != nil else { return }
            tableView.reloadData()
        }
    }
    var notLiveList: [Place]? {
        didSet {
            guard notLiveList != nil else { return }
            if notLiveList!.count != 0 {
                print("places is ready")
                places = notLiveList!
                tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done
        
        SVProgressHUD.show()
        
        // TODO: make work with async call to CoreLocations
        // TODO: need to make 'forNeighborhood' not static
        
        // DEBUG: when writing to DB, comment out this line
        // DEBUG: when reading from DB, uncomment this line
        readFromDB(fromNeighborhood: "Pacific Beach")
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return searchedData.count
        }
        
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bar", for: indexPath) as! BarTableViewCell
        
        if isSearching {
            
            var bar = searchedData[indexPath.row]
            
            let imageUrl =  URL(string: bar.record.images.removeFirst())
            
            ImageLoader.shared.getImageFromURL(for: imageUrl!) { image in
                cell.barImage.image = image
            }
            
            cell.barImage.alpha = 0.90
            cell.nameLabel.text = bar.record.name
            cell.distanceLabel.text = "0.5 mi"
            cell.ratingsLabel.text = "+ + + +"
            cell.happyHourLabel.text = "5 - 7pm"
            cell.priceLabel.text = String(bar.record.price)
            
            return cell
            
            
        } else {
            var bar = places[indexPath.row]
            
            let imageUrl =  URL(string: bar.record.images.removeFirst())
            
            ImageLoader.shared.getImageFromURL(for: imageUrl!) { image in
                cell.barImage.image = image
            }
            
            cell.barImage.alpha = 0.90
            
            cell.nameLabel.text = bar.record.name
            cell.nameLabel.textColor = UIColor.white
            
            cell.distanceLabel.text = "0.5 mi"
            cell.distanceLabel.textColor = UIColor.white
            
            cell.ratingsLabel.text = "+ + + +"
            cell.ratingsLabel.textColor = UIColor.white
            
            cell.happyHourLabel.text = "5 - 7pm"
            cell.happyHourLabel.textColor = UIColor.white
            
            cell.priceLabel.text = String(bar.record.price)
            cell.priceLabel.textColor = UIColor.white
            
        
        }
        return cell
    }
    
    
    // MARK: - Search Functions
    
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        
        if searchBar.isHidden {
            searchBar.isHidden = false
        } else {
            searchBar.isHidden = true
        }
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == nil || searchText == ""{
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            isSearching = true
            //searchedData = places.filter({$0.record.name.lowercased() == searchBar.text?.lowercased()})
            searchedData = places.filter({$0.record.name.lowercased().contains(searchBar.text!.lowercased())})
            tableView.reloadData()
        }
    }
    
    
    // MARK: - Database Functions
    
    func filterList() {
        let current = Date()
        let currentDate = DateInRegion(absoluteDate: current)
        
        for bar in masterList! {
            if let happyHourString = bar.record.happyHours["\(current.weekdayName)"] {
                
                let (dayOffset, startTimeHours, startTimeMinutes, endTimeHours, endTimeMinutes): (Int, String, String, String, String) = computeTimes(for: happyHourString)
                
                var startingDate = DateComponents()
                startingDate.year = currentDate.year
                startingDate.timeZone = TimeZoneName.americaLosAngeles.timeZone
                startingDate.calendar = CalendarName.gregorian.calendar
                startingDate.month = currentDate.month
                startingDate.day = currentDate.day
                startingDate.hour = Int(startTimeHours)!
                startingDate.minute = Int(startTimeMinutes)
                let happyHourStartingDate = DateInRegion(components: startingDate)
                
                var endingDate = DateComponents()
                endingDate.year = currentDate.year
                endingDate.timeZone = TimeZoneName.americaLosAngeles.timeZone
                endingDate.calendar = CalendarName.gregorian.calendar
                endingDate.month = currentDate.month
                endingDate.day = currentDate.day + dayOffset
                endingDate.hour = Int(endTimeHours)!
                endingDate.minute = Int(endTimeMinutes)
                let happyHourEndingDate = DateInRegion(components: endingDate)
                
                if currentDate > happyHourStartingDate! && currentDate < happyHourEndingDate! {
                    liveList!.append(bar)
                    
                    // DEBUG:
                    print("\tAdding \(bar.record.name) to live list")
                } else {
                    notLiveList!.append(bar)
                    
                    // DEBUG:
                    print("\tAdding \(bar.record.name) to not live list")
                }
                
            } else {
                notLiveList!.append(bar)
                print("\tAdding \(bar.record.name) to not live list")
            }
        }
        
        SVProgressHUD.dismiss()
    }
    
    func computeTimes(for happyHourString: String) -> (Int, String, String, String, String) {
        let components = happyHourString.components(separatedBy: " ")
        var dayOffset = 0
        var startInMorning: Bool = true
        var startTimeHours: Int
        var startTimeMinutes: Int
        var endTimeHours: Int
        var endTimeMinutes: Int
        guard components.count == 5 else {
            print("ERROR: incompatible time")
            return (0, "", "", "", "")
        }
        
        // compute starting time
        if components[0].contains(":") {
            let startComponents = components[0].components(separatedBy: ":")
            startTimeHours = Int(startComponents[0])!
            startTimeMinutes = Int(startComponents[1])!
        } else {
            startTimeHours = Int(components[0])!
            startTimeMinutes = 0
        }
        
        if components[1] == "pm" || components[1] == "Pm" || components[1] == "PM" || components[1] == "pM" {
            startTimeHours += 12
            startInMorning = false
        }
        
        // compute ending time
        if components[1].contains(":") {
            let endComponents = components[1].components(separatedBy: ":")
            endTimeHours = Int(endComponents[0])!
            endTimeMinutes = Int(endComponents[1])!
        } else {
            //endTimeHours = Int(components[3])! //This is crashing so Meelad added the next line
            endTimeHours = 1
            endTimeMinutes = 0
        }
        
        if components[4] == "pm" || components[4] == "Pm" || components[4] == "PM" || components[4] == "pM" {
            endTimeHours += 12
        } else if components[4] == "am" || components[4] == "Am" || components[4] == "AM" || components[4] == "aM" {
            if !startInMorning {
                dayOffset += 1
            }
        }
        
        return (dayOffset, String(startTimeHours), String(startTimeMinutes), String(endTimeHours), String(endTimeMinutes))
    }
    
    func readFromDB(fromNeighborhood neighborhood: String) {
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
            
            self.masterList = places
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showSelected", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSelected" {
            let selectedVC = segue.destination as! SelectedBarViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedPlace = places[indexPath.row]
            selectedVC.place = selectedPlace
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    // MARK: - Start of View Function
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.isNavigationBarHidden = true
        self.searchBar.isHidden = true
    }

}

