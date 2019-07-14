//
//  GradientView.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 25/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {

    let gradientLayer = CAGradientLayer()
    
    @IBInspectable var startColor:UIColor = .blue
    @IBInspectable var endColor:UIColor = .green
    @IBInspectable var startPosition:CGPoint = CGPoint(x: 0.5, y: 0)
    @IBInspectable var endPosition:CGPoint = CGPoint(x: 0.5, y: 0.5)
    
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
    
    override func draw(_ rect: CGRect) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.startPoint = startPosition
        gradient.endPoint = endPosition
        layer.insertSublayer(gradient, at: 0)
    }
    
}
