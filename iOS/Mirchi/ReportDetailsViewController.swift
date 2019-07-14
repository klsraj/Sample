//
//  ReportDetailsViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 25/01/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

class ReportDetailsViewController: BaseAlertViewController {
    
    var delegate:ReportViewControllerDelegate?
    var user:User!
    var reportReason:String?

    @IBOutlet weak var centreVerticalConstraint:NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsTextField: UITextField!
    @IBOutlet weak var reportButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let reportTitle:String = {
            guard let name = user.name else { return NSLocalizedString("REPORT_DETAILS_ALERT_HEADING", comment: "Report Button") }
            return String(format: NSLocalizedString("REPORT_DETAILS_ALERT_HEADING_WITH_NAME", comment: "Report Button (with user's name)"), name)
        }()
        titleLabel.text = reportTitle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addKeyboardObservers()
        detailsTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detailsTextField.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObservers()
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
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect{
            centreVerticalConstraint.constant = -(frame.size.height - bottomLayoutGuide.length)/2.0
            
            UIView.animate(withDuration: notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        centreVerticalConstraint.constant = 0
        UIView.animate(withDuration: notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0, animations: {
            self.view.layoutIfNeeded()
        })
    }

    @IBAction func didTapReport(_ sender: Any) {
        ChatService.shared.reportUser(user: user, reason: reportReason ?? "Other", notes: detailsTextField.text ?? "") { (error) in
            if let error = error{
                let alert = Utility.alertForError(transitioningDelegate: self, error: error, onDismiss: nil)
                self.present(alert, animated: true, completion: nil)
            }else{
                self.reportSent()
            }
        }
    }
    
    func reportSent(){
        let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("REPORT_SENT_ALERT_TITLE", comment: "Report has been sent alert title"), message: NSLocalizedString("REPORT_SENT_ALERT_BODY", comment: "Report has been sent alert body"))
        alert.addAction(title: NSLocalizedString("REPORT_SENT_ALERT_CLOSE_BUTTON", comment: "Report has been sent alert close button"), style: .default) {
            self.delegate?.didSendReport(user: self.user)
        }
        alert.transitioningDelegate = self
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        //delegate?.didCancelReport()
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

extension ReportDetailsViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
