//
//  DeleteAccountViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 21/01/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import UIKit
import MBProgressHUD
import DropletIF

class DeleteAccountViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func hideProfile(_ sender: Any) {
        UserSettings.shared.showMe = false
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        let progressHUD = MBProgressHUD.showAdded(to: navigationController!.view, animated: true)
        AuthService.shared.deleteAccount(onComplete: { (error) in
            NotificationCenter.default.post(name: Constants.NotificationName.accountDeleted, object: nil)
            DispatchQueue.main.async {
                progressHUD.hide(animated: true)
            }
            if let error = error{
                let alert = Utility.alertForError(transitioningDelegate: self, error: error, onDismiss: nil)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }

}
