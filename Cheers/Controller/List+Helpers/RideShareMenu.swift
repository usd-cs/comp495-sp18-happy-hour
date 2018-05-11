//
//  RideShareMenu.swift
//  Cheers
//
//  Created by Will Carhart on 5/9/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import ChameleonFramework

class RideShareMenu: UIView {
    
    @IBOutlet var contentView: UIView!
    
    // high-level view outlets
    @IBOutlet weak var uberView: UIView!
    @IBOutlet weak var lyftView: UIView!
    @IBOutlet weak var mapsView: UIView!
    @IBOutlet weak var cancelView: UIView!
    
    // non-programmatically created button outlets
    @IBOutlet weak var mapsButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RideShareMenu", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.lyftView.backgroundColor = FlatWhite()
        self.lyftView.layer.cornerRadius = 10
        self.mapsView.backgroundColor = FlatWhite()
        self.mapsView.layer.cornerRadius = 10
        self.cancelView.backgroundColor = FlatPowderBlueDark()
        self.cancelView.layer.cornerRadius = 10
        
        self.mapsButton.setTitleColor(FlatBlackDark(), for: .normal)
        self.cancelButton.setTitleColor(FlatBlackDark(), for: .normal)
    }

}
