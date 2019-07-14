//
//  TextCellOutgoing.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 16/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

@IBDesignable
class MessageCellTextOutgoing: MessageCellText {
    
    override func configureCell(message:Message, user:User) {
        if message.type == .text, let text = message.text{
            messageTextView.text = text
        }
        updateTimestampLabelWith(date: message.timestamp)
        layoutIfNeeded()
    }
}
