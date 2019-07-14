//
//  ProfileCardOverlayView.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 19/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import Koloda

class ProfileCardOverlayView: OverlayView {
    
    @IBOutlet weak var likeOverlay: UIView!
    @IBOutlet weak var passOverlay: UIView!
    @IBOutlet weak var superlikeOverlay: UIView!
    
    
    override var overlayState: SwipeResultDirection?  {
        didSet {
            switch overlayState {
            case .left? :
                likeOverlay.alpha = 0
                passOverlay.alpha = 0.75
                superlikeOverlay.alpha = 0
            case .right? :
                likeOverlay.alpha = 0.75
                passOverlay.alpha = 0
                superlikeOverlay.alpha = 0
            case .up? :
                likeOverlay.alpha = 0
                passOverlay.alpha = 0
                superlikeOverlay.alpha = 0.75
            default:
                likeOverlay.alpha = 0
                passOverlay.alpha = 0
                superlikeOverlay.alpha = 0
            }
            
        }
    }

}
