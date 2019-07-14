//
//  SelectLocationViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 10/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import SwipeCellKit
import DropletIF

class SelectLocationViewController: UITableViewController{

    @IBOutlet weak var doneButton: UIBarButtonItem!
    var settingsChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCloseButton()
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
    
    func configureCloseButton(){
        if navigationController?.viewControllers.count ?? 0 > 1{
            navigationItem.rightBarButtonItems?.removeAll()
        }
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "toAddLocationViewController" && Config.Features.passportIsPremium && !StoreService.shared.isSubscribed(){
            performSegue(withIdentifier: "toUpgradeViewController", sender: nil)
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toVC = (segue.destination as? UINavigationController)?.viewControllers.first as? AddLocationViewController{
            toVC.delegate = self
        }
    }

}

extension SelectLocationViewController{ // UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserSettings.shared.locations.count + 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        if indexPath.row == 0{
            // My Current Location Cell
            cell = tableView.dequeueReusableCell(withIdentifier: "CurrentLocationCell", for: indexPath)
            cell.detailTextLabel?.text = LocationService.shared.currentLocation?.name
            cell.accessoryType = (UserSettings.shared.activeLocation == -1 ? .checkmark : .none)
            
        }else if indexPath.row == tableView.numberOfRows(inSection: 0) - 1{
            // Add New Location Button
            cell = tableView.dequeueReusableCell(withIdentifier: "AddLocationCell", for: indexPath)
            
        }else{
            // Other Location Cell
            cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
            let location = UserSettings.shared.locations[indexPath.row - 1]
            cell.textLabel?.text = location.name
            cell.accessoryType = (UserSettings.shared.activeLocation == indexPath.row - 1 ? .checkmark : .none)
            (cell as! SwipeTableViewCell).delegate = self
        }
        
        
        return cell
    }
}

extension SelectLocationViewController{ // UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1{
            // Add New Location Tapped
            return
        }else{
            if indexPath.row == 0{
                UserSettings.shared.activeLocation = -1
            }else{
                if Config.Features.passportIsPremium && !StoreService.shared.isSubscribed(){
                    performSegue(withIdentifier: "toUpgradeViewController", sender: nil)
                    return
                }
                UserSettings.shared.activeLocation = indexPath.row - 1
            }
            settingsChanged = true
            tableView.reloadData()
        }
    }
}

extension SelectLocationViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: NSLocalizedString("PASSPORT_LOCATION_DELETE_BUTTON", comment: "Delete Button")) { (action, indexPath) in
            //Set index, allowing for 'currentLocation' cell
            let index = indexPath.row - 1
            
            guard UserSettings.shared.locations.count > index else { return }
            UserSettings.shared.locations.remove(at: index)
            if UserSettings.shared.activeLocation == index{
                UserSettings.shared.activeLocation = -1
            }else if UserSettings.shared.activeLocation > index{
                UserSettings.shared.activeLocation -= 1
            }
            
            self.tableView.beginUpdates()
            action.fulfill(with: .delete)
            
            // Shouldn't need this, bug in SwipeCellKit?
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            self.tableView.endUpdates()
        }
        
        //deleteAction.image = UIImage(named:"UnmatchIcon")
        
        return [deleteAction]
    }
}

extension SelectLocationViewController: AddLocationDelegate{
    func didAddNewLocation() {
        tableView.reloadData()
        settingsChanged = true
    }
}
