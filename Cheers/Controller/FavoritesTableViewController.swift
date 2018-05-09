//
//  FavoritesTableViewController.swift
//  Cheers
//
//  Created by Maia Thomas on 4/17/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController {

    @IBOutlet var favoritesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoritesTableView.dataSource = self
        favoritesTableView.delegate = self
        favoritesTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
//        if let attempt = Place.loadFromFile()
//        {
//            favorites = attempt
//        } else {
//            print("Error: Could not read persisted list from file")
//        }
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoritesSingleton.shared.favorites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bar", for: indexPath) as! BarTableViewCell
        
        var bar = FavoritesSingleton.shared.favorites[indexPath.row]
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showSelectedFromFavorites", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSelectedFromFavorites" {
            let destination = segue.destination as! SelectedPlaceViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedPlace = FavoritesSingleton.shared.favorites[indexPath.row]
            destination.place = selectedPlace
            destination.sender = "Favorites"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.favoritesTableView.reloadData()
        
//        if FavoritesSingleton.shared.favorites.count == 0 {
//
//            let label : UILabel = {
//               let lab = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 35))
//                lab.text = "No Favorites"
//                return lab
//            }()
//
//            view.addSubview(label)
//            label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100)
//            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100)
//            label.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 150)
//
//        }
    }
    
    @IBAction func unwindToFavorites(segue: UIStoryboardSegue) {
        
    }
    
}
