//
//  UIViewController+Extensions.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 24/01/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import UIKit

extension UIViewController: UIViewControllerTransitioningDelegate{
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var animator:UIViewControllerAnimatedTransitioning?
        if presented as? BaseAlertViewController != nil{
            if presenting as? BaseAlertViewController != nil{
                animator = AlertSwapAnimator(presenting:true)
            }else{
                animator = AlertAnimator(presenting:true)
            }
        }else if let presented = presented as? ChatViewController{
            animator = FauxPushAnimator(presenting: true, interactionController: presented.interactionController)
        }else if presented as? ProfileViewController != nil{
            animator = ProfileAnimator(presenting: true, fromCard: true)
        }else if presented as? NewMatchViewController != nil{
            animator = NewMatchAnimator(presenting: true)
        }
        return animator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var animator:UIViewControllerAnimatedTransitioning?
        if dismissed as? BaseAlertViewController != nil{
            if dismissed.presentingViewController as? BaseAlertViewController != nil{
                animator = AlertSwapAnimator(presenting: false)
            }else{
                animator = AlertAnimator(presenting:false)
            }
        }else if let dismissed = dismissed as? ChatViewController{
            animator = FauxPushAnimator(presenting: false, interactionController: dismissed.interactionController)
        }else if dismissed as? ProfileViewController != nil{
            animator = ProfileAnimator(presenting: false, fromCard: true)
        }else if dismissed as? NewMatchViewController != nil{
            animator = NewMatchAnimator(presenting: false)
        }
        return animator
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? FauxPushAnimator,
            let interactionController = animator.interactionController,
            interactionController.inProgress else {
                return nil
        }
        return interactionController
    }
}
