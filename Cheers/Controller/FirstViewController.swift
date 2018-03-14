//
//  FirstViewController.swift
//  Cheers
//
//  Created by Will on 3/6/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    let arr = ["House"]
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bar", for: indexPath) as! BarTableViewCell
        
        cell.barImage.image = UIImage(named : "shout.jpg")
        cell.barImage.alpha = 0.90
        
        cell.nameLabel.text = "The Shout House"
        cell.nameLabel.textColor = UIColor.white
        
        cell.distanceLabel.text = "0.5 mi"
        cell.distanceLabel.textColor = UIColor.white
        
        cell.ratingsLabel.text = "+ + + +"
        cell.ratingsLabel.textColor = UIColor.white
        
        cell.happyHourLabel.text = "5 - 7pm"
        cell.happyHourLabel.textColor = UIColor.white
        
        cell.priceLabel.text = "$$$"
        cell.priceLabel.textColor = UIColor.white
        //print("Got here")
        
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.delegate = self
        
        //Place.readFromTextFile()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

