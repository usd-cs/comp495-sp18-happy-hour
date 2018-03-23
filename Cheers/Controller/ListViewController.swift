//
//  FirstViewController.swift
//  Cheers
//
//  Created by Will on 3/6/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import Firebase

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var tableView: UITableView!
    
    var places: [Place] = []
    
    //used to pull info from AppDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var liveList: [Place]? {
        didSet {
            
        }
    }
    var notLiveList: [Place]? {
        didSet {
            guard notLiveList != nil else { return }
            if notLiveList!.count != 0 {
                print("places is ready")
                places = notLiveList!
                tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bar", for: indexPath) as! BarTableViewCell
        let bar = places[indexPath.row]
        
        cell.barImage.image = UIImage(named : "shout.jpg")
        cell.barImage.alpha = 0.90
        
        cell.nameLabel.text = bar.record.name
        cell.nameLabel.textColor = UIColor.white
        
        cell.distanceLabel.text = "0.5 mi"
        cell.distanceLabel.textColor = UIColor.white
        
        cell.ratingsLabel.text = "+ + + +"
        cell.ratingsLabel.textColor = UIColor.white
        
        cell.happyHourLabel.text = "5 - 7pm"
        cell.happyHourLabel.textColor = UIColor.white
        
        cell.priceLabel.text = String(bar.record.price)
        cell.priceLabel.textColor = UIColor.white
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        liveList = appDelegate.liveList
        notLiveList = appDelegate.notLiveList
        
//        while true {
//            liveList = appDelegate.liveList
//            notLiveList = appDelegate.notLiveList
//            if notLiveList == nil {
//                continue
//            } else if notLiveList!.count != 0 {
//                break
//            }
//        }
        //places = liveList!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showSelected", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSelected" {
            let selectedVC = segue.destination as! SelectedBarViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedPlace = places[indexPath.row]
            selectedVC.place = selectedPlace
        }
    }

}

