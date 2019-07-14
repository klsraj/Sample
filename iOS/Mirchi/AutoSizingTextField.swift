//
//  AutoSizingTextField.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 30/01/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import UIKit

class AutoSizingTextField: UITextField {

    override var intrinsicContentSize: CGSize {
        if isEditing {
            let string = (text ?? "") as NSString
            let size = string.size(withAttributes: typingAttributes)
            return CGSize(width: size.width + (rightView?.bounds.size.width ?? 0) + (leftView?.bounds.size.width ?? 0) + 2, height: size.height)
        }
        return super.intrinsicContentSize
    }

}
