//
//  FilterOptionCell.swift
//  Cheers
//
//  Created by Meelad Dawood on 4/13/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit

class FilterOptionCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Distance"
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let slideItem: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 25
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        return slider
    }()
    
    override init(frame: CGRect) {
        super.init(frame:  frame)
        self.addSubview(titleLabel)
        
        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 35)
        
        
        self.addSubview(slideItem)
        slideItem.topAnchor.constraint(equalTo: titleLabel.bottomAnchor ).isActive = true
        slideItem.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        slideItem.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        slideItem.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        slideItem.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        //slideItem.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
