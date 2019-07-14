//
//  ProfileImageButton.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 25/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

@IBDesignable
class ProfileImageButton: UIButton {

    @IBInspectable var isCircular:Bool = true{
        didSet{
            if isCircular{
                self.layer.cornerRadius = self.bounds.width/2.0
                self.clipsToBounds = true
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
    
    override func awakeFromNib() {
        imageView?.contentMode = .scaleAspectFill
    }

}
