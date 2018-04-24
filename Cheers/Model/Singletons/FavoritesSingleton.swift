//
//  FavoritesSingleton.swift
//  Cheers
//
//  Created by Will Carhart on 4/18/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation

public class FavoritesSingleton: Codable {
    static let shared = FavoritesSingleton()
    var favorites: [Place] = []
    
    private let documentsDirectory: URL
    private let archiveURL: URL
    
    init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        archiveURL = documentsDirectory.appendingPathComponent("favorites").appendingPathExtension(".plist")
    }
    
    func update(place: Place, isFavorited: Bool) {
        let favoritesFromDisk = loadFromFile()
        
        if let favoritesFromDisk = favoritesFromDisk {
            if isFavorited {
                if favoritesFromDisk.contains(place) {
                    print("1")
                    print("It seems that this place is already favorited: \(place.record.name)")
                    saveToFile()
                } else {
                    favorites.append(place)
                    print("2")
                    print("Adding \(place.record.name) to favorites...")
                    saveToFile()
                }
            } else {
                favorites.remove(at: favorites.index(of: place)!)
                print("3")
                print("Removing \(place.record.name) from favorites...")
                saveToFile()
            }
        } else {
            favorites.append(place)
            print("4")
            print("Adding \(place.record.name) to favorites...")
            saveToFile()
        }
        
    }
    
    private func saveToFile() {
//        do {
//            try FileManager.default.removeItem(at: archiveURL)
//        } catch {
//            print("Error deleting file: \n\(error)")
//        }
        
        let encoder = PropertyListEncoder()
        
        let encodedPlaces = try! encoder.encode(favorites)
        
        try! encodedPlaces.write(to: archiveURL, options: .noFileProtection)
        
        // DEBUG:
        print("Writing to file...")
        print("Favorites is now: ")
        for (i, place) in favorites.enumerated() {
            print("  \(i). \(place.record.name)")
        }
    }
    
    private func loadFromFile() -> [Place]? {
        guard let decodedList = try? Data(contentsOf: archiveURL) else {
            print("Warning: returning nil, didn't find content on disk")
            return nil
        }
        
        let decoder = PropertyListDecoder()
        
        do {
            let decodedArray = try decoder.decode(Array<Place>.self, from: decodedList)
            return decodedArray
        } catch {
            print("Error loading from disk: \n\(error)")
            return nil
        }
    }
}
