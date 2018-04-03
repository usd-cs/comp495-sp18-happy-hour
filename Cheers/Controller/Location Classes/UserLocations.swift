//
//  UserLocations.swift
//  Cheers
//
//  Created by Meelad Dawood on 4/1/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import CoreLocation

class UserLocations: CLLocationManager, CLLocationManagerDelegate {
    
    //Singleton variable to be shared.
    public static var shared: UserLocations!
    
    public var currentLatitude: Double?
    public var currentLongitude: Double?
    public var authorizationStatus: CLAuthorizationStatus
    
    
    // MARK: - Intialization
    private override init() {
        authorizationStatus = CLLocationManager.authorizationStatus()
        super.init()
    }
    
    
    // MARK: - Public Methods
    public static func instantiateSharedInstance() {
        // initialize with example data
        shared = UserLocations()
        
        UserLocations.shared.delegate = UserLocations.shared
        UserLocations.shared.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        UserLocations.shared.startUpdatingLocation()
    }
    
    var locationPermissionsGranted: Bool {
        return authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse
    }
    
    var currentLocation: CLLocation? {
        if let latitude = currentLatitude, let longitude = currentLongitude {
            return CLLocation(latitude: latitude, longitude: longitude)
        }
        return nil
    }
    
    
    // MARK: - Delegate Methods
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            self.currentLatitude = nil
            self.currentLongitude = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = manager.location?.coordinate
        currentLatitude = currentLocation?.latitude
        currentLongitude = currentLocation?.longitude
    }
}
