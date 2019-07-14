//
//  CodeEntryViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 14/11/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import FirebaseAuth
import DropletIF

class CodeEntryViewController: AuthFormBaseViewController{
    
    var verificationID:String!
    var phoneNumber:String!
    @IBOutlet weak var codeField: CodeEntryField!
    @IBOutlet weak var resendButton: UIButton!
    var resendTimer:Timer?
    var resendCount:Int = 30
    @IBOutlet weak var resendActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        codeField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if verificationID != nil{
            storeVerificationDetails()
            initializeResendTimer()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Code Entry View Disappeared!")
        removeVerificationDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func storeVerificationDetails(){
        UserDefaults.standard.set(verificationID, forKey: "PhoneAuthVerificationID")
        UserDefaults.standard.set(phoneNumber, forKey: "PhoneAuthPhoneNumber")
        UserDefaults.standard.synchronize()
    }
    
    func removeVerificationDetails(){
        UserDefaults.standard.removeObject(forKey: "PhoneAuthVerificationID")
        UserDefaults.standard.removeObject(forKey: "PhoneAuthPhoneNumber")
    }
    
    func initializeResendTimer(){
        resendCount = 30
        resendTimer?.invalidate()
        resendTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateResendTimer), userInfo: nil, repeats: true)
        self.resendActivityIndicator.stopAnimating()
        self.resendButton.isHidden = false
    }
    
    @objc func updateResendTimer(){
        resendCount -= 1
        if resendCount > 0{
            resendButton.setTitle(String(format: NSLocalizedString("CODE_ENTRY_RESEND_BUTTON_WITH_COUNTDOWN", comment: "Phone Auth Resend Button With Time"), resendCount), for: .normal)
            resendButton.isEnabled = false
        }else{
            resendButton.setTitle(NSLocalizedString("CODE_ENTRY_RESEND_BUTTON", comment: "Phone Auth Resend Button Enabled"), for: .normal)
            resendButton.isEnabled = true
        }
        
    }
        
    @IBAction func didTapResend(_ sender: Any) {
        resendButton.isHidden = true
        resendActivityIndicator.startAnimating()
        codeField.clearCodeEntry()
        self.view.isUserInteractionEnabled = false
        AuthService.shared.loginWithPhone(phoneNumber: phoneNumber) { (verificationID, error) in
            self.continueButton.loading = false
            self.view.isUserInteractionEnabled = true
            self.initializeResendTimer()
            guard let veriID = verificationID, error == nil else{
                self.handleError(error: error, onDismiss: nil)
                return
            }
            self.verificationID = veriID
            self.storeVerificationDetails()
        }
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        signInWithCode(code: codeField.codeEntry)
    }
    
    func signInWithCode(code:String){
        codeField.resignFirstResponder()
        continueButton.loading = true
        view.isUserInteractionEnabled = false
        AuthService.shared.delegate = self
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
        Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
            if let error = error{
                self.continueButton.loading = false
                self.view.isUserInteractionEnabled = true
                self.handleError(error: error, onDismiss: {
                    self.codeField.becomeFirstResponder()
                })
            }
        }
        /*Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error{
                self.continueButton.loading = false
                self.view.isUserInteractionEnabled = true
                self.handleError(error: error, onDismiss: {
                    self.codeField.becomeFirstResponder()
                })
            }
        }*/
    }
    
    func checkUserProfileComplete(){
        guard let currentUser = AuthService.shared.currentUser as? CustomUser else { return }
        currentUser.delegate = nil
        if !currentUser.privacyAccepted(){
            self.performSegue(withIdentifier: "toPrivacyViewController", sender: nil)
            return
        }else if !currentUser.userSetupComplete(){
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

extension CodeEntryViewController: AuthServiceDelegate{
    func didLogin() {
        print("Logged in, have cached user, waiting for user to load")
    }
    
    func loggedInLoadingUser() {
        print("Logged in, don't have cached user, waiting for user to load")
    }
    
    func didLogoutWith(error: Error?) {
        print("Did log out for some reason!")
        navigationController?.popToRootViewController(animated: true)
    }
    
    func loadedCurrentUser() {
        checkUserProfileComplete()
    }
}

extension CodeEntryViewController: CodeEntryFieldDelegate{
    func codeEntryComplete(code: String) {
        continueButton.isEnabled = true
        signInWithCode(code: code)
    }
    
    func codeEntryIncomplete() {
        continueButton.isEnabled = false
    }
}
