//
//  AlertAnimator.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 24/01/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import UIKit

class AlertAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
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
        
        let alertViewController = transitionContext.viewController(forKey: presenting ? .to : .from) as! BaseAlertViewController
        //alertViewController.alertView.alpha = 1.0
        //alertViewController.alertView.transform = .identity
        
        alertViewController.loadViewIfNeeded()
        alertViewController.view.layoutIfNeeded()
        toView.layoutIfNeeded()
        fromView.layoutIfNeeded()
        
        let outgoingSnapshot = containerView.snapshotView(afterScreenUpdates: true)!
        let duplicateOutgoingSnapshot = containerView.snapshotView(afterScreenUpdates: true)!
        let incomingSnapshot = toView.snapshotView(afterScreenUpdates: true)!
        
        if presenting{
            containerView.addSubview(outgoingSnapshot)
        }
        
        containerView.addSubview(toView)
        
        let canvas = UIView(frame: containerView.bounds)
        canvas.backgroundColor = .clear
        canvas.addSubview(presenting ? duplicateOutgoingSnapshot : incomingSnapshot)
        containerView.addSubview(canvas)
        
        let visualEffectView = UIVisualEffectView(frame: containerView.bounds)
        visualEffectView.effect = UIBlurEffect(style: .dark)
        canvas.addSubview(visualEffectView)
        
        let alertSnapshot = alertViewController.alertView.snapshotView(afterScreenUpdates: true)!
        
        alertSnapshot.frame = frameForSnapshot(originalView: alertViewController.alertView, container: containerView)
        visualEffectView.contentView.addSubview(alertSnapshot)
        
        let alertTransform = CGAffineTransform(translationX: 0, y: containerView.bounds.size.height - alertSnapshot.frame.origin.y).scaledBy(x: 0.1, y: 0.1)
        
        if presenting{
            visualEffectView.alpha = 0.0
            
            alertSnapshot.alpha = 0.0
            alertSnapshot.transform = alertTransform
            
            UIView.animate(withDuration: duration, animations: {
                
                visualEffectView.alpha = 1.0
                
                alertSnapshot.alpha = 1.0
                alertSnapshot.transform = .identity
                
            }, completion: { (complete) in
                canvas.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
        }else{
            
            visualEffectView.alpha = 1.0
            
            alertSnapshot.alpha = 1.0
            
            UIView.animate(withDuration: duration, animations: {
                
                visualEffectView.alpha = 0.0
                
                alertSnapshot.alpha = 0.0
                alertSnapshot.transform = alertTransform
                
            }, completion: { (complete) in
                canvas.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
    
    func frameForSnapshot(originalView:UIView, container:UIView) -> CGRect{
        return container.convert(originalView.bounds, from: originalView)
    }

}
