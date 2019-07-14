//
//  UITextViewPlaceholder.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 17/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

class UITextViewPlaceholder: UITextView {

    @IBInspectable var placeholder:String = ""{
        didSet{
            self.text = placeholder
        }
    }
    @IBInspectable var placeholderTextColor:UIColor = .lightGray{
        didSet{
            self.textColor = placeholderTextColor
        }
    }
    @IBInspectable var defaultTextColor:UIColor = .darkText
    
}
