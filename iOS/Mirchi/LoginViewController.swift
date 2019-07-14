//
//  LoginViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 14/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import MBProgressHUD
import DropletIF

class LoginViewController: AuthFormBaseViewController{
    
    let FBReadPermissions = ["public_profile","email","user_friends","user_birthday","user_gender"]
    var loginProgressHUD:MBProgressHUD?
    var firebaseLoginComplete:Bool = false
    var facebookScrapeComplete:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AuthService.shared.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let progressHUD = loginProgressHUD{
            progressHUD.hide(animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapLogin(_ sender: Any) {
        FBSDKLoginManager().logIn(withReadPermissions: FBReadPermissions, from: self) { (result, error) in
            
            //If error or no result, alert user
            guard let result = result, error == nil else {
                self.handleError(error: error)
                return
            }
            
            //If login was cancelled, do nothing
            guard !result.isCancelled else { return }
            
            //If required permissions not granted, logout and alert user
            /*guard result.declinedPermissions.count == 0 else {
                FBSDKLoginManager().logOut()
                self.handleError(error: nil)
                return
            }*/
            
            //Everything looks good, login to FireBase
            self.performLoginWith(accessToken: result.token.tokenString)
        }
    }
    
    func performLoginWith(accessToken:String){
        facebookScrapeComplete = false
        loginProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        AuthService.shared.loginWithFB(accessToken: accessToken, onComplete: {
            self.facebookScrapeComplete = true
            self.completeFBLogin()
        }) { (error) in
            DispatchQueue.main.async {
                self.loginProgressHUD?.hide(animated: true)
            }
            self.handleError(error: error)
        }
    }
    
    func checkForPhoneAuthVerification(){
        if let verificationID = UserDefaults.standard.string(forKey: "PhoneAuthVerificationID"), let phoneNumber = UserDefaults.standard.string(forKey: "PhoneAuthPhoneNumber"){
            if let phoneEntryVC = storyboard?.instantiateViewController(withIdentifier: "PhoneEntryViewController"), let codeEntryVC = storyboard?.instantiateViewController(withIdentifier: "CodeEntryViewController") as? CodeEntryViewController, var navVCs = navigationController?.viewControllers{
                codeEntryVC.verificationID = verificationID
                codeEntryVC.phoneNumber = phoneNumber
                navVCs.append(contentsOf: [phoneEntryVC, codeEntryVC])
                navigationController?.setViewControllers(navVCs, animated: false)
            }
        }
    }
    
    func handleError(error:Error?){
        let alert = Utility.alertForError(transitioningDelegate: self, error: error, onDismiss: nil)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLoading(){
        loginProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    func hideLoading(){
        DispatchQueue.main.async {
            self.loginProgressHUD?.hide(animated: true)
        }
    }
    
    func completeFBLogin(){
        guard firebaseLoginComplete && facebookScrapeComplete else {
            return
        }
        hideLoading()
        guard let currentUser = AuthService.shared.currentUser as? CustomUser else {
            AuthService.shared.logout(onComplete: nil, onError: nil)
            return
        }
        if currentUser.privacyAccepted() && currentUser.userSetupComplete() && currentUser.images.count > 0{
            guard let rootVC = presentingViewController as? RootViewController else {
                AuthService.shared.logout(onComplete: nil, onError: nil)
                return
            }
            /*rootVC.dismissLoginViewController(animated: true, completion: {
                UserService.shared.loadUsers()
            })*/
            rootVC.didLogin()
        }else{
            if !currentUser.privacyAccepted(){
                performSegue(withIdentifier: "toPrivacyViewController", sender: nil)
            }else if currentUser.userSetupComplete(){
                performSegue(withIdentifier: "toPictureViewController", sender: nil)
            }else{
                performSegue(withIdentifier: "toFirstNameViewController", sender: nil)
            }
        }
    }
    
    // MARK: - Segues
    
    @IBAction func unwindToLogin(sender: UIStoryboardSegue){
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "showTerms", let destVC = (segue.destination as? UINavigationController)?.viewControllers.first as? WebViewController{
            destVC.url = URL(string: NSLocalizedString("TERMS_OF_USE_URL", comment: "Link terms button on Login screen should open"))!
        }
        if segue.identifier == "showPrivacy", let destVC = (segue.destination as? UINavigationController)?.viewControllers.first as? WebViewController{
            destVC.url = URL(string: NSLocalizedString("PRIVACY_POLICY_URL", comment: "Link terms button on Login screen should open"))!
        }
        if let toVC = segue.destination as? CodeEntryViewController, let verificationID = sender as? String{
            toVC.verificationID = verificationID
        }
    }
}

extension LoginViewController: AuthServiceDelegate{
    func didLogin() {
        /*hideLoading()
        guard let rootVC = presentingViewController as? RootViewController else {
            AuthService.shared.logout(onComplete: nil, onError: nil)
            return
        }
        AuthService.shared.delegate = rootVC
        rootVC.didLogin()*/
        firebaseLoginComplete = true
        completeFBLogin()
    }
    
    func loggedInLoadingUser() {
        showLoading()
    }
    
    func didLogoutWith(error: Error?) {
        if let error = error{
            handleError(error: error)
        }
    }
    
    func loadedCurrentUser() {
        firebaseLoginComplete = true
        completeFBLogin()
    }
}
