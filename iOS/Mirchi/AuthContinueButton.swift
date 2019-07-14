//
//  AuthContinueButton.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 18/12/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

@IBDesignable
class AuthContinueButton: UIButton {

    @IBInspectable var isRounded:Bool = false{
        didSet{
            if isRounded{
                self.layer.cornerRadius = self.bounds.height/2.0
            }
        }
    }
    
    @IBInspectable var enabledBackgroundColor:UIColor = Colors.darkPurple
    @IBInspectable var disabledBackgroundColor:UIColor = UIColor(white: 0.9, alpha: 1.0)
    var loadingSpinner:UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
    var loading:Bool = false{
        didSet{
            if loading{
                setTitle("", for: .normal)
                isEnabled = false
                self.loadingSpinner.startAnimating()
            }else{
                setTitle(buttonTitle, for: .normal)
                isEnabled = true
                self.loadingSpinner.stopAnimating()
            }
        }
    }
    var buttonTitle:String?
    
    override var isEnabled: Bool{
        didSet{
            updateBackground()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonTitle = self.titleLabel?.text
        updateBackground()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        self.addSubview(loadingSpinner)
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        loadingSpinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loadingSpinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func updateBackground(){
        if isEnabled{
            self.backgroundColor = enabledBackgroundColor
        }else{
            self.backgroundColor = disabledBackgroundColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
