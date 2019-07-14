//
//  CustomAlertViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 24/01/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import UIKit

class CustomAlertViewController: BaseAlertViewController{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var debugMessageLabel: UILabel!
    
    @IBOutlet weak var destructiveButton: ShapeButton!
    @IBOutlet weak var primaryButton: ShapeButton!
    @IBOutlet weak var cancelButton: ShapeButton!
    
    var destructiveAction:(()->Void)?
    var primaryAction:(()->Void)?
    var cancelAction:(()->Void)?
    
    var destructiveEnabled = false
    var primaryEnabled = false
    var cancelEnabled = false
    
    static func instantiate(title:String?, message:String?) -> CustomAlertViewController{
        /*let alert = UIStoryboard(name: "CustomAlert", bundle: nil).instantiateViewController(withIdentifier: "AlertViewController") as! CustomAlertViewController
        alert.configureAlert(title: title, message: message, debugMessage: nil)
        return alert*/
        return instantiate(title: title, message: message, debugMessage: nil)
    }
    
    static func instantiate(title:String?, message:String?, debugMessage:String?) -> CustomAlertViewController{
        let alert = UIStoryboard(name: "CustomAlert", bundle: nil).instantiateViewController(withIdentifier: "AlertViewController") as! CustomAlertViewController
        alert.configureAlert(title: title, message: message, debugMessage: debugMessage)
        return alert
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureForDisplay()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureForDisplay(){
        destructiveButton.isHidden = !destructiveEnabled
        primaryButton.isHidden = !primaryEnabled
        cancelButton.isHidden = !cancelEnabled
        if (titleLabel.text ?? "").isEmpty{
           titleLabel.isHidden = true
        }
        if (messageLabel.text ?? "").isEmpty{
            messageLabel.isHidden = true
        }
    }
    
    func configureAlert(title:String?, message:String?){
        configureAlert(title: title, message: message, debugMessage: nil)
    }
    
    func configureAlert(title:String?, message:String?, debugMessage:String?){
        loadViewIfNeeded()
        titleLabel.text = title
        messageLabel.text = message
        debugMessageLabel.isHidden = (debugMessage == nil)
        debugMessageLabel.text = debugMessage
    }
    
    func addAction(title:String, style:UIAlertAction.Style, handler:(()->Void)?){
        loadViewIfNeeded()
        switch(style){
        case .cancel:
            cancelButton.setTitle(title, for: .normal)
            cancelEnabled = true
            cancelAction = handler
        case .default:
            primaryButton.setTitle(title, for: .normal)
            primaryEnabled = true
            primaryAction = handler
        case .destructive:
            destructiveButton.setTitle(title, for: .normal)
            destructiveEnabled = true
            destructiveAction = handler
        }
    }
    
    @IBAction func onTapPrimary(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: primaryAction)
    }
    
    @IBAction func onTapDestructive(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: destructiveAction)
    }
    
    @IBAction func onTapCancel(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: cancelAction)
    }
    
    @IBAction func onTapBackground(_ sender: UIGestureRecognizer) {
        let view = sender.view
        let loc = sender.location(in: view)
        if view?.hitTest(loc, with: nil) == sender.view{
            presentingViewController?.dismiss(animated: true, completion: cancelAction)
        }
    }
    
}
