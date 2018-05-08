//
//  AddHappyHourTableViewController.swift
//  Cheers
//
//  Created by Maia Thomas on 5/2/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//


import UIKit
import SwiftDate
import ChameleonFramework

class AddHappyHourTableViewController: UITableViewController {
    
    var place: Place!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBAction func dayTextField(_ sender: UITextField) {
    }
    
    @IBAction func timeTextField(_ sender: UITextField) {
    }
    
    let colors:[UIColor] = [
        UIColor.flatSand,
        UIColor.flatWhite,
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HistoryQueue.shared.append(place)

        let imageUrl =  URL(string: place.record.images[0])
        
        ImageLoader.shared.getImageFromURL(for: imageUrl!) { image in
            self.imageView.image = image
        }
        imageView.contentMode = .scaleAspectFill
        
        nameLabel.text  = place.record.name
        nameLabel.sizeToFit()
     
        
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: colors)
    }
    
    // TO DO: if cancel button is pushed
    @IBAction func unwindAddHappyHourSegue(segue: UIStoryboardSegue) {
        
    }
    
    // TO DO: if save button is pushed
    
    
}
