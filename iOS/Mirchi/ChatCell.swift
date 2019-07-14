//
//  ChatCell.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 29/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import FirebaseUI
import SwipeCellKit
import DropletIF

class ChatCell: SwipeTableViewCell {
    
    @IBOutlet weak var profileImageView: ShapeImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadIndicatorContainer: RoundedView!
    @IBOutlet weak var unreadIndicator: RoundedView!
    
    
    // Selecting cell clears unread indicator background color, override
    // setSelected and setHighlighted to fix.
    override func setSelected(_ selected: Bool, animated: Bool) {
        let containerColor = unreadIndicatorContainer.backgroundColor
        let indicatorColor = unreadIndicator.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if(selected) {
            unreadIndicatorContainer.backgroundColor = containerColor
            unreadIndicator.backgroundColor = indicatorColor
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let containerColor = unreadIndicatorContainer.backgroundColor
        let indicatorColor = unreadIndicator.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if(highlighted) {
            unreadIndicatorContainer.backgroundColor = containerColor
            unreadIndicator.backgroundColor = indicatorColor
        }
    }
    
    func configureCell(chat:Chat){
        
        if let image = chat.opponent.images.first{
            profileImageView.sd_setImage(with: Storage.storage().reference().child(image))
        }else{
            profileImageView.image = nil
        }
        nameLabel.text = chat.opponent.name
        
        messageLabel.text = NSLocalizedString(chat.last_message_text ?? "", comment: "")
        messageLabel.font = chat.haveUnreadMessages() ? UIFont.boldSystemFont(ofSize: messageLabel.font.pointSize) : UIFont.systemFont(ofSize: messageLabel.font.pointSize)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        dateLabel.text = formatter.string(from: chat.updated_at)
        
        unreadIndicatorContainer.isHidden = !chat.haveUnreadMessages()
        
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let view = gestureRecognizer.view,
            let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer
        {
            let translation = gestureRecognizer.translation(in: view)
            
            if swipeOffset == 0 && translation.x > 0{
                return false
            }
            return abs(translation.y) <= abs(translation.x)
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
