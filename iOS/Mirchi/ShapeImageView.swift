//
//  ProfileImageView.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 25/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

@IBDesignable
class ShapeImageView: UIImageView {

    @IBInspectable var isCircular:Bool = true{
        didSet{
            if isCircular{
                self.layer.cornerRadius = self.bounds.width/2.0
            }else{
                self.layer.cornerRadius = cornerRadius
            }
        }
    }
    
    @IBInspectable var cornerRadius:CGFloat = 0.0{
        didSet{
            if !isCircular{
                self.layer.cornerRadius = cornerRadius
            }else{
                self.layer.cornerRadius = self.bounds.width/2.0
            }
        }
    }
    
    @IBInspectable var borderWidthPercentage:CGFloat = 0.0{
        didSet{
            self.layer.borderWidth = borderWidthPercentage * self.bounds.size.height
        }
    }
    
    @IBInspectable var borderColor:UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutCornerRadius()
        
    }
    
    func layoutCornerRadius(){
        if isCircular{
            self.layer.cornerRadius = self.bounds.width/2.0
        }else{
            self.layer.cornerRadius = cornerRadius
        }
    }

}
