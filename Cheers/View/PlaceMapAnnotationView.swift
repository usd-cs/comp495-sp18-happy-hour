//
//  PlaceMapAnnotationView.swift
//  Cheers
//
//  Created by Will on 4/4/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import MapViewPlus

public protocol PlaceMapAnnotationViewModelDelegate: class {
    func beginToTriggerSegue(for place: Place)
}

class PlaceMapAnnotationView: UIView, CalloutViewPlus {
    
    weak var delegate: PlaceMapAnnotationViewModelDelegate?
    
    var place: Place?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var barImage: UIImageView!
    @IBOutlet weak var happyHoursLabel: UILabel!
    @IBOutlet weak var favoritedIcon: UIButton!
    
    
    @IBAction func barSelected(_ sender: Any) {
        delegate!.beginToTriggerSegue(for: place!)
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        if FavoritesSingleton.shared.favorites.isEmpty {
            //place.favorited = true
            favoritedIcon.setImage(#imageLiteral(resourceName: "favorites_selected"), for: UIControlState.normal)
            print("Sending \(place?.record.name) with value true")
            FavoritesSingleton.shared.update(place: place!, isFavorited: true)
        } else {
            if FavoritesSingleton.shared.favorites.contains(place!) {
                //place.favorited = false
                favoritedIcon.setImage(#imageLiteral(resourceName: "favorites"), for: UIControlState.normal)
                print("Sending \(place?.record.name) with value false")
                FavoritesSingleton.shared.update(place: place!, isFavorited: false)
            } else {
                //place.favorited = true
                favoritedIcon.setImage(#imageLiteral(resourceName: "favorites_selected"), for: UIControlState.normal)
                print("Sending \(place?.record.name) with value true")
                FavoritesSingleton.shared.update(place: place!, isFavorited: true)
            }
        }
    }
    
    func configureCallout(_ viewModel: CalloutViewModel) {
        let viewModel = viewModel as! PlaceMapAnnotationViewModel
        
        titleLabel.text = viewModel.name
        happyHoursLabel.text = viewModel.happyHours
        place = viewModel.place
        
        let imageUrl =  URL(string: (place?.record.images[0])!)
        ImageLoader.shared.getImageFromURL(for: imageUrl!) { image in
            self.barImage.image = image
        }
        
        if FavoritesSingleton.shared.favorites.contains(place!) {
            favoritedIcon.setImage(#imageLiteral(resourceName: "favorites_selected"), for: UIControlState.normal)
        } else {
            favoritedIcon.setImage(#imageLiteral(resourceName: "favorites"), for: UIControlState.normal)
        }
    }
}
