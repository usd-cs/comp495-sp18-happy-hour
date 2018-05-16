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

class MapViewController: UIViewController, FilterMenuDelegate {
    
    @IBOutlet weak var rangeButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var mapView: MapViewPlus!
    weak var currentCalloutView: UIView?
    
    // place to be passed via segue to SelectedBarViewController
    var selectedPlace: Place?

    var myLocation: CLLocationCoordinate2D?
    
    // for circle overlay
    var overlays = [MKCircle]()
    var showOverlay: Bool = true
    
    var hasAppeared: Bool = false
    var lastDist: Double!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // prepare map for custom annotations
        mapView.delegate = self

        // gets the current location from the caculation in the AppDelegate
        myLocation = UserLocations.shared.currentLocation?.coordinate
        mapView.showsUserLocation = true
        
        mapView.showsPointsOfInterest = false
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        
        filterButton.tintColor = UIColor.black
        rangeButton.tintColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadMap()
    }
    
    func reloadMap() {
        if !hasAppeared {
            populateMap()
            updateRangeOverlay()
            hasAppeared = true
            lastDist = FilterSettingsSingleton.shared.distanceFromMe
        } else {
            updateRangeOverlay()
            mapView.removeAllAnnotations()
            populateMap()
        }
        updateSpan()
    }
    
    func updateSpan() {
        // set span of map
        let spanRadius = 2.5 * FilterSettingsSingleton.shared.distanceFromMe / 69.0
        
        // set region of map
        let span = MKCoordinateSpanMake(spanRadius, spanRadius)
        let region = MKCoordinateRegion(center: (UserLocations.shared.currentLocation?.coordinate)!, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func updateRangeOverlay() {
        if showOverlay {
            if !overlays.isEmpty {
                mapView.removeOverlays(overlays)
                overlays.removeAll()
            }
            overlays.append(MKCircle(center: (UserLocations.shared.currentLocation?.coordinate)!, radius: FilterSettingsSingleton.shared.distanceFromMe*1609.34))
            mapView.addOverlays(overlays)
        } else {
            if !overlays.isEmpty {
                mapView.removeOverlays(overlays)
                overlays.removeAll()
            }
        }
    }
    
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        FilterSettingsSingleton.filterMenu.delegate = self
        FilterSettingsSingleton.filterMenu.showFilterMenu()
    }
    
    @IBAction func rangeButtonPressed(_ sender: UIButton) {
        showOverlay = !showOverlay
        updateRangeOverlay()
    }
    
    func updateParent() {
        reloadMap()
    }
    
    // renderer for map view overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
        renderer.strokeColor = UIColor.black
        renderer.lineWidth = 1
        return renderer
    }
    
    func calculateDistance(myLat: Double, myLong: Double, placeLat: Double, placeLong: Double) -> Double {
        // radius of the earth in meters
        let radius: Double = 6371
        
        let deltaLat: Double = toRadians(placeLat - myLat)
        let deltaLong: Double = toRadians(placeLong - myLong)
        
        let a: Double =
            sin(deltaLat / 2.0) * sin(deltaLat / 2.0) +
                cos(toRadians(myLat)) * cos(toRadians(placeLat)) *
                sin(deltaLong / 2.0) * sin(deltaLong / 2.0)
        
        let c: Double = 2.0 * atan2(sqrt(a), sqrt(1.0 - a))
        let d: Double = radius * c
        
        return d * 0.621371
    }
    
    func toRadians(_ degrees: Double) -> Double {
        return degrees * (Double.pi / 180.0)
    }
    
    // populate map with live and non-live bars
    func populateMap() {
        var annotations = [AnnotationPlus]()
        
        // load live bars into map
        for place in SharedListsSingleton.shared.liveList {
            let distanceFromMe = calculateDistance(myLat: Double((UserLocations.shared.currentLocation?.coordinate.latitude)!), myLong: Double((UserLocations.shared.currentLocation?.coordinate.longitude)!), placeLat: place.record.latitude, placeLong: place.record.longitude)
            
            if distanceFromMe <= FilterSettingsSingleton.shared.distanceFromMe {
                let today = Date()
                let todaysDate = today.weekdayName
                let todaysHappyHours = place.record.happyHours[todaysDate] ?? "No happy hours today."
                
                let viewModel = PlaceMapAnnotationViewModel(name: place.record.name, happyHours: todaysHappyHours, favorited: place.favorited, place: place, live: true)
               
                let location = CLLocationCoordinate2DMake(CLLocationDegrees(place.record.latitude), CLLocationDegrees(place.record.longitude))
                let annotation = AnnotationPlus(viewModel: viewModel, coordinate: location)
                annotations.append(annotation)
            }
        }
        
        mapView.setup(withAnnotations: annotations)
        
        // load not live bars into map
        for place in SharedListsSingleton.shared.allList {
            let distanceFromMe = calculateDistance(myLat: Double((UserLocations.shared.currentLocation?.coordinate.latitude)!), myLong: Double((UserLocations.shared.currentLocation?.coordinate.longitude)!), placeLat: place.record.latitude, placeLong: place.record.longitude)

            if distanceFromMe <= FilterSettingsSingleton.shared.distanceFromMe {
                let today = Date()
                let todaysDate = today.weekdayName
                let todaysHappyHours = place.record.happyHours[todaysDate] ?? "No happy hours today."
                
                
                let viewModel = PlaceMapAnnotationViewModel(name: place.record.name, happyHours: todaysHappyHours, favorited: place.favorited, place: place, live: false)
                
                let location = CLLocationCoordinate2DMake(CLLocationDegrees(place.record.latitude), CLLocationDegrees(place.record.longitude))
                let annotation = AnnotationPlus(viewModel: viewModel, coordinate: location)
                annotations.append(annotation)
            }
        }
        
        mapView.setup(withAnnotations: annotations)
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
        
        let destination = segue.destination as! SelectedPlaceViewController
        
        destination.place = selectedPlace
        destination.sender = "Map"
    }
    
    @IBAction func unwindToMap(segue: UIStoryboardSegue) {
    
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

