//
//  ShapeView.swift
//  Sparker
//
//  Created by Samuel Harrison on 28/07/2017.
//  Copyright © 2017 Samuel Harrison. All rights reserved.
//

import UIKit

@IBDesignable
class ShapeView: UIView {
    
    @IBInspectable var borderWidth:CGFloat = 0.0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor:UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var cornerRadius:CGFloat = 0.0{
        didSet{
            self.layer.cornerRadius = cornerRadius
            self.clipsToBounds = true
        }
    }
    
    @IBInspectable var isCircular:Bool = false{
        didSet{
            self.layer.cornerRadius = self.bounds.size.height/2
            self.clipsToBounds = true
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
