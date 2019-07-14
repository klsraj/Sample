//
//  IAmGenderTableViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 16/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

class IAmGenderTableViewController: UITableViewController {

    @IBOutlet weak var manCell: UITableViewCell!
    @IBOutlet weak var womanCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateSelection()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateSelection(){
        if AuthService.shared.currentUser?.gender == Genders.male.rawValue{
            manCell.accessoryType = .checkmark
            womanCell.accessoryType = .none
        }else if AuthService.shared.currentUser?.gender == Genders.female.rawValue{
            manCell.accessoryType = .none
            womanCell.accessoryType = .checkmark
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0{
            if AuthService.shared.currentUser?.gender == Genders.male.rawValue{
                return
            }
            AuthService.shared.currentUser?.gender = Genders.male.rawValue
            UserService.shared.resetUsers()
        }else if indexPath.row == 1{
            if AuthService.shared.currentUser?.gender == Genders.female.rawValue{
                return
            }
            AuthService.shared.currentUser?.gender = Genders.female.rawValue
            UserService.shared.resetUsers()
        }
        updateSelection()
    }


}
