//
//  ReportViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 03/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

protocol ReportViewControllerDelegate{
    func didSendReport(user:User)
    func didCancelReport()
}

class ReportViewController: BaseAlertViewController{

    var delegate:ReportViewControllerDelegate?
    var user:User!
    var reportReason:String?
    @IBOutlet weak var reportMessagesButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView(){
        let reportTitle:String = {
            guard let name = user.name else { return NSLocalizedString("REPORT_ALERT_HEADING", comment: "Report Button") }
            return String(format: NSLocalizedString("REPORT_ALERT_HEADING_WITH_NAME", comment: "Report Button (with user's name)"), name)
        }()
        titleLabel.text = reportTitle
        reportMessagesButton.isHidden = (ChatService.shared.getChatFor(opponent: user) == nil)
    }
    
    @IBAction func didTapOffensiveMessages(_ sender: Any) {
        reportReason = "Offensive Messages"
        sendReport()
    }
    
    @IBAction func didTapOffensiveProfile(_ sender: Any) {
        reportReason = "Offensive Profile"
        sendReport()
    }
    
    @IBAction func didTapSpam(_ sender: Any) {
        reportReason = "Spam"
        sendReport()
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        delegate?.didCancelReport()
    }
    
    func sendReport(){
        ChatService.shared.reportUser(user: user, reason: reportReason ?? "", notes: "") { (error) in
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toVC = segue.destination as? ReportDetailsViewController{
            toVC.delegate = self
            toVC.user = self.user
            toVC.reportReason = self.reportReason
            toVC.transitioningDelegate = self
        }
    }

}

extension ReportViewController: ReportViewControllerDelegate{
    func didSendReport(user: User) {
        self.delegate?.didSendReport(user: user)
    }
    
    func didCancelReport() {
        delegate?.didCancelReport()
    }
}
