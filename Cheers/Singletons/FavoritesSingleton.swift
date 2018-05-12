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
                    saveToFile()
                } else {
                    favorites.append(place)
                    saveToFile()
                }
            } else {
                favorites.remove(at: favorites.index(of: place)!)
                saveToFile()
            }
        } else {
            favorites.append(place)
            saveToFile()
        }
        
        if FilterSettingsSingleton.shared.favorited {
            SharedListsSingleton.shared.filterWithSettings()
        }
    }
    
    private func saveToFile() {
        let encoder = PropertyListEncoder()
        let encodedPlaces = try! encoder.encode(favorites)
        try! encodedPlaces.write(to: archiveURL, options: .noFileProtection)
    }
    
    private func loadFromFile() -> [Place]? {
        guard let decodedList = try? Data(contentsOf: archiveURL) else { return nil }
        
        let decoder = PropertyListDecoder()
        do {
            let decodedArray = try decoder.decode(Array<Place>.self, from: decodedList)
            return decodedArray
        } catch { return nil }
    }
    
    func loadFavorites() {
        if let favoritesFromDisk = loadFromFile() {
            FavoritesSingleton.shared.favorites = favoritesFromDisk
        }
    }
}
