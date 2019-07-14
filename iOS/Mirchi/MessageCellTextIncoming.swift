//
//  TextCellIncoming.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 16/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import FirebaseUI
import DropletIF

@IBDesignable
class MessageCellTextIncoming: MessageCellText {
    
    @IBOutlet weak var profileImageButton: ProfileImageButton!
    
    @IBOutlet weak var profileImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageWidthConstraint: NSLayoutConstraint!
    
    override func configureCell(message: Message, user:User) {
        if let image = user.images.first{
            profileImageButton.imageView?.sd_setImage(with: Storage.storage().reference().child(image), placeholderImage: nil, completion: { (image, error, cache, ref) in
                if let image = image{
                    self.profileImageButton.setImage(image, for: .normal)
                }
            })
            
        }else{
            profileImageButton.setImage(nil, for: .normal)
        }
        if message.type == .text, let text = message.text{
            messageTextView.text = text
        }
        updateTimestampLabelWith(date: message.timestamp)
        layoutIfNeeded()
    }
    
    @IBAction func didTapProfile(_ sender: Any) {
        delegate?.didTapProfile()
    }
    
    override func contentSpacing() -> CGSize {
        var size = super.contentSpacing()
        size.width += profileImageLeadingConstraint.constant + profileImageWidthConstraint.constant
        return size
    }
}
