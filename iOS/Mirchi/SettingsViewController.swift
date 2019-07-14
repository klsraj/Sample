//
//  SettingsViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 15/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import MapKit
import MARKRangeSlider
import NMRangeSlider
import MBProgressHUD
import StoreKit
import DropletIF

class SettingsViewController: UITableViewController {
    
    
    @IBOutlet weak var shareCell: UITableViewCell!
    @IBOutlet weak var restoreCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    @IBOutlet weak var locationHeading: UILabel!
    @IBOutlet weak var locationSubheading: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    
    @IBOutlet weak var interestedInLabel: UILabel!
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var ageSlider: NMRangeSlider!
    
    @IBOutlet weak var showMeSwitch: UISwitch!
    
    @IBOutlet weak var matchNotificationSwitch: UISwitch!
    @IBOutlet weak var messageNotificationSwitch: UISwitch!
    @IBOutlet weak var soundsSwitch: UISwitch!
    
    var progressHUD:MBProgressHUD? = nil
    
    
    var settingsChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ageSlider.stepValue = 1.0
        ageSlider.minimumRange = 1.0
        ageSlider.minimumValue = 18.0
        ageSlider.maximumValue = 60.0
        ageSlider.tintColor = distanceSlider.tintColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureForSettings()
        StoreService.shared.delegate = self
        LocationService.shared.addDelegate(delegate: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if settingsChanged{
            UserService.shared.resetUsers()
            self.settingsChanged = false
        }
        StoreService.shared.delegate = nil
        LocationService.shared.removeDelegate(delegate: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureForSettings(){
        
        if let currentUser = AuthService.shared.currentUser{
            ageSlider.setUpperValue(Float(currentUser.maxAge), animated: false)
            ageSlider.setLowerValue(Float(currentUser.minAge), animated: false)
        }
        distanceSlider.setValue(Float(UserSettings.shared.maxDistance), animated: false)
        updateLocationCell()
        updateDistance()
        updateAge()
        updateInterestedIn()
        
        showMeSwitch.isOn = UserSettings.shared.showMe
        matchNotificationSwitch.isOn = UserSettings.shared.matchNotifications
        messageNotificationSwitch.isOn = UserSettings.shared.messageNotifications
        soundsSwitch.isOn = UserSettings.shared.inAppSounds
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ageDidChange(_ sender: Any) {
        updateAge()
        settingsChanged = true
    }
    
    @IBAction func distanceDidChange(_ sender: UISlider) {
        updateDistance()
        settingsChanged = true
    }
    
    func updateLocationCell(){
        if UserSettings.shared.activeLocation == -1{
            locationHeading.text = NSLocalizedString("SETTINGS_LOCATION_CURRENT_LOCATION_HEADING", comment: "Settings Location Title My Current Location")
        }else{
            locationHeading.text = NSLocalizedString("SETTINGS_LOCATION_PASSPORT_LOCATION_HEADING", comment: "Settings Location Title Passport")
        }
        locationSubheading.text = LocationService.shared.searchLocation?.name
    }
    
    func updateAge(){
        let minAge = Int(round(ageSlider.lowerValue))
        let maxAge = Int(round(ageSlider.upperValue))
        ageLabel.text = String.init(format: NSLocalizedString("SETTINGS_AGE_SLIDER_RANGE", comment: "Settings Age Slider Label"), minAge, (maxAge < 60 ? "\(maxAge)" : "60+"))
        AuthService.shared.currentUser?.minAge = minAge
        AuthService.shared.currentUser?.maxAge = maxAge
    }
    
    func updateDistance(){
        let distFormatter = MKDistanceFormatter()
        let distValue = round(Double(distanceSlider.value))
        distanceLabel.text = distFormatter.string(fromDistance: distValue * 1000)
        UserSettings.shared.maxDistance = Int(distValue)
    }
    
    func updateInterestedIn(){
        if AuthService.shared.currentUser?.interestedIn == Genders.male.rawValue{
            interestedInLabel.text = NSLocalizedString("SETTINGS_INTERESTED_IN_MEN_SELECTED", comment: "Interested In Men")
        }else if AuthService.shared.currentUser?.interestedIn == Genders.female.rawValue{
            interestedInLabel.text = NSLocalizedString("SETTINGS_INTERESTED_IN_WOMEN_SELECTED", comment: "Interested In Women")
        }else if AuthService.shared.currentUser?.interestedIn == Genders.maleAndFemale.rawValue{
            interestedInLabel.text = NSLocalizedString("SETTINGS_INTERESTED_IN_MEN_AND_WOMEN_SELECTED", comment: "Interested In Men & Women")
        }
    }
    
    @IBAction func showMeDidChange(_ sender: UISwitch) {
        UserSettings.shared.showMe = sender.isOn
    }
    
    @IBAction func matchNotificationDidChange(_ sender: UISwitch) {
        UserSettings.shared.matchNotifications = sender.isOn
    }
    
    @IBAction func messageNotificationDidChange(_ sender: UISwitch) {
        UserSettings.shared.messageNotifications = sender.isOn
    }
    
    @IBAction func soundsDidChange(_ sender: UISwitch) {
        UserSettings.shared.inAppSounds = sender.isOn
    }
    
    func displayShareMenu(){
        let shareItems:[AnyObject] = [
            NSLocalizedString("SETTINGS_SHARE_MESSAGE", comment: "Share App Text") as AnyObject,
            URL(string: NSLocalizedString("SETTINGS_SHARE_URL", comment: "Settings share URL"))! as AnyObject
        ]
        let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityVC.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .openInIBooks, .print, .saveToCameraRoll]
        if #available(iOS 11.0, *) {
            activityVC.excludedActivityTypes?.append(.markupAsPDF)
        }
        self.present(activityVC, animated: true, completion: nil)
    }
    
    // MARK: - Segues
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "toUpgradeVC" && StoreService.shared.isSubscribed(){
            let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("SETTINGS_ALREADY_SUBSCRIBED_ALERT_TITLE", comment: "Settings already subscribed alert title"), message: NSLocalizedString("SETTINGS_ALREADY_SUBSCRIBED_ALERT_BODY", comment: "Settings already subscribed alert body"))
            alert.addAction(title: NSLocalizedString("SETTINGS_ALREADY_SUBSCRIBED_ALERT_CLOSE_BUTTON", comment: "Settings already subscribed alert close button"), style: .default, handler: nil)
            alert.transitioningDelegate = self
            present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toVC = segue.destination as? WebViewController, let identifier = segue.identifier{
            switch(identifier){
            case "toPrivacyPolicy":
                toVC.url = URL(string: NSLocalizedString("PRIVACY_POLICY_URL", comment: ""))
            case "toTermsOfService":
                toVC.url = URL(string: NSLocalizedString("TERMS_OF_USE_URL", comment: ""))
            case "toSubscriptionInformation":
                toVC.url = URL(string: NSLocalizedString("SUBSCRIPTION_INFO_URL", comment: ""))
            case "toSupport":
                toVC.url = URL(string: NSLocalizedString("SUPPORT_URL", comment: ""))
            default:
                print("Unknown identifier")
            }
        }
    }

}

