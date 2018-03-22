//
//  FirstViewController.swift
//  Cheers
//
//  Created by Will on 3/6/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import Firebase

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var places: [Place] = []
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bar", for: indexPath) as! BarTableViewCell
        
        let bar = places[indexPath.row]
        

        cell.barImage.image = UIImage(named : "shout.jpg")
        cell.barImage.alpha = 0.90
        
        cell.nameLabel.text = bar.name
        cell.nameLabel.textColor = UIColor.white
        
        cell.distanceLabel.text = "0.5 mi"
        cell.distanceLabel.textColor = UIColor.white
        
        cell.ratingsLabel.text = "+ + + +"
        cell.ratingsLabel.textColor = UIColor.white
        
        cell.happyHourLabel.text = "5 - 7pm"
        cell.happyHourLabel.textColor = UIColor.white
        
        cell.priceLabel.text = String(bar.priciness)
        cell.priceLabel.textColor = UIColor.white
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.delegate = self
        places = Place.readFromTextFile()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.performSegue(withIdentifier: "showSelected", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSelected"{
            let selectedVC = segue.destination as! SelectedBarViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedPlace = places[indexPath.row]
            selectedVC.place = selectedPlace
        }
    }

}

