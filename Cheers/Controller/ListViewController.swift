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
    var filterMode = false
    var refHandle: DatabaseHandle?
    
    var showLive: Bool = true {
        didSet {
            tableView.reloadData()
            print("Number of items in masterList: \(SharedListsSingleton.shared.masterList.count)")
        }
    }
    
    var places: [Place] = [] {
        didSet {
            tableView.reloadData()
            print("Number of items in masterList: \(SharedListsSingleton.shared.masterList.count)")
        }
    }
    var searchedData: [Place] = []
    
    // used to pull info from AppDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.searchBarStyle = UISearchBarStyle.minimal
        
        SVProgressHUD.show()
        
        readFromDB()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if searching is toggled then loaded results
        if isSearching {
            return searchedData.count
        }
        return showLive ? SharedListsSingleton.shared.liveList.count : SharedListsSingleton.shared.notLiveList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bar", for: indexPath) as! BarTableViewCell
        
        if isSearching {
            
            var bar = searchedData[indexPath.row]
            let imageUrl = URL(string: bar.record.images[0])
            
            ImageLoader.shared.getImageFromURL(for: imageUrl!) { image in
                cell.barImage.image = image
            }
            
            cell.nameLabel.text = bar.record.name
            let dist = calculateDistance(myLat: (UserLocations.shared.currentLocation?.coordinate.latitude)!, myLong: (UserLocations.shared.currentLocation?.coordinate.longitude)!, placeLat: bar.record.latitude, placeLong: bar.record.longitude)
            if SettingsSingleton.shared.useMiles {
                cell.distanceLabel.text = "\(dist) mi"
            } else {
                cell.distanceLabel.text = "\(dist) km"
            }
            cell.ratingsLabel.text = String(repeating: "👍", count: Int(round(bar.record.rating)))
            let today = Date()
            let todaysDate = today.weekdayName
            let todaysHappyHours = bar.record.happyHours[todaysDate] ?? ""
            cell.happyHourLabel.text = todaysHappyHours
            cell.priceLabel.text = String(bar.record.price)
            
            return cell
            
        } else {
            var bar = showLive ? SharedListsSingleton.shared.liveList[indexPath.row] : SharedListsSingleton.shared.notLiveList[indexPath.row]
            //ar bar = places[indexPath.row]
            print(places)
            print("dequeing the boys", bar.record.name)
            let imageUrl =  URL(string: bar.record.images[0])
            
            ImageLoader.shared.getImageFromURL(for: imageUrl!) { image in
                cell.barImage.image = image
            }
            
            cell.nameLabel.text = bar.record.name
            let dist = calculateDistance(myLat: (UserLocations.shared.currentLocation?.coordinate.latitude)!, myLong: (UserLocations.shared.currentLocation?.coordinate.longitude)!, placeLat: bar.record.latitude, placeLong: bar.record.longitude)
            if SettingsSingleton.shared.useMiles {
                cell.distanceLabel.text = "\(dist) mi"
            } else {
                cell.distanceLabel.text = "\(dist) km"
            }
            cell.ratingsLabel.text = String(repeating: "👍", count: Int(round(bar.record.rating)))
            let today = Date()
            let todaysDate = today.weekdayName
            let todaysHappyHours = bar.record.happyHours[todaysDate] ?? ""
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
        var d: Double = radius * c
        
        if SettingsSingleton.shared.useMiles {
            d *= 0.621371
        }
        return String(format: "%.2f", d)
    }
    
    func toRadians(_ degrees: Double) -> Double {
        return degrees * (Double.pi / 180.0)
    }
    
    
    // MARK: - Search Functions
    
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        showSearchBar()
    }
    
    // displays the search bar and hides the bar buttons
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

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // TODO: when search bar hides, segmented control is no longer visible
        hideSearchBar()
    }
    
    // hides the search bar and bar button
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
        if searchText == "" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            // display searched results
            isSearching = true
            
            searchedData = showLive ? SharedListsSingleton.shared.liveList.filter({$0.record.name.lowercased().contains(searchBar.text!.lowercased())}) : SharedListsSingleton.shared.notLiveList.filter({$0.record.name.lowercased().contains(searchBar.text!.lowercased())})
            tableView.reloadData()
        }
    }
    
    let filterMenu = FilterMenu()
    @IBAction func filterButtonPressed(_ sender: Any) {
        // TODO: present filtering options
        //filterMore()
        filterMenu.showFilterMenu(tableView: tableView)
    }
    
    func filterMore() {
        self.performSegue(withIdentifier: "filterPressed", sender: self)
    }
    
    @objc func handleDismiss() {
        
    }
    
    @IBAction func segmentedButtonChanged(_ sender: Any) {
        showLive = segmentedControlButton.selectedSegmentIndex == 0 ? true : false
        print(showLive)
        
        /*
        
        if segmentedControlButton.selectedSegmentIndex == 0 {
            places = SharedListsSingleton.shared.liveList
            // TODO: do we need this here?
            //tableView.reloadData()
        } else {
            places = SharedListsSingleton.shared.notLiveList
            /*print("\n\nplaces is now:")
            for place in places {
                print(place.record.name)
            }
            
            print("\n\nsingleton masterList is now:")
            for place in SharedListsSingleton.shared.masterList {
                print(place.record.name)
            }
            */
            // TODO: do we need this here?
            //tableView.reloadData()
        }
        */
    }
    
    // MARK: - Database Functions
    
    func readFromDB() {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        var places = [Place]()
        
        refHandle = ref.observe(.value, with: { (snapshot) in
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
                
                let neighborhoodName = Neighborhood(rawValue: recordInfo["neighborhood"] as! String)!
                
                let newRecord = DatabaseRecord(id: id, name: name, longitude: longitude, latitude: latitude, rating: rating, price: price, reviewCount: reviewCount, phoneNumber: phoneNumber, address: address, city: city, state: state, zipCode: zipCode, country: country, images: images, categories: categories, happyHours: happyHours, neighborhood: neighborhoodName)
                
                places.append(Place(record: newRecord, favorited: false))
                //print("Appending \(newRecord.name) to local method places list")
            }
            
            SharedListsSingleton.shared.masterList = places
            self.places = SharedListsSingleton.shared.liveList
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showLive {
            HistoryQueue.shared.append(SharedListsSingleton.shared.liveList[indexPath.row])
        } else {
            HistoryQueue.shared.append(SharedListsSingleton.shared.notLiveList[indexPath.row])
        }
        self.performSegue(withIdentifier: "showSelected", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSelected" {
            let navigator = segue.destination as! UINavigationController
            let selectedVC = navigator.viewControllers.first as! SelectedBarViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedPlace = showLive ? SharedListsSingleton.shared.liveList[indexPath.row] : SharedListsSingleton.shared.notLiveList[indexPath.row]
            selectedVC.place = selectedPlace
            selectedVC.senderString = "List"
            self.navigationController?.isNavigationBarHidden = false
        }
        
        if segue.identifier == "filterPressed" {
            //let navigator = segue.destination as! UINavigationController
            //self.navigationController?.isNavigationBarHidden = false
            filterMode = true
            
        }
        
        
    }
    
    // MARK: - Start of View Function
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func unwindToList(segue: UIStoryboardSegue) {
        
    }

}

