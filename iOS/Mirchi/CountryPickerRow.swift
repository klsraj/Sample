//
//  CountryPickerRow.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 10/12/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

class CountryPickerRow: UIView {

    @IBOutlet weak var flagLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var dialCodeLabel: UILabel!
    
    @IBOutlet var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit(){
        Bundle.main.loadNibNamed("CountryPickerRow", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
    }
    
    func configureCountryInfo(info:CountryCodeInfo){
        flagLabel.text = info.countryFlagEmoji() ?? nil
        countryLabel.text = info.localizedCountryName ?? info.countryName ?? nil
        dialCodeLabel.text = "+\(info.dialCode ?? "")"
    }

}
