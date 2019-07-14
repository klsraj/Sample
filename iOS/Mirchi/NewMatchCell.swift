//
//  NewMatchCell.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 29/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import FirebaseUI
import DropletIF

class NewMatchCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: ShapeImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unreadIndicator: RoundedView!
    
    func configureCell(chat:Chat){
        if chat.opponent.images.count > 0{
            profileImageView.sd_setImage(with: Storage.storage().reference().child(chat.opponent.images[0]))
        }else{
            profileImageView.image = nil
        }
        nameLabel.text = chat.opponent.name
        
        unreadIndicator.isHidden = !chat.haveUnreadMessages()
    }
    
    func configureCell(name:String?, imageUrl:String?){
        if let imageUrlString = imageUrl, let url = URL(string: imageUrlString){
            profileImageView.sd_setImage(with: url, completed: nil)
        }else{
            profileImageView.image = nil
        }
        nameLabel.text = name
        
        if unreadIndicator != nil{
            unreadIndicator.isHidden = true
        }
    }

}
