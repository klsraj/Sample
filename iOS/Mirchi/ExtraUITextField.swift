//
//  UITextField+Extensions.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 07/07/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import UIKit

@objc protocol ExtraUITextFieldDelegate{
    @objc optional func willDeleteBackward(textField:UITextField)
}

class ExtraUITextField: UITextField{
    
    @IBOutlet var extraDelegate: ExtraUITextFieldDelegate?
    
    override func deleteBackward() {
        extraDelegate?.willDeleteBackward?(textField: self)
        super.deleteBackward()
    }
    
    //Prevent cut-off of first character after textfield expands
    override var intrinsicContentSize: CGSize{
        var size = super.intrinsicContentSize
        size.width += 8
        return size
    }
}
