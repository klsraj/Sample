//
//  PrivacyViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 18/05/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

class PrivacyViewController: WebViewController {
    
    var wasNavbarHidden:Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        wasNavbarHidden = self.navigationController?.isNavigationBarHidden ?? false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(wasNavbarHidden, animated: true)
    }

    override func viewDidLoad() {
        self.url = URL(string: NSLocalizedString("PRIVACY_POLICY_URL", comment: ""))
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureCloseButton() {
        //
    }
    
    //User Pressed Decline
    override func didTapClose(_ sender: Any) {
        let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("PRIVACY_DECLINE_ALERT_TITLE", comment: "Title for user declining privacy policy alert."), message: NSLocalizedString("PRIVACY_DECLINE_ALERT_BODY", comment: "Body for user declining privacy policy alert."))
        alert.addAction(title: NSLocalizedString("PRIVACY_DECLINE_ALERT_DECLINE_BUTTON", comment: "Button for user to confirm they decline privacy policy (will log user out)"), style: .destructive) {
            AuthService.shared.logout(onComplete: {
                self.navigationController?.popToRootViewController(animated: true)
            }, onError: nil)
        }
        alert.addAction(title: NSLocalizedString("PRIVACY_DECLINE_ALERT_CANCEL_BUTTON", comment: "Button for user to cancel privacy decline alert"), style: .cancel, handler: nil)
        alert.transitioningDelegate = self
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func didTapAccept(_ sender: Any) {
        let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("PRIVACY_ACCEPT_ALERT_TITLE", comment: "Title for user accepting privacy policy alert."), message: NSLocalizedString("PRIVACY_ACCEPT_ALERT_BODY", comment: "Body for user Accept privacy policy alert."))
        alert.addAction(title: NSLocalizedString("PRIVACY_ACCEPT_ALERT_ACCEPT_BUTTON", comment: "Button for user to confirm they accept privacy policy"), style: .default) {
            self.didConfirmAccept()
        }
        alert.addAction(title: NSLocalizedString("PRIVACY_ACCEPT_ALERT_CANCEL_BUTTON", comment: "Button for user to cancel privacy accept alert"), style: .cancel, handler: nil)
        alert.transitioningDelegate = self
        self.present(alert, animated: true, completion: nil)
    }
    
    func didConfirmAccept(){
        guard let currentUser = AuthService.shared.currentUser as? CustomUser else { return }
        currentUser.privacyAcceptedDate = Date()
        if !currentUser.userSetupComplete(){
            self.performSegue(withIdentifier: "toFirstNameViewController", sender: nil)
            return
        }else if currentUser.images.count == 0{
            self.performSegue(withIdentifier: "toPictureViewController", sender: nil)
            return
        }else if let rootVC = UIApplication.shared.delegate?.window??.rootViewController as? RootViewController{
            AuthService.shared.delegate = rootVC
            rootVC.didLogin()
        }
    }
}
