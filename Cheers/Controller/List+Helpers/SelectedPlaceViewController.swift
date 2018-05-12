//
//  SelectedPlaceViewController.swift
//  Cheers
//
//  Created by Will Carhart on 5/9/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import UIKit
import ChameleonFramework
import SwiftPhotoGallery
import SpriteKit

import UberRides
import Lyft
import LyftSDK

import MapboxStatic
import MapKit

import Alamofire
import SwiftyJSON
import SafariServices

class SelectedPlaceViewController: UIViewController {
    
    // for storing reviews from Yelp API call
    struct Review {
        var name: String
        var text: String
        var score: Int
    }

    // storyboard outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var selectedPlaceView: SelectedPlace!
    
    // current place struct and what view sent it
    var place: Place!
    var sender: String!
    
    // for photo
    var photoURLs: [String?]?
    var photos = [UIImage]()
    var gallery: SwiftPhotoGallery!
    
    // for opening Yelp in SafariVC
    var yelpURL: String?
    
    // for reviews
    var reviews: [Review]!
    var reviewIndex = 0
    
    // for showing ride share menu
    let background = UIView()
    let rideShareMenu = RideShareMenu()
    
    // for showing categories bubbles
    var categories: [String]!
    var skView: SKView!
    var floatingCollectionScene: BubblesScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HistoryQueue.shared.append(self.place)
        
        // set up background
        let colors = ColorsSingleton.shared.getColorPair()
        self.view.backgroundColor = GradientColor(.topToBottom, frame: self.view.frame, colors: colors)
        
        self.photoURLs = [nil, nil, nil]
        
        reviews = []
        categories = []
        
        acquirePictures()
        acquireReviews()
        configureContent()
        
