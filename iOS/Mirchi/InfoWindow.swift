//
//  InfoWindow.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 10/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

class InfoWindow: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit(){
        Bundle.main.loadNibNamed("InfoWindow", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
    }

}
