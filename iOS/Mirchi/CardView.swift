//
//  CardView.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 04/02/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import UIKit

class CardView: UIView {
    
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
    
    @IBInspectable var shadowOffset: CGPoint = CGPoint.zero {
        didSet {
            layer.shadowOffset = CGSize(width: shadowOffset.x, height: shadowOffset.y)
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 3.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    var previousBounds:CGRect = CGRect.zero

    
}
