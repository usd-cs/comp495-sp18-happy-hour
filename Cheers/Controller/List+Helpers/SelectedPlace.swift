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
    @IBOutlet weak var imageViewButton: UIButton!
    
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
    
    // View IV (review) outlets
    @IBOutlet weak var reviewViewContentLabel: UILabel!
    @IBOutlet weak var reviewViewAnnotationLabel: UILabel!
    @IBOutlet weak var yelpReviewButton: UIButton!
    @IBOutlet weak var reviewStar0: UIImageView!
    @IBOutlet weak var reviewStar1: UIImageView!
    @IBOutlet weak var reviewStar2: UIImageView!
    @IBOutlet weak var reviewStar3: UIImageView!
    @IBOutlet weak var reviewStar4: UIImageView!
    
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
        
        self.detailsViewRatingLabel.layer.masksToBounds = true
        self.detailsViewRatingLabel.layer.cornerRadius = 10
        
        self.detailsViewPricinessLabel.layer.masksToBounds = true
        self.detailsViewPricinessLabel.layer.cornerRadius = 10
    }
    
}
