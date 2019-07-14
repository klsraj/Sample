//
//  LocationPermissionRequestViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 12/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import CoreLocation
import DropletIF
import UserNotifications

class LocationPermissionRequestViewController: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LocationService.shared.addDelegate(delegate: self)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocationService.shared.removeDelegate(delegate: self)
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func willEnterForeground(){
        if LocationService.shared.isLocationPermissionGranted(){
            locationAuthorizationChanged()
        }
    }
    
    @IBAction func didTapAllow(_ sender: Any) {
        if LocationService.shared.isLocationPermissionGranted(){
            locationAuthorizationChanged()
        }
        guard CLLocationManager.authorizationStatus() != .denied else{
            showLocationDeniedAlert()
            return
        }
        LocationService.shared.requestLocationPermission()
    }
    
    func showLocationDeniedAlert(){
        let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("LOCATION_PERMISSION_ALERT_TITLE", comment: "Location Permission Alert Title"), message: NSLocalizedString("LOCATION_PERMISSION_ALERT_BODY", comment: "Location Permission Alert Body"))
        alert.addAction(title: NSLocalizedString("LOCATION_PERMISSION_ALERT_SETTINGS_BUTTON", comment: "Settings Button"), style: .default, handler: {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.openURL(settingsUrl)
            }
        })
        alert.addAction(title: NSLocalizedString("LOCATION_PERMISSION_ALERT_CANCEL_BUTTON", comment: "Cancel Button"), style: .cancel, handler: nil)
        alert.transitioningDelegate = self
        self.present(alert, animated: true, completion: nil)
    }
}

extension LocationPermissionRequestViewController: LocationServiceDelegate{
    func locationAuthorizationChanged() {
        if LocationService.shared.isLocationPermissionGranted(){
            LocationService.shared.requestLocation()
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
