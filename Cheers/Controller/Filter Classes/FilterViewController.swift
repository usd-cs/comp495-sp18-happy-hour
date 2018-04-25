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
    
    
    let masterList = SharedListsSingleton.shared.masterList
    var liveList = SharedListsSingleton.shared.liveList
    var notLiveList = SharedListsSingleton.shared.notLiveList
    
    var filtredMasterList = [Place]()
    
    @IBAction func distanceFilter(_ sender: Any) {
        distanceLabel.text = "Maximum Distance: \(distanceSlider.value)"
        distanceLabel.reloadInputViews()
        //filtredMasterList = masterList.filter {$0.record.}
        
    }
    
    @IBAction func ratingsFilter(_ sender: Any) {
        filtredMasterList = masterList.filter {$0.record.rating >= Double(ratingsSegementedControl.selectedSegmentIndex + 1)}
        
        print(filtredMasterList)
    }
    
    @IBAction func priceFilter(_ sender: Any) {
        filtredMasterList = masterList.filter {Int($0.record.price.count) <= Int(priceSegementedControl.selectedSegmentIndex + 1)}
        SharedListsSingleton.shared.masterList = filtredMasterList
    }
    
    @IBAction func favoritesOnly(_ sender: Any) {
        
        if favSegementedControl.selectedSegmentIndex == 1 {
            filtredMasterList = masterList.filter {$0.favorited}
        }
        
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
