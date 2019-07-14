//
//  FauxPushAnimator.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 16/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

class FauxPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.25
    var presenting = true
    var originFrame = CGRect.zero
    var cardView:ProfileCardView!
    let interactionController:FauxPushInteractionController?
    
    init(presenting:Bool, interactionController:FauxPushInteractionController?){
        self.presenting = presenting
        self.interactionController = interactionController
        super.init()
    }
    
    // MARK: - Animated Transitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        
        toView.layoutIfNeeded()
        fromView.layoutIfNeeded()
        
        containerView.addSubview(toView)
        
        if presenting{
            toView.transform = CGAffineTransform(translationX: fromView.bounds.size.width, y: 0)
            containerView.bringSubviewToFront(toView)
        }else{
            toView.transform = CGAffineTransform(translationX: -fromView.bounds.size.width, y: 0)
            containerView.bringSubviewToFront(fromView)
        }
        
        if presenting{
            // Presenting Animation
            
            UIView.animate(withDuration: duration, animations: {
                toView.transform = .identity
                fromView.transform = CGAffineTransform(translationX: -fromView.bounds.size.width, y: 0)
            }) { (completed) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
        }else{
            //Dismissing animation
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                fromView.transform = CGAffineTransform(translationX: fromView.bounds.size.width, y: 0)
                toView.transform = .identity
            }, completion: { (completed) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
        }
        
    }
    
    func frameForSnapshot(originalView:UIView, container:UIView) -> CGRect{
        return container.convert(originalView.bounds, from: originalView)
    }

}
