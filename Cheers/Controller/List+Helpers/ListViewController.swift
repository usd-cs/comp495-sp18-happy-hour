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
import FirebaseDatabase
import ChameleonFramework

class ListViewController: UIViewController, UISearchBarDelegate, FilterMenuDelegate{
    
    var searchBar = UISearchBar()
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBarButton: UIBarButtonItem!
    @IBOutlet weak var filterBarButton: UIBarButtonItem!
    @IBOutlet var segmentedControlButton: UISegmentedControl!
    
    //Determines if we are in search mode or not
    var isSearching = false
    var filterMode = false
    var refHandle: DatabaseHandle?
    
    var showLive: Bool = true {
        didSet {
            tableView.reloadData()
        }
    }
    
    var places: [Place] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var searchedData: [Place] = []
    
    var emptyView: EmptyView!
    
    // used to pull info from AppDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tableView.backgroundColor = FlatWhiteDark()
        
        let xib = UINib(nibName: "PlaceTableViewCell", bundle: nil)
        self.tableView.register(xib, forCellReuseIdentifier: "PlaceCell")
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.searchBarStyle = UISearchBarStyle.minimal
        
        SVProgressHUD.show()
        
        readFromDB()
        tableView.reloadData()
        
        emptyView = EmptyView()
        self.view.addSubview(emptyView)
        emptyView.backgroundColor = FlatWhiteDark()
        
        DispatchQueue.main.async {
            self.emptyView.frame = self.tableView.frame
            self.emptyView.needsUpdateConstraints()
            self.emptyView.setNeedsLayout()
            self.emptyView.setNeedsDisplay()
        }
        
        emptyView.isHidden = true
        
