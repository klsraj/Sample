//
//  AlertSwapAnimator.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 26/01/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import UIKit

class AlertSwapAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    var duration: TimeInterval = 0.3
    let presenting:Bool
    
    init(presenting:Bool){
        self.presenting = presenting
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        
        let fromAlertViewController = transitionContext.viewController(forKey: .from) as! BaseAlertViewController
        let toAlertViewController = transitionContext.viewController(forKey: .to) as! BaseAlertViewController
        
        fromAlertViewController.loadViewIfNeeded()
        fromAlertViewController.view.layoutIfNeeded()
        toAlertViewController.loadViewIfNeeded()
        toAlertViewController.view.layoutIfNeeded()
        
        let fromAlertView = fromAlertViewController.alertView!

        toView.layoutIfNeeded()
        fromView.layoutIfNeeded()
        
        containerView.addSubview(toView)
        toView.alpha = 0
        
        let canvas = UIView(frame: containerView.bounds)
        canvas.backgroundColor = .clear
        containerView.addSubview(canvas)
        
        toAlertViewController.alertView!.alpha = 1.0
        toAlertViewController.alertView!.transform = .identity
        
        let toAlertSnapshot = toAlertViewController.alertView.snapshotView(afterScreenUpdates: true)!
        toAlertSnapshot.frame = frameForSnapshot(originalView: toAlertViewController.alertView, container: containerView)
        canvas.addSubview(toAlertSnapshot)
        
        let toAlertTransform = CGAffineTransform(translationX: 0, y: containerView.bounds.size.height - toAlertSnapshot.frame.origin.y).scaledBy(x: 0.1, y: 0.1)
        let fromAlertTransform = CGAffineTransform(translationX: 0, y: -fromAlertView.frame.origin.y - fromAlertView.frame.size.height).scaledBy(x: 0.1, y: 0.1)
            
        toAlertSnapshot.alpha = 0.0
        toAlertSnapshot.transform = presenting ? toAlertTransform : fromAlertTransform
        fromAlertView.alpha = 1.0
        fromAlertView.transform = .identity
        
        UIView.animate(withDuration: duration, animations: {

            toAlertSnapshot.alpha = 1.0
            toAlertSnapshot.transform = .identity
            fromAlertView.alpha = 0.0
            fromAlertView.transform = self.presenting ? fromAlertTransform : toAlertTransform
            
        }, completion: { (complete) in
            toView.alpha = 1.0
            canvas.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    func frameForSnapshot(originalView:UIView, container:UIView) -> CGRect{
        return container.convert(originalView.bounds, from: originalView)
    }

}
