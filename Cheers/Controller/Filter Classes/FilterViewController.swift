//
//  FilterViewController.swift
//  Cheers
//
//  Created by Meelad Dawood on 4/17/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var distanceSlider: UISlider!
    @IBOutlet var ratingsSegementedControl: UISegmentedControl!
    @IBOutlet var priceSegementedControl: UISegmentedControl!
    @IBOutlet var favSegementedControl: UISegmentedControl!
    
    
    @IBAction func distanceFilter(_ sender: Any) {
        distanceLabel.text = "Maximum Distance: \(distanceSlider.value)"
        distanceLabel.reloadInputViews()
    }
    
    @IBAction func ratingsFilter(_ sender: Any) {
    }
    
    @IBAction func priceFilter(_ sender: Any) {
    }
    
    @IBAction func favoritesOnly(_ sender: Any) {
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        distanceLabel.text = "Maximum Distance: 25"
        distanceSlider.value = distanceSlider.maximumValue
        ratingsSegementedControl.selectedSegmentIndex = 0
        priceSegementedControl.selectedSegmentIndex = 4
        favSegementedControl.selectedSegmentIndex = 0
        view.reloadInputViews()
    }
}
