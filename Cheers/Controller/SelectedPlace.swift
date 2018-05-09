//
//  SelectedPlace.swift
//  Cheers
//
//  Created by Will Carhart on 5/9/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import ChameleonFramework

class SelectedPlace: UIView {
    // top-level view
    @IBOutlet var view: UIView!
    
    // high-level view outlets
    @IBOutlet weak var imageView: UIView!           // I
    @IBOutlet weak var detailsView: UIView!         // II
    @IBOutlet weak var categoriesView: UIView!      // III
    @IBOutlet weak var reviewView: UIView!          // IV
    @IBOutlet weak var mapView: UIView!             // V
    @IBOutlet weak var aboutView: UIView!           // VI
    
    // View I (image) outlets
    @IBOutlet weak var imageViewImage: UIImageView!
    @IBOutlet weak var imageViewPageControl: UIPageControl!
    
    // View II (details) outlets
    @IBOutlet weak var detailsViewTitleLabel: UILabel!
    @IBOutlet weak var detailsViewKnownHHView: UIView!
    @IBOutlet weak var detailsViewKnownHHReportButton: UIButton!
    @IBOutlet weak var detailsViewUnknownHHView: UIView!
    @IBOutlet weak var detailsViewUnknownHHAddButton: UIButton!
    @IBOutlet weak var detailsViewCurrentHHLabel: UILabel!
    @IBOutlet weak var detailsViewMoreHHLabel: UILabel!
    @IBOutlet weak var detailsViewMoreHHButton: UIButton!
    @IBOutlet weak var detailsViewFavoritesIcon: UIImageView!
    @IBOutlet weak var detailsViewFavoritesButton: UIButton!
    @IBOutlet weak var detailsViewRatingIcon: UIImageView!
    @IBOutlet weak var detailsViewRatingLabel: UILabel!
    @IBOutlet weak var detailsViewPricinessIcon: UIImageView!
    @IBOutlet weak var detailsViewPricinessLabel: UILabel!
    
    // View III (categories) outlets
    @IBOutlet weak var categoryLabel0: UILabel!
    @IBOutlet weak var categoryLabel1: UILabel!
    @IBOutlet weak var categoryLabel2: UILabel!
    @IBOutlet weak var categoryLabel3: UILabel!
    @IBOutlet weak var categoryLabel4: UILabel!
    @IBOutlet weak var categoryLabel5: UILabel!
    
    // View IV (review) outlets
    @IBOutlet weak var reviewViewContentLabel: UILabel!
    @IBOutlet weak var reviewViewAnnotationLabel: UILabel!
    
    // View V (map) outlets
    @IBOutlet weak var mapViewImage: UIImageView!
    @IBOutlet weak var mapViewButtonView: UIView!
    @IBOutlet weak var mapViewDirectionsButton: UIButton!
    
    // View VI (about) outlets
    @IBOutlet weak var aboutViewTitleLabel: UILabel!
    @IBOutlet weak var aboutViewContentLabel: UILabel!
    
    var happyHoursKnown: Bool = false {
        didSet {
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SelectedPlace", owner: self, options: nil)
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        updateUI()
    }
    
    private func updateUI() {
        self.detailsViewKnownHHView.isHidden = true
        self.detailsViewUnknownHHView.isHidden = true
        self.detailsViewMoreHHLabel.isHidden = true
        self.detailsViewMoreHHButton.isHidden = true
        self.detailsViewKnownHHReportButton.isHidden = true
        
        if happyHoursKnown {
            self.detailsViewKnownHHView.isHidden = false
            self.detailsViewMoreHHLabel.isHidden = false
            self.detailsViewMoreHHButton.isHidden = false
            self.detailsViewKnownHHReportButton.isHidden = false
        } else {
            self.detailsViewUnknownHHView.isHidden = false
            self.detailsViewUnknownHHView.layer.cornerRadius = 10
        }
        
        updateColors()
    }
    
    private func updateColors() {
        self.imageView.backgroundColor = FlatWhite()
        self.detailsView.backgroundColor = FlatWhite()
        self.categoriesView.backgroundColor = FlatWhite()
        self.reviewView.backgroundColor = FlatWhite()
        self.mapViewButtonView.backgroundColor = FlatWhite()
        self.aboutView.backgroundColor = FlatWhite()
        
        self.mapViewDirectionsButton.layer.cornerRadius = 10
        
        self.detailsViewRatingLabel.layer.masksToBounds = true
        self.detailsViewRatingLabel.layer.cornerRadius = 10
        
        self.detailsViewPricinessLabel.layer.masksToBounds = true
        self.detailsViewPricinessLabel.layer.cornerRadius = 10
    }
    
    func setCategories(_ categories: [String]) {
        categoryLabel0.text = categories.count > 0 ? categories[0] : ""
        categoryLabel1.text = categories.count > 1 ? categories[1] : ""
        categoryLabel2.text = categories.count > 2 ? categories[2] : ""
        categoryLabel3.text = categories.count > 3 ? categories[3] : ""
        categoryLabel4.text = categories.count > 4 ? categories[4] : ""
        categoryLabel5.text = categories.count > 5 ? categories[5] : ""
    }
    
}

extension UIView {
    func addDashedBorder() {
        let color = FlatGray().cgColor
        
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [6, 3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
}
