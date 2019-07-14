//
//  SuperLikeLimitViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 23/01/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

class SuperLikeLimitViewController: BaseLimitViewController {
    
    override func viewDidLoad() {
        if let currentUser = AuthService.shared.currentUser{
            startDate = currentUser.superLikeLimitLifted
        }
        super.viewDidLoad()
        
        if StoreService.shared.isSubscribed(){
            upgradeButton.setTitle(NSLocalizedString("ULTRA_LIKE_LIMIT_ALERT_CLOSE_BUTTON", comment: ""), for: .normal)
        }
    }

}
