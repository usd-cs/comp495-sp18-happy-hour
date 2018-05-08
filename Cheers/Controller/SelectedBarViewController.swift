//
//  SelectedBarViewController.swift
//  Cheers
//
//  Created by Maeve McClatchey on 3/12/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import SwiftDate
import ChameleonFramework

class SelectedBarViewController: UIViewController {
    
    var place: Place!
    var senderString: String!
    // TODO: update image from ListViewController
    //var image: UIImage?
    
    @IBAction func AddHappyHour(_ sender: UIBarButtonItem) {
    }
    
    let colors:[UIColor] = [
        UIColor.flatSand,
        UIColor.flatWhite,
    ]
    
    
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
        HistoryQueue.shared.append(place)
        navigationItem.title = place.record.name
        
        let current = Date()
        
        let imageUrl =  URL(string: place.record.images[0])
        
        ImageLoader.shared.getImageFromURL(for: imageUrl!) { image in
            self.imageView.image = image
        }
        imageView.contentMode = .scaleAspectFill
        
        
        nameLabel.text  = place.record.name
        nameLabel.sizeToFit()
        addressLabel.text = place.record.address
        addressLabel.sizeToFit()
        timeLabel.text = "Happy Hour: \(place.record.happyHours[current.weekdayName] ?? "no happy hours today")"
        timeLabel.sizeToFit()
        ratingLabel.text = "Rating: " + String(repeating: "👍", count: Int(round(place.record.rating)))
        ratingLabel.sizeToFit()
        
        // TODO: need to figure out how to show menu information
        menuLabel.text = "Yelp Reviews"
        
        updateFavoriteButton()
        
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: colors)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteButton()
    }
    
    func updateFavoriteButton() {
        if FavoritesSingleton.shared.favorites.isEmpty {
            favoriteButton.setImage(#imageLiteral(resourceName: "favorites"), for: UIControlState.normal)
        } else {
            if FavoritesSingleton.shared.favorites.contains(place) {
                favoriteButton.setImage(#imageLiteral(resourceName: "favorites_selected"), for: UIControlState.normal)
            } else {
                favoriteButton.setImage(#imageLiteral(resourceName: "favorites"), for: UIControlState.normal)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        if FavoritesSingleton.shared.favorites.isEmpty {
            place.favorited = true
            favoriteButton.setImage(#imageLiteral(resourceName: "favorites_selected"), for: UIControlState.normal)
            print("Sending \(place.record.name) with value true")
            FavoritesSingleton.shared.update(place: place, isFavorited: true)
        } else {
            if FavoritesSingleton.shared.favorites.contains(place) {
                place.favorited = false
                favoriteButton.setImage(#imageLiteral(resourceName: "favorites"), for: UIControlState.normal)
                print("Sending \(place.record.name) with value false")
                FavoritesSingleton.shared.update(place: place, isFavorited: false)
            } else {
                place.favorited = true
                favoriteButton.setImage(#imageLiteral(resourceName: "favorites_selected"), for: UIControlState.normal)
                print("Sending \(place.record.name) with value true")
                FavoritesSingleton.shared.update(place: place, isFavorited: true)
            }
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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        if senderString == "List" {
            performSegue(withIdentifier: "barToList", sender: nil)
        } else if senderString == "Map" {
            performSegue(withIdentifier: "barToMap", sender: nil)
        } else if senderString == "Favorites" {
            performSegue(withIdentifier: "barToFavorites", sender: nil)
        }
    }
    
    @IBAction func unwindCancel(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "addHappyHour" else { return }
        
        guard let navigator = segue.destination as? UINavigationController
            else { return }
        let destination = navigator.viewControllers.first as! AddHappyHourViewController
        destination.place = self.place
    }
}

