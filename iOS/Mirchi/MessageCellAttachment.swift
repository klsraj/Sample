//
//  MessageCellAttachment.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 17/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import FirebaseStorage
import DropletIF

class MessageCellAttachment: MessageCell {
    
    @IBOutlet weak var attachmentImageView:UIImageView!
    @IBOutlet weak var attachmentImageViewProportionConstraint:NSLayoutConstraint!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        attachmentImageView.layer.cornerRadius = messageBubble.layer.cornerRadius
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        attachmentImageView.sd_cancelCurrentImageLoad()
        attachmentImageView.image = nil
    }
    
    override func configureCell(message: Message, user: User) {
        if message.type == .location{
            activityIndicator.stopAnimating()
            attachmentImageView.image = UIImage(named: "MessageLocationIcon")?.withRenderingMode(.alwaysTemplate)
        }else if let attachmentRef = message.attachmentThumbRef{
            activityIndicator.startAnimating()
            attachmentImageView.sd_setImage(with: Storage.storage().reference().child(attachmentRef), placeholderImage: nil, completion: { (image, error, cache, ref) in
                if let error = error{
                    print("Error loading image:", error.localizedDescription);
                    return
                }
                self.activityIndicator.stopAnimating()
            })
        }else{
            activityIndicator.stopAnimating()
            attachmentImageView.image = nil
        }
        updateTimestampLabelWith(date: message.timestamp)
    }
    
    override func calculateCellSize(message:Message, itemSize:CGSize) -> CGSize{
        var height = attachmentImageViewProportionConstraint.multiplier * itemSize.width
        height += contentSpacing().height
        return CGSize(width: itemSize.width, height: height)
    }
}
