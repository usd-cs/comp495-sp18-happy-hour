//
//  HistoryQueue.swift
//  Cheers
//
//  Created by Will Carhart on 4/17/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation

class HistoryQueue: Codable {
    var history = [DatabaseRecord]()
    var index: Int = 0
    let MAX_SIZE: Int = 10
    
    func append(_ item: DatabaseRecord) {
        history[index] = item
        index = (index + 1) % MAX_SIZE
        
        // write to file
    }
}
