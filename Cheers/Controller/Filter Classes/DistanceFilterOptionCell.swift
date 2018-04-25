//
//  DistanceFilterOptionCell.swift
//  Cheers
//
//  Created by Meelad Dawood on 4/13/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit

class DistanceFilterOptionCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Distance \(FilterSettingsSingleton.shared.distanceFromMe)"
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let slideItem: UISlider = {
        let slider = UISlider()
        
        slider.minimumValue = 0
        slider.maximumValue = 25
        slider.isContinuous = true
        slider.value = Float(FilterSettingsSingleton.shared.distanceFromMe)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isUserInteractionEnabled = true
        slider.contentMode = .scaleToFill
        
        slider.isUserInteractionEnabled = true
        
        return slider
    }()
    
    @objc func sliderValueDidChange(sender: UISlider!) {
        titleLabel.text = "Distance: \(sender.value.rounded())"
        FilterSettingsSingleton.shared.distanceFromMe = Double(sender.value.rounded())
        SharedListsSingleton.shared.filterWithSettings()
    }
    
    override init(frame: CGRect) {
        super.init(frame:  frame)
        setUpViews()
        slideItem.addTarget(self, action: #selector(sliderValueDidChange), for: UIControlEvents.valueChanged)
    }
    
    func setUpViews() {
        
        let stackView: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [titleLabel,slideItem])
            stack.distribution = .fillEqually
            stack.axis = .vertical
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: self.topAnchor),
                                     stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 5),
                                     stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant : -5),
                                     stackView.heightAnchor.constraint(equalToConstant: 50)
            
            ])
        
        
        
        //Trial Run Code == Works Perfectly
        
        //        let blueView : UIView = {
        //            let b = UIView()
        //            //frame: CGRect(x: 0, y: 0, width: frame.width, height: 50)
        //            b.backgroundColor = UIColor.blue
        //            b.translatesAutoresizingMaskIntoConstraints = false
        //            return b
        //        }()
        //
        //        let redView : UIView = {
        //            let r = UIView()
        //            //frame: CGRect(x: 0, y: 0, width: frame.width, height: 50)
        //            r.backgroundColor = UIColor.red
        //            r.translatesAutoresizingMaskIntoConstraints = false
        //            return r
        //        }()
        //        self.addSubview(blueView)
        //        self.addSubview(redView)
        //
        //        NSLayoutConstraint.activate([blueView.topAnchor.constraint(equalTo: self.topAnchor),
        //                                     blueView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        //                                     blueView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        //                                     blueView.heightAnchor.constraint(equalToConstant: 50)
        //            ])
        //
        //        NSLayoutConstraint.activate([redView.topAnchor.constraint(equalTo: blueView.bottomAnchor),
        //                                     redView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        //                                     redView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        //                                     redView.heightAnchor.constraint(equalToConstant: 50)
        //            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
