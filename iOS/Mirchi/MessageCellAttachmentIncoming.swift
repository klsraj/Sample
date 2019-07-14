//
//  MessageCellAttachmentIncoming.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 17/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import FirebaseUI
import DropletIF

class MessageCellAttachmentIncoming: MessageCellAttachment {
    
    @IBOutlet weak var profileImageButton: ProfileImageButton!
    
    @IBOutlet weak var profileImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageWidthConstraint: NSLayoutConstraint!
    
    override func configureCell(message: Message, user:User) {
        super.configureCell(message: message, user: user)
        if let image = user.images.first{
            profileImageButton.imageView?.sd_setImage(with: Storage.storage().reference().child(image), placeholderImage: nil, completion: { (image, error, cache, ref) in
                if let image = image{
                    self.profileImageButton.setImage(image, for: .normal)
                }
            })
        }else{
            profileImageButton.setImage(nil, for: .normal)
        }
    }
    
    @IBAction func didTapProfile(_ sender: Any) {
        delegate?.didTapProfile()
    }
    
    override func contentSpacing() -> CGSize{
        var size = super.contentSpacing()
        size.width += profileImageLeadingConstraint.constant + profileImageWidthConstraint.constant
        return size
    }
}
