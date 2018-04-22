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
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let slideItem: UISlider = {
        let slider = UISlider()
        
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.isContinuous = true
        slider.value = 100
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isUserInteractionEnabled = true
        slider.contentMode = .scaleToFill
        slider.addTarget(self, action: #selector(sliderValueDidChange), for: UIControlEvents.valueChanged)
        
        return slider
    }()
    
    @objc func sliderValueDidChange(sender:UISlider!)
    {
        print("value--\(sender.value)")
    }
    
    override init(frame: CGRect) {
        super.init(frame:  frame)
        setUpViews()
       
        

    }
    
    func setUpViews() {
        
        let blueView : UIView = {
            let b = UIView()
            //frame: CGRect(x: 0, y: 0, width: frame.width, height: 50)
            b.backgroundColor = UIColor.blue
            b.translatesAutoresizingMaskIntoConstraints = false
            return b
        }()
        
        let redView : UIView = {
            let r = UIView()
            //frame: CGRect(x: 0, y: 0, width: frame.width, height: 50)
            r.backgroundColor = UIColor.red
            r.translatesAutoresizingMaskIntoConstraints = false
            return r
        }()
        
        let stackView: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [titleLabel,slideItem])
            stack.distribution = .fillEqually
            stack.axis = .vertical
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: self.topAnchor),
                                     stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                                     stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                                     stackView.heightAnchor.constraint(equalToConstant: 100)
            
            ])
        
        //Works Perfectly
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
