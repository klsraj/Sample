//
//  FirstNameViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 16/11/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

class FirstNameViewController: AuthFormBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let name = AuthService.shared.currentUser?.name, !name.isEmpty{
            textField.text = name
            textFieldEditingChanged(textField)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        AuthService.shared.logout(onComplete: {
            self.navigationController?.popToRootViewController(animated: true)
        }, onError: nil)
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
        guard AuthService.shared.currentUser != nil, let nameText = textField.text else { return }
        AuthService.shared.currentUser!.name = nameText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.performSegue(withIdentifier: "toDobViewController", sender: nil)
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        continueButton.isEnabled = (sender.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0) > 1
    }
    
    @IBAction func unwindToFirstName(sender: UIStoryboardSegue){
    }
    

}