        _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(slidePhotos), userInfo: nil, repeats: true)
        _ = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(updateReviews), userInfo: nil, repeats: true)
        
        scrollView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteButton()
    }
    
    @objc func slidePhotos() {
        var index = self.selectedPlaceView.imageViewPageControl.currentPage + 1
        index = index % self.photos.count
        self.selectedPlaceView.imageViewPageControl.currentPage = index
        let newImage = self.photos[self.selectedPlaceView.imageViewPageControl.currentPage]
        
        UIView.transition(with: self.selectedPlaceView.imageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.selectedPlaceView.imageViewImage.image = newImage
        }, completion: nil)
        
    }
    
    func configureContent() {
        configureImageView()
        configureDetailsView()
        //configureCategoriesView()
        configureReviewsView()
        configureMapView()
        configureAboutView()
        
        // configure button actions
        self.selectedPlaceView.detailsViewFavoritesButton.addTarget(self, action: #selector(favoritesButtonPressed), for: .touchUpInside)
        self.selectedPlaceView.detailsViewUnknownHHAddButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        self.selectedPlaceView.detailsViewKnownHHReportButton.addTarget(self, action: #selector(reportButtonPressed), for: .touchUpInside)
        self.selectedPlaceView.detailsViewMoreHHButton.addTarget(self, action: #selector(showMoreButtonPressed), for: .touchUpInside)
        self.selectedPlaceView.mapViewDirectionsButton.addTarget(self, action: #selector(getDirectionsButtonPressed), for: .touchUpInside)
    }
    
    func configureImageView() {
        
        self.selectedPlaceView.imageViewButton.addTarget(self, action: #selector(showGallery), for: .touchUpInside)
        
        // load in first image
        let imageURL = URL(string: place.record.images[0])!
        ImageLoader.shared.getImageFromURL(for: imageURL) { image in
            self.selectedPlaceView.imageViewImage.image = image
        }
        self.selectedPlaceView.imageViewImage.contentMode = .scaleAspectFill
        self.selectedPlaceView.imageViewPageControl.numberOfPages = 0
        
    }
    
    @objc func showGallery() {
        gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
        
        gallery.backgroundColor = FlatBlack()
        gallery.pageIndicatorTintColor = FlatGray().withAlphaComponent(0.5)
        gallery.currentPageIndicatorTintColor = FlatWhite()
        gallery.hidePageControl = false
        
        present(gallery, animated: true, completion: { () -> Void in
            self.gallery.currentPage = self.selectedPlaceView.imageViewPageControl.currentPage
        })
    }
    
    func configureDetailsView() {
        
        let current = Date()
        
        self.selectedPlaceView.happyHoursKnown = !place.record.happyHours.isEmpty
        
        self.selectedPlaceView.detailsViewTitleLabel.text = place.record.name
        self.selectedPlaceView.detailsViewTitleLabel.adjustsFontSizeToFitWidth = true
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
    }
    
    func configureCategoriesView() {
        skView = SKView(frame: self.selectedPlaceView.categoriesView.frame)
        self.selectedPlaceView.categoriesView.addSubview(skView)
        skView.topAnchor.constraint(equalTo: self.selectedPlaceView.categoriesView.topAnchor, constant: 0).isActive = true
        skView.bottomAnchor.constraint(equalTo: self.selectedPlaceView.categoriesView.bottomAnchor, constant: 0).isActive = true
        skView.leftAnchor.constraint(equalTo: self.selectedPlaceView.categoriesView.leftAnchor, constant: 0).isActive = true
        skView.rightAnchor.constraint(equalTo: self.selectedPlaceView.categoriesView.rightAnchor, constant: 0).isActive = true
        
        DispatchQueue.main.async {
            self.skView.frame = self.selectedPlaceView.categoriesView.bounds
            self.skView.needsUpdateConstraints()
            self.skView.setNeedsLayout()
            self.skView.setNeedsDisplay()
        }
        
        floatingCollectionScene = BubblesScene(size: skView.bounds.size)
        skView.presentScene(floatingCollectionScene)
        
        for category in self.categories {
            addBubble(named: category)
        }
        
    }
    
    private func addBubble(named name: String) {
        let newNode = BubbleNode.instantiate(named: name)
        floatingCollectionScene.addChild(newNode)
    }
    
    private func commitSelection() {
        floatingCollectionScene.performCommitSelectionAnimation()
    }
    
    func configureReviewsView() {
        self.selectedPlaceView.yelpReviewButton.addTarget(self, action: #selector(showYelpPage), for: .touchUpInside)
    }
    
    @objc func showYelpPage() {
        if let urlString = self.yelpURL {
            let url = URL(string: urlString)!
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    func configureMapView() {
        self.selectedPlaceView.mapViewDirectionsButton.setTitleColor(FlatBlackDark(), for: .normal)
        grabMapSnapshot()
    }
    
    func configureAboutView() {
        self.selectedPlaceView.aboutViewTitleLabel.text = "More Info"
        self.selectedPlaceView.aboutViewContentLabel.text = "\(place.record.address)\n\(place.record.city), \(place.record.state) \(place.record.zipCode)\n\n\(place.record.phoneNumber)"
    }
    
    func acquirePictures() {
        
        let header: HTTPHeaders = [
            "Authorization": "Bearer Mxkbvkgu6VYllYtDz5Oppicd1FiPg2G6QBj2yiKw3nUlIaB1BUCSHAThlEMb_vF4Np5iNpYjNLuC_clWi-2yXAo_WTLzabGmeoAaNHwehd2MTOZwyYRX5fu741WsWnYx"
        ]
        
        let url: String = "https://api.yelp.com/v3/businesses/\(place.record.id)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                
                self.yelpURL = json["url"].string
                
                self.categories = json["categories"].map { $0.1["title"].string! }
                self.configureCategoriesView()
                
                self.photoURLs![0] = json["photos"][0].string
                self.photoURLs![1] = json["photos"][1].string
                self.photoURLs![2] = json["photos"][2].string
                
                for photoURL in self.photoURLs! {
                    if let url = photoURL {
                        ImageLoader.shared.getImageFromURL(for: URL(string: url)!) { image in
                            if let image = image {
                                self.photos.append(image)
                                self.selectedPlaceView.imageViewPageControl.numberOfPages += 1
                            }
                        }
                    }
                }
                
            }
        }
        
    }
    
    func acquireReviews() {
        
        let header: HTTPHeaders = [
            "Authorization": "Bearer Mxkbvkgu6VYllYtDz5Oppicd1FiPg2G6QBj2yiKw3nUlIaB1BUCSHAThlEMb_vF4Np5iNpYjNLuC_clWi-2yXAo_WTLzabGmeoAaNHwehd2MTOZwyYRX5fu741WsWnYx"
        ]
        
        let url: String = "https://api.yelp.com/v3/businesses/\(place.record.id)/reviews"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                
                for i in 0...2 {
                    if let review = json["reviews"][i]["text"].string,
                        let user = json["reviews"][i]["user"]["name"].string,
                        let rating = json["reviews"][i]["rating"].int {
                        self.reviews.append(Review(name: user, text: review, score: rating))
                    }
                }
                
                self.selectedPlaceView.reviewViewContentLabel.text = self.reviews[self.reviewIndex].text
                self.selectedPlaceView.reviewViewAnnotationLabel.text = "-\(self.reviews[self.reviewIndex].name)"
                
                self.selectedPlaceView.reviewStar0.isHidden = true
                self.selectedPlaceView.reviewStar1.isHidden = true
                self.selectedPlaceView.reviewStar2.isHidden = true
                self.selectedPlaceView.reviewStar3.isHidden = true
                self.selectedPlaceView.reviewStar4.isHidden = true
                
                switch self.reviews[self.reviewIndex].score {
                case 0:
                    break
                case 1:
                    self.selectedPlaceView.reviewStar0.isHidden = false
                case 2:
                    self.selectedPlaceView.reviewStar0.isHidden = false
                    self.selectedPlaceView.reviewStar1.isHidden = false
                case 3:
                    self.selectedPlaceView.reviewStar0.isHidden = false
                    self.selectedPlaceView.reviewStar1.isHidden = false
                    self.selectedPlaceView.reviewStar2.isHidden = false
                case 4:
                    self.selectedPlaceView.reviewStar0.isHidden = false
                    self.selectedPlaceView.reviewStar1.isHidden = false
                    self.selectedPlaceView.reviewStar2.isHidden = false
                    self.selectedPlaceView.reviewStar3.isHidden = false
                default:
                    self.selectedPlaceView.reviewStar0.isHidden = false
                    self.selectedPlaceView.reviewStar1.isHidden = false
                    self.selectedPlaceView.reviewStar2.isHidden = false
                    self.selectedPlaceView.reviewStar3.isHidden = false
                    self.selectedPlaceView.reviewStar4.isHidden = false
                }
                
                self.reviewIndex += 1
                
            }
        }
    }
    
    @objc func updateReviews() {
        
        let newText = self.reviews[self.reviewIndex].text
        let newName = "-\(self.reviews[self.reviewIndex].name)"
        
        UIView.transition(with: self.selectedPlaceView.reviewView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.selectedPlaceView.reviewViewContentLabel.text = newText
            self.selectedPlaceView.reviewViewAnnotationLabel.text = newName
            
            self.selectedPlaceView.reviewStar0.isHidden = true
            self.selectedPlaceView.reviewStar1.isHidden = true
            self.selectedPlaceView.reviewStar2.isHidden = true
            self.selectedPlaceView.reviewStar3.isHidden = true
            self.selectedPlaceView.reviewStar4.isHidden = true
            
            switch self.reviews[self.reviewIndex].score {
            case 0:
                break
            case 1:
                self.selectedPlaceView.reviewStar0.isHidden = false
            case 2:
                self.selectedPlaceView.reviewStar0.isHidden = false
                self.selectedPlaceView.reviewStar1.isHidden = false
            case 3:
                self.selectedPlaceView.reviewStar0.isHidden = false
                self.selectedPlaceView.reviewStar1.isHidden = false
                self.selectedPlaceView.reviewStar2.isHidden = false
            case 4:
                self.selectedPlaceView.reviewStar0.isHidden = false
                self.selectedPlaceView.reviewStar1.isHidden = false
                self.selectedPlaceView.reviewStar2.isHidden = false
                self.selectedPlaceView.reviewStar3.isHidden = false
            default:
                self.selectedPlaceView.reviewStar0.isHidden = false
                self.selectedPlaceView.reviewStar1.isHidden = false
                self.selectedPlaceView.reviewStar2.isHidden = false
                self.selectedPlaceView.reviewStar3.isHidden = false
                self.selectedPlaceView.reviewStar4.isHidden = false
            }
            
        }, completion: nil)
        
        self.reviewIndex += 1
        self.reviewIndex %= self.reviews.count
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
        let camera = SnapshotCamera(lookingAtCenter: location, zoomLevel: 12)
        
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
        
        rideShareMenu.cancelButton.addTarget(self, action: #selector(hideRideShareMenu), for: .touchUpInside)
        rideShareMenu.mapsButton.addTarget(self, action: #selector(goToMaps), for: .touchUpInside)
        
        // TODO: not currently working because -
        // Uber requires a unique bundle identifier for app to work, which
        // we currently don't have because multiple developers on our team are using the same idenitifer
        // (edu.sandiego.comp495.Cheers) -- this will work if idenifier was unique, but we'd have to refactor
        // database authentication/other .plist properties to do that
        prepareUber()
        
        // TODO: this is not working because of bug in Lyft SDK source - opened as Issue #18 on their GitHub
        // lol @ Lyft for having a broken production API, or I'm just stupid for not knowing how to use it
        prepareLyft()
        
        if let window = UIApplication.shared.keyWindow {
            background.backgroundColor = UIColor(white: 0, alpha: 0.5)
            background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideRideShareMenu)))
            window.addSubview(background)
            window.addSubview(rideShareMenu)
            
            let height: CGFloat = 384.0
            let y = window.frame.height - height
            
            rideShareMenu.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            background.frame = window.frame
            background.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.background.alpha = 1
                self.rideShareMenu.frame = CGRect(x: 0, y: y, width: self.rideShareMenu.frame.width, height: self.rideShareMenu.frame.height)
            }, completion: nil)
        }
        
    }
    
    @objc func hideRideShareMenu() {
        UIView.animate(withDuration: 0.5) {
            self.background.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.rideShareMenu.frame = CGRect(x: 0, y: window.frame.height, width: self.rideShareMenu.frame.width, height: self.rideShareMenu.frame.height)
            }
        }
    }
    
    @objc func goToMaps() {
        
        if let sourceLocation = UserLocations.shared.location?.coordinate {
            let source = MKMapItem(placemark: MKPlacemark(coordinate: sourceLocation))
            source.name = "My Location"
            
            let destinationLatitude = place.record.latitude
            let destinationLongitude = place.record.longitude
            let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude)))
            destination.name = place.record.name
            
            MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
        
        hideRideShareMenu()
        
    }
    
    func prepareUber() {
        let builder = RideParametersBuilder()
        builder.pickupLocation = UserLocations.shared.location!
        builder.dropoffLocation = CLLocation(latitude: CLLocationDegrees(place.record.latitude), longitude: CLLocationDegrees(place.record.longitude))
        builder.pickupNickname = "My Location"
        builder.dropoffNickname = place.record.name
        builder.dropoffAddress = "\(place.record.name), \(place.record.city)"
        let rideParameters = builder.build()
        
        let uberButton = RideRequestButton(rideParameters: rideParameters)
        uberButton.titleLabel?.centerXAnchor.constraint(equalTo: uberButton.centerXAnchor, constant: 0).isActive = true
        uberButton.titleLabel?.centerYAnchor.constraint(equalTo: uberButton.centerYAnchor, constant: 0).isActive = true
        rideShareMenu.uberView.addSubview(uberButton)
        
        DispatchQueue.main.async {
            uberButton.frame = self.rideShareMenu.uberView.frame
            uberButton.needsUpdateConstraints()
            uberButton.setNeedsLayout()
            uberButton.setNeedsDisplay()
        }
    }
    
    func prepareLyft() {
        let lyftButton = LyftButton()
        let pickupLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(UserLocations.shared.currentLatitude!), longitude: CLLocationDegrees(UserLocations.shared.currentLatitude!))
        let dropOffLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(place.record.latitude), longitude: CLLocationDegrees(place.record.longitude))
        lyftButton.configure(rideKind: LyftSDK.RideKind.Standard, pickup: pickupLocation, destination: dropOffLocation)
        lyftButton.style = .hotPink
        lyftButton.backgroundColor = .clear
        lyftButton.layer.cornerRadius = 10
        
        rideShareMenu.lyftView.addSubview(lyftButton)
        
        DispatchQueue.main.async {
            lyftButton.frame = self.rideShareMenu.uberView.frame
            lyftButton.needsUpdateConstraints()
            lyftButton.setNeedsLayout()
            lyftButton.setNeedsDisplay()
        }
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
            } else if sender == "History" {
                performSegue(withIdentifier: "barToHistory", sender: nil)
            }
        }
    }
}

extension SelectedPlaceViewController: SwiftPhotoGalleryDataSource, SwiftPhotoGalleryDelegate {
    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        if let photoURLs = self.photoURLs {
            return photoURLs.count
        } else {
            return 0
        }
    }
    
    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        return self.photos[forIndex]
    }
    
    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        self.selectedPlaceView.imageViewPageControl.currentPage = self.gallery.currentPage
        self.selectedPlaceView.imageViewImage.image = photos[selectedPlaceView.imageViewPageControl.currentPage]
        dismiss(animated: true, completion: nil)
    }
}

extension UIView {
    func addDashedBorder() {
        let color = FlatRed().cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [6,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
}
