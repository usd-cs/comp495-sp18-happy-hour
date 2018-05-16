//
//  ImageLoader.swift
//  Cheers
//
//  Created by Meelad Dawood on 4/2/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class ImageLoader {
    
    private let imageCache = NSCache<NSString, NSData>()
    
    //Singleton variable to be shared
    static let shared = ImageLoader()
    
    //Downloads image and caches it so each image is only requested once
    func getImageFromURL(for url: URL, completionHandler: @escaping(_ image: UIImage?) -> ()) {
        
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            //check if image is in the imageCache
            if let cachedImage = self.imageCache.object(forKey: url.absoluteString as NSString) {
                DispatchQueue.main.async {
                    // DEBUG:
                    //print("We in the cache boys")
                    completionHandler(UIImage(data: cachedImage as Data)) }
                return
            }
            
            //not in cache then download it
            guard let downloadedImage = NSData(contentsOf: url) else {
                DispatchQueue.main.async { completionHandler(nil) }
                return
            }
            
            //put the image in the cache for future use. 
            self.imageCache.setObject(downloadedImage, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async { completionHandler(UIImage(data: downloadedImage as Data)) }
        }
        SVProgressHUD.dismiss()
    }
    
}
