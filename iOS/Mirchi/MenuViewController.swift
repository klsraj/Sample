//
//  MenuViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 09/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import FirebaseStorage
import DropletIF

class MenuViewController: UIViewController{
    
    @IBOutlet weak var profileImageView: ShapeImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var upgradeView: UIView!
    @IBOutlet weak var upgradeScrollView: UIScrollView!
    @IBOutlet weak var upgradePageControl: UIPageControl!
    
    //let profileAnimator = ProfileAnimator()
    var autoScrollTimer:Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(currentUserUpdated), name: NSNotification.Name("currentUserUpdatedNotification") , object: nil)
        // Do any additional setup after loading the view.
        initAutoScrollTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initAutoScrollTimer(){
        autoScrollTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(toNextPage), userInfo: nil, repeats: true)
    }
    
    func configureUpgradePageControl(){
        upgradeScrollView.layoutIfNeeded()
        upgradePageControl.numberOfPages = Int(ceil(upgradeScrollView.contentSize.width / upgradeScrollView.bounds.size.width))
    }
    
    func updateNameLabel(){
        loadViewIfNeeded()
        if let name = AuthService.shared.currentUser?.name{
            if let age = AuthService.shared.currentUser?.age{
                nameLabel.text = String(format: NSLocalizedString("MENU_NAME_AGE_HEADING", comment: "Menu Name & Age Text"), arguments: [name, age])
                return
            }
            nameLabel.text = String(format: NSLocalizedString("MENU_NAME_HEADING", comment: "Menu Name Text"), arguments: [name])
        }
    }
    
    @objc func toNextPage(){
        let toPage = upgradePageControl.currentPage + 1 < upgradePageControl.numberOfPages ? upgradePageControl.currentPage + 1 : 0
        upgradeScrollView.setContentOffset(CGPoint(x: CGFloat(toPage) * upgradeScrollView.bounds.size.width, y: 0), animated: true)
    }
    
    @IBAction func didTapEditProfile(_ sender: Any) {
        performSegue(withIdentifier: "toOwnProfileViewController", sender: true)
    }
    
    @objc func currentUserUpdated(){
        if let image = AuthService.shared.currentUser?.images.first{
            profileImageView.sd_setImage(with: Storage.storage().reference().child(image))
        }else{
            profileImageView.image = nil
        }
        updateNameLabel()
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "toOwnProfileViewController"{
            return AuthService.shared.currentUser != nil
        }else if identifier == "toUpgradeVC" && StoreService.shared.isSubscribed(){
            let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("MENU_ALREADY_SUBSCRIBED_ALERT_TITLE", comment: "Settings already subscribed alert title"), message: NSLocalizedString("MENU_ALREADY_SUBSCRIBED_ALERT_BODY", comment: "Settings already subscribed alert body"))
            alert.addAction(title: NSLocalizedString("MENU_ALREADY_SUBSCRIBED_ALERT_CLOSE_BUTTON", comment: "Settings already subscribed alert close button"), style: .default, handler: nil)
            alert.transitioningDelegate = self
            present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toVC = segue.destination as? ProfileViewController{
            if sender as? Bool == true{
                toVC.toEditScreen = true
            }
            toVC.transitioningDelegate = self
            toVC.user = AuthService.shared.currentUser as! CustomUser
        }
    }

}

extension MenuViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == upgradeScrollView{
            let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.size.width))
            upgradePageControl.currentPage = page
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        autoScrollTimer?.invalidate()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        initAutoScrollTimer()
    }
}
