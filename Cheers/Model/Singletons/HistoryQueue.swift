//
//  HistoryQueue.swift
//  Cheers
//
//  Created by Will Carhart on 4/17/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation

class HistoryQueue: Codable {
    static let shared = HistoryQueue()
    
    var history: [Place] = []
    var index: Int = 0
    let MAX_SIZE: Int = 10
    
    func append(_ item: Place) {
        if history.contains(item) {
            history.remove(at: history.index(of: item)!)
            history.append(item)
        } else {
            if history.count >= MAX_SIZE {
                history.remove(at: 0)
            }
            history.append(item)
        }
        
        // TODO: need to make the history queue persist
        //persist()
    }
    
    func persist() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("history_queue").appendingPathComponent("plist")
        
        let propertyListEncoder = PropertyListEncoder()
        let encodedHistory = try? propertyListEncoder.encode(history)
        
        print("\n\nSaving history...")
        print("History is now:")
        for (i, place) in history.enumerated() {
            print("\(i). \(place.record.name)")
        }
        
        try? encodedHistory?.write(to: archiveURL, options: .noFileProtection)
    }
}
