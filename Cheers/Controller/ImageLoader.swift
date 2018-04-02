//
//  ImageLoader.swift
//  Cheers
//
//  Created by Meelad Dawood on 4/2/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation
import UIKit

class ImageLoader {
    
    private let imageCache = NSCache<NSString, NSData>()
    
    static let shared = ImageLoader()
    
    //Downloads image and caches it so each image is only requested once
    func getImageFromURL(for url: URL, completionHandler: @escaping(_ image: UIImage?) -> ()) {
        
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            if let data = self.imageCache.object(forKey: url.absoluteString as NSString) {
                DispatchQueue.main.async { completionHandler(UIImage(data: data as Data)) }
                return
            }
            
            guard let data = NSData(contentsOf: url) else {
                DispatchQueue.main.async { completionHandler(nil) }
                return
            }
            
            self.imageCache.setObject(data, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async { completionHandler(UIImage(data: data as Data)) }
        }
    }
    
}
