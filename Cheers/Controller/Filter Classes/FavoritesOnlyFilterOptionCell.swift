//
//  FavoritesOnlyFilterOptionCell.swift
//  Cheers
//
//  Created by Meelad Dawood on 4/22/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit

class FavoritesOnlyFilterOptionCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Favorites Only"
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ratingsSegementedControl: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["No","Yes"])
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.selectedSegmentIndex = 0
        return seg
    }()
    
    @objc func segmenetSelected(sender: UISegmentedControl!) {
        if sender.selectedSegmentIndex == 0 {
            FilterSettingsSingleton.shared.favorited = false
        } else {
            FilterSettingsSingleton.shared.favorited = true
        }
        SharedListsSingleton.shared.filterWithSettings()
    }
    
    override init(frame: CGRect) {
        super.init(frame:  frame)
        setUpViews()
        ratingsSegementedControl.addTarget(self, action: #selector(segmenetSelected), for: UIControlEvents.valueChanged)
        
    }
    
    func setUpViews() {
        
        let stackView: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [titleLabel,ratingsSegementedControl])
            stack.distribution = .fillEqually
            stack.axis = .vertical
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: self.topAnchor),
                                     stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
                                     stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
                                     stackView.heightAnchor.constraint(equalToConstant: 50)
            
            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