        checkIfEmpty(SharedListsSingleton.shared.liveList.count == 0)
        
    }
    
    func checkIfEmpty(_ showLive: Bool) {
        
        if showLive {
            if SharedListsSingleton.shared.liveList.count == 0 {
                self.emptyView.isHidden = false
                self.tableView.isHidden = true
            } else {
                self.emptyView.isHidden = true
                self.tableView.isHidden = false
            }
        } else {
            self.emptyView.isHidden = true
            self.tableView.isHidden = false
        }
        
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
        navigationItem.titleView = segmentedControlButton
        segmentedControlButton.isHidden = false
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
            
            searchedData = showLive ? SharedListsSingleton.shared.liveList.filter({$0.record.name.lowercased().contains(searchBar.text!.lowercased())}) : SharedListsSingleton.shared.allList.filter({$0.record.name.lowercased().contains(searchBar.text!.lowercased())})
            tableView.reloadData()
        }
    }
    
    func updateParent() {
        tableView.reloadData()
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        FilterSettingsSingleton.filterMenu.delegate = self
        FilterSettingsSingleton.filterMenu.showFilterMenu()
    }
    
    func filterMore() {
        self.performSegue(withIdentifier: "filterPressed", sender: self)
    }
    
    @objc func handleDismiss() {
        
    }
    
    @IBAction func segmentedButtonChanged(_ sender: Any) {
        showLive = segmentedControlButton.selectedSegmentIndex == 0 ? true : false
        checkIfEmpty(showLive)
    }
    
    // MARK: - Database Functions
    
    func readFromDB() {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        var places = [Place]()
        
        refHandle = ref.observe(.value, with: { (snapshot) in
            let allRecords = snapshot.value as! [String: AnyObject]
            
            let verifiedRecords = allRecords["Verified"] as! [String: AnyObject]
            
            for record in verifiedRecords {
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
            }
            
            SharedListsSingleton.shared.masterList = places
            self.places = SharedListsSingleton.shared.liveList
            
            self.checkIfEmpty(SharedListsSingleton.shared.liveList.count == 0)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSelected" {
            guard let destination = segue.destination as? SelectedPlaceViewController else { return }
            let indexPath = tableView.indexPathForSelectedRow!
            if isSearching {
                destination.place = searchedData[indexPath.row]
            } else {
                destination.place = showLive ? SharedListsSingleton.shared.liveList[indexPath.row] : SharedListsSingleton.shared.allList[indexPath.row]
            }
            destination.sender = "List"
        }
        
        if segue.identifier == "filterPressed" {
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

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if searching is toggled then loaded results
        if isSearching {
            return searchedData.count
        }
        return showLive ? SharedListsSingleton.shared.liveList.count : SharedListsSingleton.shared.allList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceTableViewCell
        
        if isSearching {
            
            var bar = searchedData[indexPath.row]
            let imageUrl = URL(string: bar.record.images[0])
            
            ImageLoader.shared.getImageFromURL(for: imageUrl!) { image in
                cell.cellImageView.image = image
            }
            
            var detailString = ""
            
            let today = Date()
            let todaysDate = today.weekdayName
            let todaysHappyHours = bar.record.happyHours[todaysDate] ?? ""
            detailString += todaysHappyHours == "" ? "" : "\(todaysHappyHours)   |   "
            
            cell.cellNameLabel.text = bar.record.name
            let dist = calculateDistance(myLat: (UserLocations.shared.currentLocation?.coordinate.latitude)!, myLong: (UserLocations.shared.currentLocation?.coordinate.longitude)!, placeLat: bar.record.latitude, placeLong: bar.record.longitude)
            if SettingsSingleton.shared.useMiles {
                detailString += "\(dist) mi"
            } else {
                detailString += "\(dist) km"
            }
            
            cell.cellDetailLabel.text = detailString
            
            cell.cellStar0.isHidden = true
            cell.cellStar1.isHidden = true
            cell.cellStar2.isHidden = true
            cell.cellStar3.isHidden = true
            cell.cellStar4.isHidden = true
            
            switch Int(bar.record.rating) {
            case 0:
                break
            case 1:
                cell.cellStar0.isHidden = false
            case 2:
                cell.cellStar0.isHidden = false
                cell.cellStar1.isHidden = false
            case 3:
                cell.cellStar0.isHidden = false
                cell.cellStar1.isHidden = false
                cell.cellStar2.isHidden = false
            case 4:
                cell.cellStar0.isHidden = false
                cell.cellStar1.isHidden = false
                cell.cellStar2.isHidden = false
                cell.cellStar3.isHidden = false
            default:
                cell.cellStar0.isHidden = false
                cell.cellStar1.isHidden = false
                cell.cellStar2.isHidden = false
                cell.cellStar3.isHidden = false
                cell.cellStar4.isHidden = false
            }
            
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
            
        } else {
            var bar = showLive ? SharedListsSingleton.shared.liveList[indexPath.row] : SharedListsSingleton.shared.allList[indexPath.row]
            let imageUrl =  URL(string: bar.record.images[0])
            
            ImageLoader.shared.getImageFromURL(for: imageUrl!) { image in
                cell.cellImageView.image = image
            }
            
            var detailString = ""
            
            let today = Date()
            let todaysDate = today.weekdayName
            let todaysHappyHours = bar.record.happyHours[todaysDate] ?? ""
            detailString += todaysHappyHours == "" ? "" : "\(todaysHappyHours)   |   "
            
            cell.cellNameLabel.text = bar.record.name
            let dist = calculateDistance(myLat: (UserLocations.shared.currentLocation?.coordinate.latitude)!, myLong: (UserLocations.shared.currentLocation?.coordinate.longitude)!, placeLat: bar.record.latitude, placeLong: bar.record.longitude)
            if SettingsSingleton.shared.useMiles {
                detailString += "\(dist) mi"
            } else {
                detailString += "\(dist) km"
            }
            
            cell.cellDetailLabel.text = detailString
            
            cell.cellStar0.isHidden = true
            cell.cellStar1.isHidden = true
            cell.cellStar2.isHidden = true
            cell.cellStar3.isHidden = true
            cell.cellStar4.isHidden = true
            
            switch Int(bar.record.rating) {
            case 0:
                break
            case 1:
                cell.cellStar0.isHidden = false
            case 2:
                cell.cellStar0.isHidden = false
                cell.cellStar1.isHidden = false
            case 3:
                cell.cellStar0.isHidden = false
                cell.cellStar1.isHidden = false
                cell.cellStar2.isHidden = false
            case 4:
                cell.cellStar0.isHidden = false
                cell.cellStar1.isHidden = false
                cell.cellStar2.isHidden = false
                cell.cellStar3.isHidden = false
            default:
                cell.cellStar0.isHidden = false
                cell.cellStar1.isHidden = false
                cell.cellStar2.isHidden = false
                cell.cellStar3.isHidden = false
                cell.cellStar4.isHidden = false
            }
            
        }
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 215.0
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showSelected", sender: self)
    }
}

