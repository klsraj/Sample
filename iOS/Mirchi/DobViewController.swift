//
//  DobViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 16/11/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

class DobViewController: AuthFormBaseViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let dob = AuthService.shared.currentUser?.birthdate{
            datePicker.setDate(dob, animated: false)
            fillTextFieldWith(date: dob)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        fillTextFieldWith(date: sender.date)
    }
    
    func fillTextFieldWith(date:Date){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        textField.text = dateFormatter.string(from: date)
        continueButton.isEnabled = true
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
        guard AuthService.shared.currentUser != nil, validateAge() else { return }
        AuthService.shared.currentUser!.birthdate = datePicker.date
        self.performSegue(withIdentifier: "toGenderViewController", sender: nil)
    }
    
    func validateAge()->Bool{
        if Calendar.current.dateComponents([.year], from: datePicker.date, to: Date()).year! < Config.Features.minimumUserAge{
            let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("DOB_ENTRY_NOT_OLD_ENOUGH_ALERT_TITLE", comment: "Not Old Enough Alert Title"), message: NSLocalizedString("DOB_ENTRY_NOT_OLD_ENOUGH_ALERT_BODY", comment: "Not Old Enough Alert Body"))
            alert.addAction(title: NSLocalizedString("DOB_ENTRY_NOT_OLD_ENOUGH_ALERT_CLOSE_BUTTON", comment: "Dismiss Button"), style: .default, handler: {
                AuthService.shared.deleteAccount(onComplete: nil)
                self.navigationController?.popToRootViewController(animated: true)
            })
            alert.transitioningDelegate = self
            present(alert, animated: true, completion: nil)
            return false
        }else{
            return true
        }
    }
    
    @IBAction func unwindToDOB(sender: UIStoryboardSegue){
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }
}
