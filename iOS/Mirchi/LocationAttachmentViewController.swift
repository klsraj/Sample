//
//  LocationAttachmentViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 26/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import GoogleMaps
import DropletIF

protocol LocationAttachmentDelegate{
    func sendLocation(location:CLLocation?)
}

class LocationAttachmentViewController: UIViewController {
    
    var delegate:LocationAttachmentDelegate?
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    var previousMyLocation:CLLocation?
    var observerAttached = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if observerAttached{
            mapView.removeObserver(self, forKeyPath: #keyPath(GMSMapView.myLocation))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureForMessage(message:Message){
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem?.title = NSLocalizedString("LOCATION_ATTACHMENT_VIEWING_CLOSE_BUTTON", comment: "Close Button")
        guard let location = message.location else { return }
        loadViewIfNeeded()
        mapView.isMyLocationEnabled = true
        addMapMarker(location: location, name:NSLocalizedString("LOCATION_ATTACHMENT_VIEWING_LOCATION_MARKER_LABEL", comment: "Map Current Location Marker Label"))
    }
    
    func configureForCurrentLocation(delegate:LocationAttachmentDelegate){
        self.delegate = delegate
        self.navigationItem.rightBarButtonItem = sendButton
        self.navigationItem.leftBarButtonItem?.title = NSLocalizedString("LOCATION_ATTACHMENT_SENDING_CANCEL_BUTTON", comment: "Cancel Button")
        self.navigationItem.title = NSLocalizedString("LOCATION_ATTACHMENT_SENDING_SEND_BUTTON", comment: "Picking Location Attachment Title")
        loadViewIfNeeded()
        mapView.isMyLocationEnabled = true
        mapView.animate(toZoom: 14)
        mapView.addObserver(self, forKeyPath: #keyPath(GMSMapView.myLocation), options: .new, context: nil)
        observerAttached = true
    }
    
    func addMapMarker(location:CLLocation, name:String){
        mapView.clear()
        let currentMarker = GMSMarker(position: location.coordinate)
        
        let iconView = UIImageView(image: UIImage(named: "MapLocationIcon")?.withRenderingMode(.alwaysTemplate))
        iconView.tintColor = Colors.darkGreen
        currentMarker.iconView = iconView
        
        currentMarker.title = name
        currentMarker.map = mapView
        mapView.animate(to: GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 14.0))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(GMSMapView.myLocation), let location = mapView.myLocation{
            currentLocationUpdated(location: location)
        }
    }
    
    func currentLocationUpdated(location:CLLocation){
        if let previousLocation = previousMyLocation, location.distance(from: previousLocation) < 100{
            return
        }
        mapView.animate(toLocation: location.coordinate)
        previousMyLocation = location
    }
    
    @IBAction func didTapSend(_ sender: Any) {
        guard let location = mapView.myLocation else { return }
        delegate?.sendLocation(location: location)
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapCancel(_ sender: Any) {
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
