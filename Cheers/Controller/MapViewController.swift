//
//  SecondViewController.swift
//  Cheers
//
//  Created by Will on 3/6/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var Map: MKMapView!
    
    var barList: [Place] = []
    var myLocation: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        //Gets the current location from the caculation in the AppDelegate
        myLocation = UserLocations.shared.currentLocation?.coordinate
        Map.showsUserLocation = true

        // load in bars
        //populateMap()

        
    }
    
    /*
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
        
    } */
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

