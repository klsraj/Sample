//
//  LikeLimitViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 06/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

class LikeLimitViewController: BaseLimitViewController {

    override func viewDidLoad() {
        if let currentUser = AuthService.shared.currentUser{
            startDate = currentUser.likeLimitLifted
        }
        super.viewDidLoad()
    }

}
