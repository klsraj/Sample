//
//  IAmCommunityTableViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 5/31/19.
//  Copyright © 2019 Samuel Harrison. All rights reserved.
//

import UIKit
import DropletIF

class IAmCommunityTableViewController: UITableViewController {
    

    @IBOutlet weak var noPreferenceCell: UITableViewCell!
    @IBOutlet weak var brahminCell: UITableViewCell!
    @IBOutlet weak var kammaCell: UITableViewCell!
    @IBOutlet weak var kapuCell: UITableViewCell!
    @IBOutlet weak var patelCell: UITableViewCell!
    @IBOutlet weak var rajuCell: UITableViewCell!
    @IBOutlet weak var reddyCell: UITableViewCell!
    @IBOutlet weak var velamaCell: UITableViewCell!
    @IBOutlet weak var vysyaCell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateSelection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSelection(){
        
        guard let currentUser = AuthService.shared.currentUser as? CustomUser else { return }
        if currentUser.community == "No Preference"{
            noPreferenceCell.accessoryType = .checkmark
            brahminCell.accessoryType = .none
            kammaCell.accessoryType = .none
            kapuCell.accessoryType = .none
            patelCell.accessoryType = .none
            rajuCell.accessoryType = .none
            reddyCell.accessoryType = .none
            velamaCell.accessoryType = .none
            vysyaCell.accessoryType = .none
            
        }else if currentUser.community == "Brahmin" {
            noPreferenceCell.accessoryType = .none
            brahminCell.accessoryType = .checkmark
            kammaCell.accessoryType = .none
            kapuCell.accessoryType = .none
            patelCell.accessoryType = .none
            rajuCell.accessoryType = .none
            reddyCell.accessoryType = .none
            velamaCell.accessoryType = .none
            vysyaCell.accessoryType = .none
        }else if currentUser.community == "Kamma" {
            noPreferenceCell.accessoryType = .none
            brahminCell.accessoryType = .none
            kammaCell.accessoryType = .checkmark
            kapuCell.accessoryType = .none
            patelCell.accessoryType = .none
            rajuCell.accessoryType = .none
            reddyCell.accessoryType = .none
            velamaCell.accessoryType = .none
            vysyaCell.accessoryType = .none
        }else if currentUser.community == "Kapu" {
            noPreferenceCell.accessoryType = .none
            brahminCell.accessoryType = .none
            kammaCell.accessoryType = .none
            kapuCell.accessoryType = .checkmark
            patelCell.accessoryType = .none
            rajuCell.accessoryType = .none
            reddyCell.accessoryType = .none
            velamaCell.accessoryType = .none
            vysyaCell.accessoryType = .none
        }else if currentUser.community == "Patel" {
            noPreferenceCell.accessoryType = .none
            brahminCell.accessoryType = .none
            kammaCell.accessoryType = .none
            kapuCell.accessoryType = .none
            patelCell.accessoryType = .checkmark
            rajuCell.accessoryType = .none
            reddyCell.accessoryType = .none
            velamaCell.accessoryType = .none
            vysyaCell.accessoryType = .none
        }else if currentUser.community == "Raju" {
            noPreferenceCell.accessoryType = .none
            brahminCell.accessoryType = .none
            kammaCell.accessoryType = .none
            kapuCell.accessoryType = .none
            patelCell.accessoryType = .none
            rajuCell.accessoryType = .checkmark
            reddyCell.accessoryType = .none
            velamaCell.accessoryType = .none
            vysyaCell.accessoryType = .none
        }else if currentUser.community == "Reddy" {
            noPreferenceCell.accessoryType = .none
            brahminCell.accessoryType = .none
            kammaCell.accessoryType = .none
            kapuCell.accessoryType = .none
            patelCell.accessoryType = .none
            rajuCell.accessoryType = .none
            reddyCell.accessoryType = .checkmark
            velamaCell.accessoryType = .none
            vysyaCell.accessoryType = .none
        }else if currentUser.community == "Velama" {
            noPreferenceCell.accessoryType = .none
            brahminCell.accessoryType = .none
            kammaCell.accessoryType = .none
            kapuCell.accessoryType = .none
            patelCell.accessoryType = .none
            rajuCell.accessoryType = .none
            reddyCell.accessoryType = .none
            velamaCell.accessoryType = .checkmark
            vysyaCell.accessoryType = .none
        }else if currentUser.community == "Vysya" {
            noPreferenceCell.accessoryType = .none
            brahminCell.accessoryType = .none
            kammaCell.accessoryType = .none
            kapuCell.accessoryType = .none
            patelCell.accessoryType = .none
            rajuCell.accessoryType = .none
            reddyCell.accessoryType = .none
            velamaCell.accessoryType = .none
            vysyaCell.accessoryType = .checkmark
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let currentUser = AuthService.shared.currentUser as? CustomUser else { return }
        
        if indexPath.row == 0{
            if currentUser.community == "No Preference"{
                return
            }
            currentUser.community = "No Preference"
            UserService.shared.resetUsers()
        }else if indexPath.row == 1{
            if currentUser.community == "Brahmin"{
                return
            }
            currentUser.community = "Brahmin"
            UserService.shared.resetUsers()
        }else if indexPath.row == 2{
            if currentUser.community == "Kamma"{
                return
            }
            currentUser.community = "Kamma"
            UserService.shared.resetUsers()
        }else if indexPath.row == 3{
            if currentUser.community == "Kapu"{
                return
            }
            currentUser.community = "Kapu"
            UserService.shared.resetUsers()
        }else if indexPath.row == 4{
            if currentUser.community == "Patel"{
                return
            }
            currentUser.community = "Patel"
            UserService.shared.resetUsers()
        }else if indexPath.row == 5{
            if currentUser.community == "Raju"{
                return
            }
            currentUser.community = "Raju"
            UserService.shared.resetUsers()
        }else if indexPath.row == 6{
            if currentUser.community == "Reddy"{
                return
            }
            currentUser.community = "Reddy"
            UserService.shared.resetUsers()
        }else if indexPath.row == 7{
            if currentUser.community == "Velama"{
                return
            }
            currentUser.community = "Velama"
            UserService.shared.resetUsers()
        }else if indexPath.row == 8{
            if currentUser.community == "Vysya"{
                return
            }
            currentUser.community = "Vysya"
            UserService.shared.resetUsers()
        }
        updateSelection()
    }
    
    
}

