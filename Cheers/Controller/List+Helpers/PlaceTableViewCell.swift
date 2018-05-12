//
//  PlaceTableViewCell.swift
//  Cheers
//
//  Created by Will Carhart on 5/11/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellNameLabel: UILabel!
    @IBOutlet weak var cellDetailLabel: UILabel!
    @IBOutlet weak var cellStar0: UIImageView!
    @IBOutlet weak var cellStar1: UIImageView!
    @IBOutlet weak var cellStar2: UIImageView!
    @IBOutlet weak var cellStar3: UIImageView!
    @IBOutlet weak var cellStar4: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
