//
//  AddLocationViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 10/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import DropletIF

protocol AddLocationDelegate{
    func didAddNewLocation()
}

class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    var delegate:AddLocationDelegate?
    var currentMarker:GMSMarker?
    var searchController: UISearchController?
    var resultsController: GMSAutocompleteResultsViewController?
    @IBOutlet var closeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        resultsController = GMSAutocompleteResultsViewController()
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        resultsController?.autocompleteFilter = filter
        resultsController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController?.searchResultsUpdater = resultsController
        searchController?.searchBar.barTintColor = UIColor.white
        searchController?.searchBar.tintColor = UIColor.white
        
        
        searchController?.searchBar.sizeToFit()
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            if let textfield = searchController?.searchBar.value(forKey: "searchField") as? UITextField {
                textfield.textColor = UIColor.blue
                if let backgroundview = textfield.subviews.first {
                    
                    // Background color
                    backgroundview.backgroundColor = UIColor.white
                    
                    // Rounded corner
                    backgroundview.layer.cornerRadius = 10;
                    backgroundview.clipsToBounds = true;
                    
                }
            }
        } else {
            // Fallback on earlier versions
            navigationItem.titleView = searchController?.searchBar
        }
        
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        
    }

    @IBAction func didTapClose(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addMapMarker(place:GMSPlace){
        mapView.clear()
        let position = place.coordinate
        currentMarker = GMSMarker(position: position)
        
        let iconView = UIImageView(image: UIImage(named: "MapLocationIcon")?.withRenderingMode(.alwaysTemplate))
        iconView.tintColor = Colors.darkGreen
        currentMarker!.iconView = iconView
        
        currentMarker!.title = place.name
        currentMarker!.snippet = place.formattedAddress
        currentMarker!.map = mapView
        mapView.animate(toLocation: place.coordinate)
        mapView.selectedMarker = currentMarker
    }
    
}

extension AddLocationViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let infoWindow = InfoWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
        infoWindow.translatesAutoresizingMaskIntoConstraints = false
        infoWindow.locationLabel.text = marker.title
        return infoWindow
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let name = marker.snippet ?? marker.title else {
            mapView.clear()
            return
        }
        let location = LabelledLocation(name: name, coordinate: marker.position)
        UserSettings.shared.locations.append(location)
        UserSettings.shared.activeLocation = UserSettings.shared.locations.count - 1
        delegate?.didAddNewLocation()
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        //mapView.selectedMarker = currentMarker
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.selectedMarker = currentMarker
    }
}

extension AddLocationViewController: GMSAutocompleteResultsViewControllerDelegate{
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        addMapMarker(place: place)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
