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
    weak var currentCalloutView: UIView?
    
    // place to be passed via segue to SelectedBarViewController
    var selectedPlace: Place?
    
    // TODO: replace this static placeholder after settings page is done
    // this is in meters
    var searchDistance: Double? = 1000
    
    var masterList: [Place] = []
    var liveList: [Place] = []
    var notLiveList: [Place] = []
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
        addRangeOverlay()
    }
    
    // add circle overlay based on how big the search radius is
    func addRangeOverlay() {
        var overlays = [MKCircle]()
        // TODO: need to safely unwrap searchDistance
        overlays.append(MKCircle(center: (UserLocations.shared.currentLocation?.coordinate)!, radius: searchDistance!))
        mapView.addOverlays(overlays)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 1
        return renderer
    }
    
    // populate map with live and non-live bars
    func populateMap() {
        masterList = SharedListsSingleton.shared.masterList
        liveList = SharedListsSingleton.shared.liveList
        notLiveList = SharedListsSingleton.shared.notLiveList
        
        var maxDist: Double = 0.0
        var annotations = [AnnotationPlus]()
        
        // load live bars into map
        for place in liveList {
            let today = Date()
            let todaysDate = today.weekdayName
            // TODO: need to double check "nil"
            let todaysHappyHours = place.record.happyHours[todaysDate] ?? "nil"
            
            // TODO: get image working
            let viewModel = PlaceMapAnnotationViewModel(name: place.record.name, image: UIImage(named: "shout.jpg")!, happyHours: todaysHappyHours, favorited: place.favorited, place: place, live: true)
            let location = CLLocationCoordinate2DMake(CLLocationDegrees(place.record.latitude), CLLocationDegrees(place.record.longitude))
            let annotation = AnnotationPlus(viewModel: viewModel, coordinate: location)
            annotations.append(annotation)
            
            // need to check to see if maxDist for region needs to be updated
            let deltaLat = abs(Double(location.latitude) - Double((UserLocations.shared.currentLocation?.coordinate.latitude)!))
            let deltaLong = abs(Double(location.longitude) - Double((UserLocations.shared.currentLocation?.coordinate.longitude)!))
            
            let newMaxDist = deltaLat > deltaLong ? deltaLat : deltaLong
            maxDist = newMaxDist > maxDist ? newMaxDist : maxDist
        }
        
        mapView.setup(withAnnotations: annotations)
        
        // load not live bars into map
        for place in notLiveList {
            let today = Date()
            let todaysDate = today.weekdayName
            // TODO: need to double check "nil"
            let todaysHappyHours = place.record.happyHours[todaysDate] ?? "nil"
            
            // TODO: get image working
            let viewModel = PlaceMapAnnotationViewModel(name: place.record.name, image: UIImage(named: "shout.jpg")!, happyHours: todaysHappyHours, favorited: place.favorited, place: place, live: false)
            let location = CLLocationCoordinate2DMake(CLLocationDegrees(place.record.latitude), CLLocationDegrees(place.record.longitude))
            let annotation = AnnotationPlus(viewModel: viewModel, coordinate: location)
            annotations.append(annotation)
            
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
    
    // animate pins dropping on map
    func mapView(_ mapView: MapViewPlus, didAddAnnotations annotations: [AnnotationPlus]) {
        // TODO: if you want the map to zoom to fit all visible bars, uncomment this line
        //mapView.showAnnotations(annotations, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "AnnotationTapped" else { return }
        guard let selectedPlace = selectedPlace else { return }
        
        //let destination = segue.destination as! UINavigationController
        let destination = segue.destination as! SelectedBarViewController
        
        destination.place = selectedPlace
    }
    
    @IBAction func unwindToMap() {
    
    }

}

// set up delegate for callout
extension MapViewController: MapViewPlusDelegate {
    
    func mapView(_ mapView: MapViewPlus, imageFor annotation: AnnotationPlus) -> UIImage {
        let annotation = annotation.viewModel as! PlaceMapAnnotationViewModel
        if annotation.live {
            return UIImage(named: "live")!
        }
        return UIImage(named: "notLive")!
    }
    
    func mapView(_ mapView: MapViewPlus, calloutViewFor annotationView: AnnotationViewPlus) -> CalloutViewPlus {
        let calloutView = Bundle.main.loadNibNamed("PlaceMapAnnotationView", owner: nil, options: nil)!.first as! PlaceMapAnnotationView
        calloutView.delegate = self
        currentCalloutView = calloutView
        return calloutView
    }
}


// set up action for when callout is pressed
extension MapViewController: PlaceMapAnnotationViewModelDelegate {
    func beginToTriggerSegue(for place: Place) {
        selectedPlace = place
        performSegue(withIdentifier: "AnnotationTapped", sender: nil)
    }
}

