//
//  Place.swift
//  Cheers
//
//  Created by Will on 3/7/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation

extension String {
    var lines: [String] {
        var result: [String] = []
        enumerateLines { line, _ in result.append(line) }
        return result
    }
}

public struct Place: Equatable{
    var record: DatabaseRecord
    var favorited: Bool
    
    public static func ==(lhs: Place, rhs: Place) -> Bool {
        return lhs.record.id == rhs.record.id
    }

}

