//
//  MessageCellText.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 16/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

class MessageCellText: MessageCell {
    
    @IBOutlet weak var messageTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageTextView.linkTextAttributes = [
            NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.underlineColor : messageTextView.textColor as Any
        ]
    }
    
    override func calculateCellSize(message:Message, itemSize:CGSize) -> CGSize{
        let textSpacing = contentSpacing()
        let stringSize = ((message.text ?? "") as NSString).boundingRect(with: CGSize(width: itemSize.width - textSpacing.width, height: CGFloat.greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading], attributes: [NSAttributedString.Key.font : messageTextView.font ?? UIFont.systemFont(ofSize: 15.0)], context: nil).integral
        return CGSize(width: itemSize.width, height: stringSize.height + textSpacing.height)
    }

}
