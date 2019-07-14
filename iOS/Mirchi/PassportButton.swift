//
//  PassportButton.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 29/01/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import UIKit

class PassportButton: ShapeButton {

    @IBInspectable var homeLocationImage:UIImage!
    @IBInspectable var awayLocationImage:UIImage!
    var isHome:Bool = true{
        didSet{
            setImage(isHome ? homeLocationImage : awayLocationImage, for: .normal)
        }
    }

}
