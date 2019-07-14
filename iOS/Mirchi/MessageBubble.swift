//
//  MessageBubble.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 25/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

@IBDesignable
class MessageBubble: UIView {

    @IBInspectable var cornerRadius:CGFloat = 0.0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth:CGFloat = 0.0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor:UIColor = .clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }

}
