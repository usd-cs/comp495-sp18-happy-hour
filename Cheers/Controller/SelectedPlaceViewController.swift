//
//  SelectedPlaceViewController.swift
//  Cheers
//
//  Created by Will Carhart on 5/9/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import ChameleonFramework
import MapboxStatic

class SelectedPlaceViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var selectedPlaceView: SelectedPlace!
    
    var place: Place!
    var sender: String!
    
    var colors: [UIColor]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HistoryQueue.shared.append(self.place)
        self.colors = [RandomFlatColor(), RandomFlatColor()]
        self.view.backgroundColor = GradientColor(.topToBottom, frame: self.view.frame, colors: self.colors)
        configureContent()
        
        scrollView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteButton()
    }
    
    func configureContent() {
        let current = Date()
        let imageURL = URL(string: place.record.images[0])!
        ImageLoader.shared.getImageFromURL(for: imageURL) { image in
            self.selectedPlaceView.imageViewImage.image = image
        }
        self.selectedPlaceView.imageViewImage.contentMode = .scaleAspectFill
        
        self.selectedPlaceView.happyHoursKnown = !place.record.happyHours.isEmpty
        self.selectedPlaceView.detailsViewTitleLabel.text = place.record.name
        self.selectedPlaceView.detailsViewTitleLabel.sizeToFit()
        self.selectedPlaceView.detailsViewCurrentHHLabel.text = "\(place.record.happyHours[current.weekdayName] ?? "None today")"
        self.selectedPlaceView.detailsViewCurrentHHLabel.sizeToFit()
        
        self.selectedPlaceView.detailsViewRatingIcon.image = #imageLiteral(resourceName: "star")
        self.selectedPlaceView.detailsViewRatingLabel.text = " \(place.record.rating) "
        switch place.record.rating {
        case 0..<1.0:
            self.selectedPlaceView.detailsViewRatingLabel.backgroundColor = FlatRed()
        case 1.0..<2.0:
            self.selectedPlaceView.detailsViewRatingLabel.backgroundColor = FlatOrange()
        case 2.0..<3.0:
            self.selectedPlaceView.detailsViewRatingLabel.backgroundColor = FlatYellow()
        default:
            self.selectedPlaceView.detailsViewRatingLabel.backgroundColor = FlatGreen()
        }
        
        self.selectedPlaceView.detailsViewPricinessIcon.image = #imageLiteral(resourceName: "dollar_sign")
        self.selectedPlaceView.detailsViewPricinessLabel.text = " \(place.record.price.count) "
        self.selectedPlaceView.detailsViewPricinessLabel.backgroundColor = FlatGreen()
        
        self.selectedPlaceView.setCategories(place.record.categories.map { $0.rawValue })
        
        // TODO: dummy label
        self.selectedPlaceView.reviewViewContentLabel.text = "I love this place!!"
        self.selectedPlaceView.reviewViewAnnotationLabel.text = "-\(["Will Carhart", "Meelad Dawood", "Maeve McClatchey", "Jordan Abushahla"][Int(arc4random_uniform(3))])"
        
        self.selectedPlaceView.mapViewDirectionsButton.backgroundColor = FlatGreen()
        self.selectedPlaceView.mapViewDirectionsButton.setTitleColor(FlatBlackDark(), for: .normal)
        grabMapSnapshot()
        
        self.selectedPlaceView.aboutViewTitleLabel.text = "More Info"
        self.selectedPlaceView.aboutViewContentLabel.text = "\(place.record.address)\n\(place.record.city)"
        
        // configure button actions
        self.selectedPlaceView.detailsViewFavoritesButton.addTarget(self, action: #selector(favoritesButtonPressed), for: .touchUpInside)
        self.selectedPlaceView.detailsViewUnknownHHAddButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        self.selectedPlaceView.detailsViewKnownHHReportButton.addTarget(self, action: #selector(reportButtonPressed), for: .touchUpInside)
        self.selectedPlaceView.detailsViewMoreHHButton.addTarget(self, action: #selector(showMoreButtonPressed), for: .touchUpInside)
        self.selectedPlaceView.mapViewDirectionsButton.addTarget(self, action: #selector(getDirectionsButtonPressed), for: .touchUpInside)
    }
    
    func updateFavoriteButton() {
        if FavoritesSingleton.shared.favorites.isEmpty {
            self.selectedPlaceView.detailsViewFavoritesIcon.image = #imageLiteral(resourceName: "favorites")
        } else {
            if FavoritesSingleton.shared.favorites.contains(place) {
                self.selectedPlaceView.detailsViewFavoritesIcon.image = #imageLiteral(resourceName: "favorites_selected")
            } else {
                self.selectedPlaceView.detailsViewFavoritesIcon.image = #imageLiteral(resourceName: "favorites")
            }
        }
    }
    
    func grabMapSnapshot() {
        let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(place.record.latitude), longitude: CLLocationDegrees(place.record.longitude))
        let camera = SnapshotCamera(lookingAtCenter: location, zoomLevel: 14)
        //camera.heading = 45
        //camera.pitch = 60
        
        let marker = Marker(coordinate: location, size: .medium, iconName: "beer")
        marker.color = FlatOrange()
        
        let options = SnapshotOptions(
            styleURL: URL(string: "mapbox://styles/mapbox/streets-v10")!,
            camera: camera,
            size: CGSize(width: 200, height: 200)
        )
        options.overlays.append(marker)
        let snapshot = Snapshot(options: options, accessToken: (Bundle.main.object(forInfoDictionaryKey: "MGLMapboxAccessToken") as! String))
        snapshot.image { (image, error) in
            if let image = image {
                self.selectedPlaceView.mapViewImage.image = image
            } else {
                print("ERROR: could not resolve map image")
                print(error!.localizedDescription)
            }
        }
    }
    
    @objc func favoritesButtonPressed() {
        if FavoritesSingleton.shared.favorites.isEmpty {
            place.favorited = true
            self.selectedPlaceView.detailsViewFavoritesIcon.image = #imageLiteral(resourceName: "favorites_selected")
            FavoritesSingleton.shared.update(place: place, isFavorited: true)
        } else {
            if FavoritesSingleton.shared.favorites.contains(place) {
                place.favorited = false
                self.selectedPlaceView.detailsViewFavoritesIcon.image = #imageLiteral(resourceName: "favorites")
                FavoritesSingleton.shared.update(place: place, isFavorited: false)
            } else {
                place.favorited = true
                self.selectedPlaceView.detailsViewFavoritesIcon.image = #imageLiteral(resourceName: "favorites_selected")
                FavoritesSingleton.shared.update(place: place, isFavorited: true)
            }
        }
    }
    
    @objc func addButtonPressed() {
        print("add")
    }
    
    @objc func reportButtonPressed() {
        print("report")
    }
    
    @objc func showMoreButtonPressed() {
        print("show")
    }
    
    @objc func getDirectionsButtonPressed() {
        let alertController = UIAlertController(title: "Get a ride to \(place.record.name)", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let uberAction = UIAlertAction(title: "Call an Uber", style: .default, handler: switchToUber)
        let lyftAction = UIAlertAction(title: "Call a Lyft", style: .default, handler: switchToLyft)
        let mapAction = UIAlertAction(title: "Open in Maps", style: .default, handler: switchToMaps)
        
        alertController.addAction(uberAction)
        alertController.addAction(lyftAction)
        alertController.addAction(mapAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func switchToUber(_ alert: UIAlertAction) {
        
    }
    
    func switchToLyft(_ alert: UIAlertAction) {
        
    }
    
    func switchToMaps(_ alert: UIAlertAction) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

}

extension SelectedPlaceViewController: UIGestureRecognizerDelegate, UIScrollViewDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -75.0 {
            if sender == "List" {
                performSegue(withIdentifier: "barToList", sender: nil)
            } else if sender == "Map" {
                performSegue(withIdentifier: "barToMap", sender: nil)
            } else if sender == "Favorites" {
                performSegue(withIdentifier: "barToFavorites", sender: nil)
            }
        }
    }
}
