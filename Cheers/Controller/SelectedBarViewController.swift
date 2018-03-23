//
//  SelectedBarViewController.swift
//  Cheers
//
//  Created by Maeve McClatchey on 3/12/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit

class SelectedBarViewController: UIViewController {
    
    var place: Place!
    
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
        //navigationItem.title = place.name
        
        // Do any additional setup after loading the view.
        /*
        imageView.image = UIImage(named: "shout.jpg")
        nameLabel.text  = place.name
        addressLabel.text = place.address
        timeLabel.text = "Happy Hour: 5:30pm - 7:30pm"
        ratingLabel.text = "Rating: \(String(place.averageUserRating))/5"
        menuLabel.text = "Featured Drinks: Moscow Mules!"
 */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        
        if place.favorited == true {
            place.favorited = false
        }
        else if place.favorited == false{
            place.favorited = true
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

