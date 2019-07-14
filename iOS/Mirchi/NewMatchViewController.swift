//
//  NewMatchViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 25/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import FirebaseStorage
import DropletIF

protocol NewMatchViewControllerDelegate{
    func goToChatWithUser(user:User)
}

class NewMatchViewController: UIViewController {
    
    var delegate:NewMatchViewControllerDelegate?
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var subheading: UILabel!
    @IBOutlet weak var currentUserImage: ShapeImageView!
    @IBOutlet weak var opponentImage: ShapeImageView!
    @IBOutlet weak var sendMessageButton: ShapeButton!
    @IBOutlet weak var closeButton: ShapeButton!
    
    var user:User!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureForUser()
    }
    
    func configureForUser(){
        subheading.text = String.init(format: NSLocalizedString("NEW_MATCH_SUBHEADING", comment: "You Matched Screen Subheading"), user.name ?? "someone")
        
        if let currentUser = AuthService.shared.currentUser, currentUser.images.count > 0{
            currentUserImage.sd_setImage(with: Storage.storage().reference().child(currentUser.images[0]), placeholderImage: nil)
        }
        
        if user.images.count > 0{
            opponentImage.sd_setImage(with: Storage.storage().reference().child(user.images[0]), placeholderImage: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapSendMessage(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: {
            self.delegate?.goToChatWithUser(user: self.user)
        })
    }
    
    @IBAction func didTapKeepSwiping(_ sender: Any) {
        if let presentingVC = presentingViewController{
            presentingVC.dismiss(animated: true, completion: {
                if let interstitial = AdsService.shared.getInterstitial(){
                    interstitial.present(fromRootViewController: presentingVC)
                }
            })
        }
    }    

}
