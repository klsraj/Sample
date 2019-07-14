//
//  ShapeButton.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 25/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

@IBDesignable
class ShapeButton: UIButton {

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
    
    @IBInspectable var gradientBackground:Bool = false
    @IBInspectable var startColor:UIColor = .blue
    @IBInspectable var endColor:UIColor = .green
    @IBInspectable var startPosition:CGPoint = CGPoint(x: 0.5, y: 0)
    @IBInspectable var endPosition:CGPoint = CGPoint(x: 0.5, y: 0.5)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(ovalIn: bounds).cgPath
        if isRounded{
            self.layer.cornerRadius = self.bounds.height/2.0
        }
    }
    
    /*override func draw(_ rect: CGRect) {
        if gradientBackground{
            let gradient = CAGradientLayer()
            gradient.frame = self.bounds
            gradient.colors = [startColor.cgColor, endColor.cgColor]
            gradient.startPoint = startPosition
            gradient.endPoint = endPosition
            layer.insertSublayer(gradient, at: 0)
        }
    }*/
}
