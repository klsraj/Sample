//
//  UIColor+Extensions.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 30/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

extension UIColor {
    var hsba:(h: CGFloat, s: CGFloat,b: CGFloat,a: CGFloat) {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h: h, s: s, b: b, a: a)
    }
}
