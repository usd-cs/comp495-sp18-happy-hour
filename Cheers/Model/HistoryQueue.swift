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
        history.insert(item, at: index)
        index = (index + 1) % MAX_SIZE
        
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
        print("History is now: \(history)")
        
        try? encodedHistory?.write(to: archiveURL, options: .noFileProtection)
    }
}
