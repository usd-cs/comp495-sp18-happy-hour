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
    func annotationTapped(withTitle title: String)
}

class PlaceMapAnnotationView: UIView, CalloutViewPlus {
    
    weak var delegate: PlaceMapAnnotationViewModelDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var barImage: UIImageView!
    @IBOutlet weak var happyHoursLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func annotationTapped(_ sender: Any) {
        print("button pressed")
        delegate?.annotationTapped(withTitle: titleLabel.text!)
    }
    
    func configureCallout(_ viewModel: CalloutViewModel) {
        let viewModel = viewModel as! PlaceMapAnnotationViewModel
        
        titleLabel.text = viewModel.name
        barImage.image = viewModel.image
        happyHoursLabel.text = viewModel.happyHours
        
        
    }
}
