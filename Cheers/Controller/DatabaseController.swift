//
//  DatabaseController.swift
//  Cheers
//
//  Created by Meelad Dawood on 3/15/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation
import Firebase

class DatabaseController {
    
    //var barList = [Place]()
    var barList: [Place] = []
        
    //barList = Place.readFromTextFile()
    
    for bar in barList {

        let barsDB =  Database.database().reference().child("Place")
    }
    
    
    
    
    
    
    
    
//    let messageDictionary = ["Bar":bar.name ,
//                             "Address":bar.address]
//
//    barsDB.childByAutoId().setValue(messageDictionary) {
//    (error, reference) in
//
//    if error != nil{
//    print(error!)
//    } else {
//    print("Message Saved successfully")
//    }
//    }
    
    
    
    
    
}
