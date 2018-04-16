//
//  SharedListsSingleton.swift
//  Cheers
//
//  Created by Will on 4/4/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation

class SharedListsSingleton {
    static let shared = SharedListsSingleton()
    var masterList: [Place] = [] {
        didSet {
            // DEBUG:
            print("MasterList is now: \(masterList)\n\n")
        }
    }
    var liveList: [Place] = []
    var notLiveList: [Place] = []
}
