//
//  UIButton+Extensions.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 18/12/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

@IBDesignable
class UIButton_Extended: UIButton {

    @IBInspectable var normalBackgroundColor:UIColor?
    @IBInspectable var selectedBackgroundColor:UIColor?
    
    @IBInspectable var isRounded:Bool = true{
        didSet{
            if isRounded{
                self.layer.cornerRadius = self.bounds.height/2.0
            }
        }
    }
    
    @IBInspectable var borderWidthPercentage:CGFloat = 0.0{
        didSet{
            self.layer.borderWidth = borderWidthPercentage * self.bounds.size.height
        }
    }
    
    @IBInspectable var borderColor:UIColor = .clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor!.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.7 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize.zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 3.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    override var isSelected: Bool{
        didSet{
            backgroundColor = isSelected ? selectedBackgroundColor ?? normalBackgroundColor : normalBackgroundColor
        }
    }

}
