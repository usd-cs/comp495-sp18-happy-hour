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

var favoriteList = [Place]()

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

    init(record: DatabaseRecord, favorited: Bool){
        self.record = record
        self.favorited = favorited
    }
    
    static func saveToFile(favoritedPlace: Place) {
        let encoder = PropertyListEncoder()
        favoriteList.append(favoritedPlace)
        
        let encodedPlaces = try? encoder.encode(favoriteList)
        try? encodedPlaces?.write(to: ArchiveURL, options: .noFileProtection)
        
        // DEBUG:
        print("Saving \(favoritedPlace) to file...")
    }
    
    static func loadFromFile() -> [Place]?  {
        guard let decodedPlaces = try? Data(contentsOf: ArchiveURL) else {return nil}
        let decoder = PropertyListDecoder()
       
        do{
            let decodedArray = try decoder.decode(Array<Place>.self, from: decodedPlaces)
            return decodedArray
        }
        catch {
            print(error)
            return nil
        }
    }
    
    static func saveToList(favoritedPlace: Place) {
        favoriteList.append(favoritedPlace)
    }
    
    static func loadFromList() -> [Place]? {
        return favoriteList
    }
}



