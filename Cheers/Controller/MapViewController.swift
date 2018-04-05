//
//  SecondViewController.swift
//  Cheers
//
//  Created by Will on 3/6/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import MapKit
import MapViewPlus
import SwiftDate

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MapViewPlus!
    
    var barList: [Place] = []
    var myLocation: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // prepare map for custom annotations
        mapView.delegate = self

        // gets the current location from the caculation in the AppDelegate
        myLocation = UserLocations.shared.currentLocation?.coordinate
        mapView.showsUserLocation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateMap()
    }
    
    
    func populateMap() {
        barList = SharedListsSingleton.shared.masterList
        
        //var mapLocations: [String: MKPointAnnotation] = [:]
        var maxDist: Double = 0.0
        var annotations = [AnnotationPlus]()
        
        for place in barList {
            
            // make new location for bar
            /*
            let annotation = MKPointAnnotation()
            let location = CLLocationCoordinate2DMake(CLLocationDegrees(place.record.latitude), CLLocationDegrees(place.record.longitude))
            annotation.coordinate = location
            annotation.title = place.record.name
            annotation.subtitle = place.record.address
            mapLocations[place.record.name] = annotation
            */
            
            let today = Date()
            let todaysDate = today.weekdayName
            let todaysHappyHours = place.record.happyHours[todaysDate] ?? "nil"
            
            // TODO: get image working
            let viewModel = PlaceMapAnnotationViewModel(name: place.record.name, image: UIImage(named: "shout.jpg")!, happyHours: todaysHappyHours, favorited: place.favorited, place: place)
            let location = CLLocationCoordinate2DMake(CLLocationDegrees(place.record.latitude), CLLocationDegrees(place.record.longitude))
            let annotation = AnnotationPlus(viewModel: viewModel, coordinate: location)
            annotations.append(annotation)
            
            
            //mapView.addAnnotation(annotation)
            
            // DEBUG:
            //print("Adding \(annotation.title!) to the map")
            
            
            // need to check to see if maxDist for region needs to be updated
            let deltaLat = abs(Double(location.latitude) - Double((UserLocations.shared.currentLocation?.coordinate.latitude)!))
            let deltaLong = abs(Double(location.longitude) - Double((UserLocations.shared.currentLocation?.coordinate.longitude)!))
            
            let newMaxDist = deltaLat > deltaLong ? deltaLat : deltaLong
            maxDist = newMaxDist > maxDist ? newMaxDist : maxDist
            
        }
        
        mapView.setup(withAnnotations: annotations)
        
        // set span of map
        let spanRadius = 2 * maxDist
        
        // set region of map
        let span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(spanRadius), longitudeDelta: CLLocationDegrees(spanRadius))
        let region = MKCoordinateRegion(center: (UserLocations.shared.currentLocation?.coordinate)!, span: span)
        mapView.setRegion(region, animated: true)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MapViewController: MapViewPlusDelegate {
    
    func mapView(_ mapView: MapViewPlus, imageFor annotation: AnnotationPlus) -> UIImage {
        // TODO: need to update this
        return UIImage(named: "location_full")!
    }
    
    func mapView(_ mapView: MapViewPlus, calloutViewFor annotationView: AnnotationViewPlus) -> CalloutViewPlus{
        let calloutView = Bundle.main.loadNibNamed("PlaceMapAnnotation", owner: nil, options: nil)!.first as! PlaceMapAnnotationView
        return calloutView
    }
}

