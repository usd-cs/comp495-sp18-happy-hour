//
//  AddHappyHourViewController.swift
//  Cheers
//
//  Created by Maia Thomas on 5/8/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import SwiftDate
import ChameleonFramework

class AddHappyHourViewController: UIViewController {
    
    var place: Place!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dayTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "unwindCancel", sender: nil)
    }
    

    let colors:[UIColor] = [
        UIColor.flatSand,
        UIColor.flatWhite,
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageUrl =  URL(string: place.record.images[0])
        
        ImageLoader.shared.getImageFromURL(for: imageUrl!) { image in
            self.imageView.image = image
        }
        imageView.contentMode = .scaleAspectFill
        
        nameLabel.text  = place.record.name
        nameLabel.sizeToFit()
        
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: colors)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TO DO: if save button is pushed
    
}

