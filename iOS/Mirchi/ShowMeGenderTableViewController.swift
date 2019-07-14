//
//  ShowMeGenderTableViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 12/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

class ShowMeGenderTableViewController: UITableViewController {

    @IBOutlet weak var menCell: UITableViewCell!
    @IBOutlet weak var womenCell: UITableViewCell!
    @IBOutlet weak var menAndWomenCell: UITableViewCell!
    var settingsChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateSelection()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if settingsChanged{
            UserService.shared.resetUsers()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSelection(){
        if AuthService.shared.currentUser?.interestedIn == Genders.male.rawValue{
            menCell.accessoryType = .checkmark
            womenCell.accessoryType = .none
//            menAndWomenCell.accessoryType = .none
        }else if AuthService.shared.currentUser?.interestedIn == Genders.female.rawValue{
            menCell.accessoryType = .none
            womenCell.accessoryType = .checkmark
//            menAndWomenCell.accessoryType = .none
        }else if AuthService.shared.currentUser?.interestedIn == Genders.maleAndFemale.rawValue{
            menCell.accessoryType = .none
            womenCell.accessoryType = .none
//            menAndWomenCell.accessoryType = .checkmark
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0{
            if AuthService.shared.currentUser?.interestedIn == Genders.male.rawValue{
                return
            }
            AuthService.shared.currentUser?.interestedIn = Genders.male.rawValue
            settingsChanged = true
        }else if indexPath.row == 1{
            if AuthService.shared.currentUser?.interestedIn == Genders.female.rawValue{
                return
            }
            AuthService.shared.currentUser?.interestedIn = Genders.female.rawValue
            settingsChanged = true
        }else{
            if AuthService.shared.currentUser?.interestedIn == Genders.maleAndFemale.rawValue{
                return
            }
            AuthService.shared.currentUser?.interestedIn = Genders.maleAndFemale.rawValue
            settingsChanged = true
        }
        updateSelection()
    }

}
