//
//  AuthFormBaseViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 16/11/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import UserNotifications

class AuthFormBaseViewController: UIViewController {
    
    var activeTextField:UITextField?
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var continueButton: AuthContinueButton!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    var initialBottomConstraintConstant:CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        if buttonBottomConstraint != nil{
            initialBottomConstraintConstant = buttonBottomConstraint.constant
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObservers()
        if self.textField != nil{
            self.textField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
        if self.textField != nil{
            self.textField.resignFirstResponder()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObservers(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification){
        guard buttonBottomConstraint != nil else { return }
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect{
            buttonBottomConstraint.constant = frame.size.height - bottomLayoutGuide.length + initialBottomConstraintConstant
            
            UIView.animate(withDuration: notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        if buttonBottomConstraint != nil{
            buttonBottomConstraint.constant = initialBottomConstraintConstant
        }
        UIView.animate(withDuration: notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func handleError(error:Error?, onDismiss:(()->Void)?){
        let alert = Utility.alertForError(transitioningDelegate: self, error: error, onDismiss: onDismiss)
        present(alert, animated: true, completion: nil)
    }
}

extension AuthFormBaseViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(continueButton.isEnabled){
            continueButton.sendActions(for: .touchUpInside)
        }
        return false
    }
}

