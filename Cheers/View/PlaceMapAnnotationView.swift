//
//  PlaceMapAnnotationView.swift
//  Cheers
//
//  Created by Will on 4/4/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import MapViewPlus

class PlaceMapAnnotationView: UIView, CalloutViewPlus {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var barImage: UIImageView!
    @IBOutlet weak var happyHoursLabel: UILabel!
    
    func configureCallout(_ viewModel: CalloutViewModel) {
        let viewModel = viewModel as! PlaceMapAnnotationViewModel
        
        titleLabel.text = viewModel.name
        barImage.image = viewModel.image
        happyHoursLabel.text = viewModel.happyHours
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        
    }
}
