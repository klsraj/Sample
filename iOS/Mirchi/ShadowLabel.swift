//
//  ShadowLabel.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 24/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

@IBDesignable
class ShadowLabel: UILabel {

    @IBInspectable var customShadowColor: UIColor? {
        didSet {
            layer.shadowColor = customShadowColor!.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var customShadowOffset: CGPoint = CGPoint.zero {
        didSet {
            layer.shadowOffset = CGSize(width: customShadowOffset.x, height: customShadowOffset.y)
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
}
