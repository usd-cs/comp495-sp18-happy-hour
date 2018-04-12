//
//  Place.swift
//  Cheers
//
//  Created by Will on 3/7/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation

let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let ArchiveURL = DocumentsDirectory.appendingPathComponent("places").appendingPathExtension("plist")

extension String {
    var lines: [String] {
        var result: [String] = []
        enumerateLines { line, _ in result.append(line) }
        return result
    }
}

public struct Place: Equatable, Codable{
    var record: DatabaseRecord
    var favorited: Bool
    
    public static func ==(lhs: Place, rhs: Place) -> Bool {
        return lhs.record.id == rhs.record.id
    }
    
    enum  CodingKeys: CodingKey{
        case record
        case favorited
    }
    
    init(record: DatabaseRecord, favorited: Bool){
        self.record = record
        self.favorited = favorited
    }
    
    
//    public init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: Place.CodingKeys.self)
//        record = try values.decode(DatabaseRecord.self, forKey: .record)
//        favorited = try values.decode(Bool.self, forKey: .favorited)
//    }
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: Place.CodingKeys.self)
//        try container.encode(favorited, forKey: .favorited)
//        try container.encode(record, forKey: .record)
//    }
    
}

public func saveToFile(favoritedPlaces: Place) {
    let encoder = PropertyListEncoder()
    let encodedPlaces = try? encoder.encode(favoritedPlaces)
    try? encodedPlaces?.write(to: ArchiveURL, options: .noFileProtection)
}

public func loadFromFile() -> [Place]?  {
    guard let decodedPlaces = try? Data(contentsOf: ArchiveURL) else {return nil}
    let decoder = PropertyListDecoder()
    return try? decoder.decode(Array<Place>.self, from: decodedPlaces
    )
}

