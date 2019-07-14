//
//  Utility.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 14/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import FirebaseAuth

class Utility: NSObject {

    static func alertForError(transitioningDelegate: UIViewControllerTransitioningDelegate?, error:Error?, onDismiss:(()->Void)?) -> CustomAlertViewController{ //UIAlertController{
        
        let errorTitle = NSLocalizedString("ERROR_ALERT_TITLE", comment: "Error Alert Title")
        var errorBody = NSLocalizedString("ERROR_ALERT_UNKNOWN_ERROR_BODY", comment: "Unknown Error Alert Body")
        
        var debugMessage:String? = nil
        if let error = error as NSError?{
            switch(error.code){
            case AuthErrorCode.networkError.rawValue:
                errorBody = NSLocalizedString("ERROR_ALERT_NETWORK_ERROR_BODY", comment: "Network Error Alert Body")
            case AuthErrorCode.userDisabled.rawValue:
                errorBody = NSLocalizedString("ERROR_ALERT_BANNED_ERROR_BODY", comment: "Account Disabled Alert Body")
            case AuthErrorCode.invalidVerificationCode.rawValue:
                errorBody = NSLocalizedString("ERROR_ALERT_VERIFICATION_CODE_INVALID_BODY", comment: "Verification Code Invalid Alert Body")
            default:
                break
            }
            debugMessage = "\(error.domain) - \(error.code)"
        }
        
        let alert = CustomAlertViewController.instantiate(title: errorTitle, message: errorBody, debugMessage: debugMessage)
        alert.addAction(title: NSLocalizedString("ERROR_ALERT_CLOSE_BUTTON", comment: "Dismiss Button"), style: .cancel, handler: {
            onDismiss?()
        })
        alert.transitioningDelegate = transitioningDelegate
        return alert
    }
    
    static func alertForErrorMessage(transitioningDelegate: UIViewControllerTransitioningDelegate?, title:String?, message:String?, onDismiss:(()->Void)?) -> CustomAlertViewController{
        let alert = CustomAlertViewController.instantiate(title: title, message: message)
        alert.configureAlert(title: title, message: message)
        alert.addAction(title: NSLocalizedString("ERROR_ALERT_CUSTOM_CLOSE_BUTTON", comment: "Dismiss Button"), style: .cancel, handler: {
            onDismiss?()
        })
        alert.transitioningDelegate = transitioningDelegate
        return alert
    }
}
