//
//  BarTableViewCell.swift
//  Cheers
//
//  Created by Meelad Dawood on 3/8/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit

class BarTableViewCell: UITableViewCell {

    @IBOutlet var barImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var ratingsLabel: UILabel!
    @IBOutlet var happyHourLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
