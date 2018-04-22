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
        
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.isContinuous = true
        slider.value = 100
        slider.addTarget(self, action: #selector(sliderValueDidChange) , for: UIControlEvents.valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isUserInteractionEnabled = true
        
        return slider
    }()
    
    @objc func sliderValueDidChange(sender:UISlider!)
    {
        print("value--\(sender.value)")
    }
    
    override init(frame: CGRect) {
        super.init(frame:  frame)
//        self.addSubview(titleLabel)
//

        let stackView = UIStackView(arrangedSubviews: [titleLabel,slideItem])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        

        
        
        
        self.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 100)
        stackView.isUserInteractionEnabled = true
        
        
        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        
        slideItem.frame = CGRect(x: 0, y: 50, width: frame.width, height: 25)
        slideItem.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        slideItem.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 30).isActive = true
        

        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
