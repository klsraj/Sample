//
//  RoundedView.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 06/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedView: UIView {
    
    @IBInspectable var circular:Bool = false{
        didSet{
            if circular{
                self.layer.cornerRadius = self.bounds.size.height/2.0
            }else{
                self.layer.cornerRadius = self.cornerRadius
            }
        }
    }

    @IBInspectable var cornerRadius:CGFloat = 0.0{
        didSet{
            if circular{
                self.layer.cornerRadius = self.bounds.size.height/2.0
            }else{
                self.layer.cornerRadius = self.cornerRadius
            }
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
    
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor!.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGPoint = CGPoint.zero {
        didSet {
            layer.shadowOffset = CGSize(width: shadowOffset.x, height: shadowOffset.y)
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        //layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        //layer.shouldRasterize = true
    }
    
}
