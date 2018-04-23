//
//  DistanceFilterOptionCell.swift
//  Cheers
//
//  Created by Meelad Dawood on 4/13/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit

class MinimumRatingFilterOptionCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Minimum Ratings"
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ratingsSegementedControl: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["1 Star","2 Stars","3 Stars","4 Stars","5 Stars"])
        seg.translatesAutoresizingMaskIntoConstraints = false
        
        return seg
    }()
    
    @objc func segmenetSelected(sender:UISegmentedControl!)
    {
        print("value--\(sender.selectedSegmentIndex)")
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
