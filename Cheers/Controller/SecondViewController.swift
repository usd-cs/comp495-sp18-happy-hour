//
//  SecondViewController.swift
//  Cheers
//
//  Created by Will on 3/6/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SecondViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var Map: MKMapView!
    
    var barList: [Place] = []
    var myLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Current Location required set-up
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()

        // set up my location
        myLocation = CLLocationCoordinate2DMake(32.774063, -117.185914)

        // load in bars
        populateMap()

        
    }
    
    
    //Reads the location manager for latest coordinate and displays it on map.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        
        
        myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude , location.coordinate.longitude)

        
        let center = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)
        let reigon = MKCoordinateRegion(center: center, span: span)
        
        Map.setRegion(reigon, animated: true)
        Map.showsUserLocation = true
        
        locationManager.stopUpdatingLocation()
        
    }
  
    
    func populateMap() {
        // this call will be replaced by API call once core features are functioning
        barList = Place.readFromTextFile()
        
        var mapLocations: [String: MKPointAnnotation] = [:]
        var maxDist: Double = 0.0
        
        for place in barList {
            
            // make new location for bar
            let annotation = MKPointAnnotation()
            let location = CLLocationCoordinate2DMake(CLLocationDegrees(place.latitude), CLLocationDegrees(place.longitude))
            annotation.coordinate = location
            annotation.title = place.name
            annotation.subtitle = place.address
            mapLocations[place.name] = annotation
            Map.addAnnotation(annotation)
            
            // for DEBUG only
            //print("Adding \(annotation.title!) to the map")
            
            // need to check to see if maxDist for region needs to be updated
            let deltaLat = abs(Double(location.latitude) - Double(myLocation!.latitude))
            let deltaLong = abs(Double(location.longitude) - Double(myLocation!.longitude))
            
            let newMaxDist = deltaLat > deltaLong ? deltaLat : deltaLong
            maxDist = newMaxDist > maxDist ? newMaxDist : maxDist
        }
        
        // set span of map
        let spanRadius = 2 * maxDist
        
        // set region of map
        let span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(spanRadius), longitudeDelta: CLLocationDegrees(spanRadius))
        let region = MKCoordinateRegion(center: myLocation!, span: span)
        Map.setRegion(region, animated: true)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