extension SettingsViewController{ //UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        if cell == shareCell{
            displayShareMenu()
        }else if cell == restoreCell{
            StoreService.shared.refreshReceipt()
        }else if cell == logoutCell{
            AuthService.shared.logout(onComplete: nil, onError: nil)
        }
    }
}

extension SettingsViewController: LocationServiceDelegate{
    func locationDidChange() {
        updateLocationCell()
    }
}

extension SettingsViewController: StoreServiceDelegate{
    func transactionInProgress() {
        if progressHUD == nil{
            progressHUD = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
        }
        progressHUD!.mode = .indeterminate
        progressHUD!.label.text = nil
        progressHUD!.detailsLabel.text = nil
    }
    
    func receiptRefreshComplete() {
        if progressHUD == nil{
            progressHUD = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
        }
        progressHUD!.mode = .text
        progressHUD!.label.text = NSLocalizedString("SETTINGS_HUD_RESTORE_COMPLETE", comment: "Upgrade HUD Restore Complete")
        progressHUD!.detailsLabel.text = nil
        progressHUD!.hide(animated: true, afterDelay: 2.5)
    }
    
    func transactionFailed(transaction: SKPaymentTransaction) {
        restoreFailed(error: transaction.error)
    }
    
    func productsLoadComplete(error: Error?) {
        if error != nil{
            restoreFailed(error: error)
        }
    }
    
    func restoreFailed(error:Error?){
        if let error = error{
            let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("SETTINGS_RESTORE_ERROR_ALERT_TITLE", comment: "Error Alert Title"), message: error.localizedDescription)
            alert.addAction(title: NSLocalizedString("SETTINGS_RESTORE_ERROR_ALERT_CLOSE_BUTTON", comment: "Dismiss Button"), style: .cancel, handler: nil)
            alert.transitioningDelegate = self
            present(alert, animated: true, completion: nil)
        }
        if progressHUD == nil{
            progressHUD = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
        }
        progressHUD!.mode = .text
        progressHUD!.label.text = NSLocalizedString("SETTINGS_HUD_RESTORE_FAILED", comment: "Upgrade HUD Restore Failed")
        progressHUD!.detailsLabel.text = nil
        progressHUD!.hide(animated: true, afterDelay: 2.5)
    }
}
