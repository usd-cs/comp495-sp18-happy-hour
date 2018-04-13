//
//  SelectedBarViewController.swift
//  Cheers
//
//  Created by Maeve McClatchey on 3/12/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import SwiftDate

class SelectedBarViewController: UIViewController {
    
    var place: Place!
    // TODO: update image from ListViewController
    //var image: UIImage?
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var menuLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = place.record.name
        
        let current = Date()
        imageView.image = UIImage(named: "shout.jpg")
        nameLabel.text  = place.record.name
        addressLabel.text = place.record.address
        timeLabel.text = "Happy Hour: \(place.record.happyHours[current.weekdayName] ?? "no happy hours today")"
        ratingLabel.text = "Rating: \(String(place.record.rating))/5"
        
        // TODO: need to figure out how to show menu information
        menuLabel.text = "Featured Drinks: Moscow Mules!"
        
        if place.favorited {
            favoriteButton.setImage(#imageLiteral(resourceName: "icon-HeartFull"), for: UIControlState.normal)
        }
        else if place.favorited == false {
            favoriteButton.setImage(#imageLiteral(resourceName: "icon-HeartEmpty"), for: UIControlState.normal)
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        
        if place.favorited == true {
            place.favorited = false
            favoriteButton.setImage(#imageLiteral(resourceName: "icon-HeartEmpty"), for: UIControlState.normal)
        }
        else if place.favorited == false{
            place.favorited = true
            favoriteButton.setImage(#imageLiteral(resourceName: "icon-HeartFull"), for: UIControlState.normal)
            
            Place.saveToFile(favoritedPlace: place)

            //print(Place.loadFromFile() ?? "No Places Favorited in File\n")
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

