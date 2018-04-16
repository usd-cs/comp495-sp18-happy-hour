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
import Foundation

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBarButton: UIBarButtonItem!
    @IBOutlet weak var filterBarButton: UIBarButtonItem!
    @IBOutlet weak var segmentedControlButton: UISegmentedControl!
    
    var isSearching = false //Determines if we are in search mode or not
    var refHandle: DatabaseHandle?
    
    var places: [Place] = []
    var searchedData: [Place] = []
    
    // used to pull info from AppDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var masterList: [Place]? {
        didSet {
            liveList = []
            notLiveList = []
            SharedListsSingleton.shared.masterList = masterList!
            filterList()
        }
    }
    var liveList: [Place]? {
        didSet {
            guard notLiveList != nil else { return }
            tableView.reloadData()
            if liveList!.count != 0 {
                // DEBUG: 
                print("places is ready")
                places = liveList!
                tableView.reloadData()
            }
        }
    }
    var notLiveList: [Place]? {
        didSet {
            guard notLiveList != nil else { return }
            tableView.reloadData()
            
            // DEBUG: is this the right place to put this?
            SVProgressHUD.dismiss()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.searchBarStyle = UISearchBarStyle.minimal
        
        SVProgressHUD.show()
        
        // DEBUG: when writing to DB, comment out this line
        // DEBUG: when reading from DB, uncomment this line
        readFromDB()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if searching is toggled then loaded results
        if isSearching {
            return searchedData.count
        }
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bar", for: indexPath) as! BarTableViewCell
        
        if isSearching {
            
            var bar = searchedData[indexPath.row]
            let imageUrl =  URL(string: bar.record.images[0])
            
            ImageLoader.shared.getImageFromURL(for: imageUrl!) { image in
                cell.barImage.image = image
            }
            
            cell.nameLabel.text = bar.record.name
            let dist = calculateDistance(myLat: (UserLocations.shared.currentLocation?.coordinate.latitude)!, myLong: (UserLocations.shared.currentLocation?.coordinate.longitude)!, placeLat: bar.record.latitude, placeLong: bar.record.longitude)
            cell.distanceLabel.text = "\(dist) mi"
            cell.ratingsLabel.text = String(repeating: "👍", count: Int(round(bar.record.rating)))
            let today = Date()
            let todaysDate = today.weekdayName
            let todaysHappyHours = bar.record.happyHours[todaysDate] ?? ""
            cell.happyHourLabel.text = todaysHappyHours
            cell.priceLabel.text = String(bar.record.price)
            
            return cell
            
            
        } else {
            var bar = places[indexPath.row]
            let imageUrl =  URL(string: bar.record.images[0])
            
            ImageLoader.shared.getImageFromURL(for: imageUrl!) { image in
                cell.barImage.image = image
            }
            
            cell.nameLabel.text = bar.record.name
            let dist = calculateDistance(myLat: (UserLocations.shared.currentLocation?.coordinate.latitude)!, myLong: (UserLocations.shared.currentLocation?.coordinate.longitude)!, placeLat: bar.record.latitude, placeLong: bar.record.longitude)
            cell.distanceLabel.text = "\(dist) mi"
            cell.ratingsLabel.text = String(repeating: "👍", count: Int(round(bar.record.rating)))
            let today = Date()
            let todaysDate = today.weekdayName
            let todaysHappyHours = bar.record.happyHours[todaysDate] ?? "nil"
            cell.happyHourLabel.text = todaysHappyHours
            cell.priceLabel.text = String(bar.record.price)
            
        
        }
        return cell
    }
    
    func calculateDistance(myLat: Double, myLong: Double, placeLat: Double, placeLong: Double) -> String {
        let radius: Double = 6371.0
        let deltaLat: Double = toRadians(placeLat - myLat)
        let deltaLong: Double = toRadians(placeLong - myLong)
        
        let a: Double =
            sin(deltaLat / 2.0) * sin(deltaLat / 2.0) +
            cos(toRadians(myLat)) * cos(toRadians(placeLat)) *
            sin(deltaLong / 2.0) * sin(deltaLong / 2.0)
        
        let c: Double = 2.0 * atan2(sqrt(a), sqrt(1.0 - a))
        let d: Double = radius * c * 0.621371
        return String(format: "%.2f", d)
    }
    
    func toRadians(_ degrees: Double) -> Double {
        return degrees * (Double.pi / 180.0)
    }
    
    
    // MARK: - Search Functions
    
    //Action function when the search button is pressed
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        showSearchBar()
        
    }
    
    //Displays the search bar and hides the bar buttons
    func showSearchBar() {
        
        navigationItem.titleView = searchBar
        navigationItem.setRightBarButton(nil, animated: true)
        
        searchBar.isHidden =  false
        searchBar.alpha = 0
        searchBar.showsCancelButton = true

        UIView.animate(withDuration: 0.5, animations: {
            self.searchBar.alpha = 1
        }, completion: { finished in
            self.searchBar.becomeFirstResponder()
        })
    }
    
    //action function when the cancel button is pressed
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
        
        // TODO: when search bar hides, segmented control is no longer visible
    }
    
    //func that hides the search bar and bar button
    func hideSearchBar() {
        searchBar.isHidden =  true
        navigationItem.setRightBarButton(searchBarButton, animated: true)
        self.searchBar.resignFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
        }, completion: { finished in
            
        })
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // if nothing is entered then display the original
        if searchText == nil || searchText == "" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else { // display searched results
            isSearching = true
            searchedData = places.filter({$0.record.name.lowercased().contains(searchBar.text!.lowercased())})
            tableView.reloadData()
        }
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        // TODO: present filtering options
    }
    
    @IBAction func segmentedButtonChanged(_ sender: Any) {
        // TODO: switch between displaying live and all lists
        if segmentedControlButton.selectedSegmentIndex == 0 {
            // TODO: need to safely unwrap
            places = liveList!
            tableView.reloadData()
        } else {
            // TODO: need to safely unwrap
            places = notLiveList!
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
                    SharedListsSingleton.shared.liveList.append(bar)
                } else {
                    notLiveList!.append(bar)
                    SharedListsSingleton.shared.notLiveList.append(bar)
                }
                
            } else {
                notLiveList!.append(bar)
                SharedListsSingleton.shared.notLiveList.append(bar)
            }
        }
        
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
        if components[3].contains(":") {
            let endComponents = components[3].components(separatedBy: ":")
            endTimeHours = Int(endComponents[0])!
            endTimeMinutes = Int(endComponents[1])!
        } else {
            //endTimeHours = Int(components[3])!
            // TODO: fix this
            //This is crashing so Meelad added the next line
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
    
    func readFromDB() {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        var places = [Place]()
        
        refHandle = ref.observe(.value, with: { (snapshot) in
            let allRecords = snapshot.value as? [String: AnyObject]
            for neighborhoodRecords in allRecords! {
                let records = neighborhoodRecords.value as? [String: AnyObject]
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
                    
                    // build list of categories, could be empty (defaults to unknown)
                    var categoriesArray = [String]()
                    if recordInfo["categories"] != nil {
                        categoriesArray = recordInfo["categories"] as! [String]
                    } else {
                        categoriesArray.append("unknown")
                    }
                    var categories = [BarType]()
                    for category in categoriesArray {
                        categories.append(BarType(rawValue: category)!)
                    }
                    
                    let happyHours = recordInfo["happyHours"] as! [String: String]
                    
                    let neighborhoodName = Neighborhood(rawValue: neighborhoodRecords.key)!
                    
                    let newRecord = DatabaseRecord(id: id, name: name, longitude: longitude, latitude: latitude, rating: rating, price: price, reviewCount: reviewCount, phoneNumber: phoneNumber, address: address, city: city, state: state, zipCode: zipCode, country: country, images: images, categories: categories, happyHours: happyHours, neighborhood: neighborhoodName)
                    
                    places.append(Place(record: newRecord, favorited: false))
                    
                }
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
            //selectedVC.image = 
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    // MARK: - Start of View Function
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.isNavigationBarHidden = true
        //self.searchBar.isHidden = true
    }

}

