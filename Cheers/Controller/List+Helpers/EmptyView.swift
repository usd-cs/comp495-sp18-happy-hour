//
//  EmptyView.swift
//  Cheers
//
//  Created by Will Carhart on 5/11/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit

class EmptyView: UIView {
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("EmptyView", owner: self, options: nil)
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
