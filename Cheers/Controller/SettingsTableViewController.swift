//
//  SettingsTableViewController.swift
//  Cheers
//
//  Created by Will Carhart on 4/17/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSegmentedControl: UISegmentedControl!
    
    let distanceSegmentedControlIndexPath = IndexPath(row: 1, section: 1)
    
    var showSegmentedControl: Bool = false {
        didSet {
            distanceSegmentedControl.isHidden = !showSegmentedControl
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        distanceLabel.text = "mi"
        updateSegmentedControl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (distanceSegmentedControlIndexPath.section, distanceSegmentedControlIndexPath.row):
            if showSegmentedControl {
                return 44.0
            } else {
                return 0.0
            }
        default:
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (distanceSegmentedControlIndexPath.section, distanceSegmentedControlIndexPath.row - 1):
            if showSegmentedControl {
                showSegmentedControl = false
            } else {
                showSegmentedControl = true
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        default:
            showSegmentedControl = false
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    func updateSegmentedControl() {
        // TODO: need to pass to rest of application
        if distanceSegmentedControl.selectedSegmentIndex == 0 {
            distanceLabel.text = "mi"
            SettingsSingleton.shared.useMiles = true
        } else if distanceSegmentedControl.selectedSegmentIndex == 1 {
            distanceLabel.text = "km"
            SettingsSingleton.shared.useMiles = false
        }
    }
    
    @IBAction func distanceSegmentedControlTapped(_ sender: UISegmentedControl) {
        updateSegmentedControl()
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */


}
