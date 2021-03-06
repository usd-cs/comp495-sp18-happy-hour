//
//  FilterMenu.swift
//  Cheers
//
//  Created by Meelad Dawood on 4/13/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation
import UIKit

protocol FilterMenuDelegate {
    func updateParent()
}

class FilterMenu: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var delegate: FilterMenuDelegate?
    
    let blackView = UIView()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.isUserInteractionEnabled = true
        return cv
    }()
    
    let distanceCellId = "distanceCellId"
    let minimumRatingCellId = "minimumRatingCellId"
    let maximumPriceCellId = "maximumPriceCellId"
    let favoritesOnlyCellId = "favoritesOnlyCellId"
    let sortCellId = "sortCellId"
    
    func showFilterMenu() {
        
        if let window = UIApplication.shared.keyWindow {
            
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideFilterMenu)))
            
            window.addSubview(blackView)
            window.addSubview(collectionView)
            
            let height : CGFloat = 350
            let theY = window.frame.height - height
            
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: theY, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }, completion: nil)
            
        }
        
    }
    
    @objc func hideFilterMenu() {
        delegate?.updateParent()
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell : UICollectionViewCell? = nil
        
        if indexPath.row == 0{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: distanceCellId, for: indexPath)
        }
        
        if indexPath.row == 1{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: minimumRatingCellId, for: indexPath)
        }
        
        if indexPath.row == 2{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: maximumPriceCellId, for: indexPath)
        }
        
        if indexPath.row == 3 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: favoritesOnlyCellId, for: indexPath)
        }
        
        if indexPath.row == 4 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: sortCellId, for: indexPath)
        }
        return cell!
    }
    
    
    
    override init() {
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DistanceFilterOptionCell.self, forCellWithReuseIdentifier: distanceCellId)
        collectionView.register(MinimumRatingFilterOptionCell.self, forCellWithReuseIdentifier: minimumRatingCellId)
        collectionView.register(MaximumPriceFilterOptionCell.self, forCellWithReuseIdentifier: maximumPriceCellId)
        collectionView.register(FavoritesOnlyFilterOptionCell.self, forCellWithReuseIdentifier: favoritesOnlyCellId)
        collectionView.register(SortFilterOptionCell.self, forCellWithReuseIdentifier: sortCellId)
    }
}
