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
    
    private let documentsDirectory: URL
    private let archiveURL: URL
    
    var history: [Place] = []
    var index: Int = 0
    let MAX_SIZE: Int = 10
    
    init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        archiveURL = documentsDirectory.appendingPathComponent("history").appendingPathExtension(".plist")
    }
    
    func append(_ item: Place) {
        
        let historyFromDisk = loadFromFile()
        
        if var history = historyFromDisk {
            if history.contains(item) {
                history.remove(at: history.index(of: item)!)
                history.append(item)
                self.history = history
                persist()
            } else {
                if history.count >= MAX_SIZE {
                    history.remove(at: 0)
                }
                history.append(item)
                self.history = history
                persist()
            }
        } else {
            HistoryQueue.shared.history.append(item)
            persist()
        }
        
    }
    
    private func loadFromFile() -> [Place]? {
        guard let decodedList = try? Data(contentsOf: archiveURL) else { return nil }
        
        let decoder = PropertyListDecoder()
        do {
            let decodedArray = try decoder.decode(Array<Place>.self, from: decodedList)
            return decodedArray
        } catch { return nil }
    }
    
    func loadHistory() {
        if let historyFromDisk = loadFromFile() {
            HistoryQueue.shared.history = historyFromDisk
        }
    }
    
    private func persist() {
        let encoder = PropertyListEncoder()
        let encodedPlaces = try! encoder.encode(self.history)
        try! encodedPlaces.write(to: archiveURL, options: .noFileProtection)
    }
}
