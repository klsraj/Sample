//
//  NewMatchAnimator.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 09/11/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

class NewMatchAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration = 0.4
    var presenting = true
    var originFrame = CGRect.zero
    
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
        
        let newMatchViewController = transitionContext.viewController(forKey: presenting ? .to : .from) as! NewMatchViewController
        
        toView.layoutIfNeeded()
        //newMatchViewController.loadViewIfNeeded()
        //newMatchViewController.view.layoutIfNeeded()
        
        let outgoingSnapshot = fromView.snapshotView(afterScreenUpdates: true)!
        let duplicateOutgoingSnapshot = fromView.snapshotView(afterScreenUpdates: false)!
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
        
        let headingSnapshot = newMatchViewController.heading.snapshotView(afterScreenUpdates: true)!
        let subheadingSnapshot = newMatchViewController.subheading.snapshotView(afterScreenUpdates: false)!
        let currentImageViewSnapshot = newMatchViewController.currentUserImage.snapshotView(afterScreenUpdates: false)!
        let opponentImageViewSnapshot = newMatchViewController.opponentImage.snapshotView(afterScreenUpdates: false)!
        let sendButtonSnapshot = newMatchViewController.sendMessageButton.snapshotView(afterScreenUpdates: false)!
        let closeButtonSnapshot = newMatchViewController.closeButton.snapshotView(afterScreenUpdates: false)!
        
        headingSnapshot.frame = frameForSnapshot(originalView: newMatchViewController.heading, container: containerView)
        subheadingSnapshot.frame = frameForSnapshot(originalView: newMatchViewController.subheading, container: containerView)
        currentImageViewSnapshot.frame = frameForSnapshot(originalView: newMatchViewController.currentUserImage, container: containerView)
        opponentImageViewSnapshot.frame = frameForSnapshot(originalView: newMatchViewController.opponentImage, container: containerView)
        sendButtonSnapshot.frame = frameForSnapshot(originalView: newMatchViewController.sendMessageButton, container: containerView)
        closeButtonSnapshot.frame = frameForSnapshot(originalView: newMatchViewController.closeButton, container: containerView)
        
        visualEffectView.contentView.addSubview(headingSnapshot)
        visualEffectView.contentView.addSubview(subheadingSnapshot)
        visualEffectView.contentView.addSubview(currentImageViewSnapshot)
        visualEffectView.contentView.addSubview(opponentImageViewSnapshot)
        visualEffectView.contentView.addSubview(sendButtonSnapshot)
        visualEffectView.contentView.addSubview(closeButtonSnapshot)
        
        let headingTransform = CGAffineTransform(translationX: 0, y: -headingSnapshot.frame.origin.y)
        let subheadingTransform = CGAffineTransform(translationX: 0, y: -subheadingSnapshot.frame.origin.y)
        let currentImageTransform = CGAffineTransform(translationX: containerView.frame.size.width, y: 0)
        let opponentImageTransform = CGAffineTransform(translationX: -containerView.frame.size.width, y: 0)
        let sendButtonTransform = CGAffineTransform(translationX: 0, y: containerView.frame.size.height - sendButtonSnapshot.frame.origin.y)
        let closeButtonTransform = CGAffineTransform(translationX: 0, y: containerView.frame.size.height - closeButtonSnapshot.frame.origin.y)
        
        if presenting{
            visualEffectView.alpha = 0.0
            
            headingSnapshot.alpha = 0.0
            headingSnapshot.transform = headingTransform
            
            subheadingSnapshot.alpha = 0.0
            subheadingSnapshot.transform = subheadingTransform
            
            currentImageViewSnapshot.alpha = 0.0
            currentImageViewSnapshot.transform = currentImageTransform
            
            opponentImageViewSnapshot.alpha = 0.0
            opponentImageViewSnapshot.transform = opponentImageTransform
            
            sendButtonSnapshot.alpha = 0.0
            sendButtonSnapshot.transform = sendButtonTransform
            
            closeButtonSnapshot.alpha = 0.0
            closeButtonSnapshot.transform = closeButtonTransform
            
            UIView.animate(withDuration: duration, animations: {
            
                visualEffectView.alpha = 1.0
                
                headingSnapshot.alpha = 1.0
                headingSnapshot.transform = .identity
                
                subheadingSnapshot.alpha = 1.0
                subheadingSnapshot.transform = .identity
                
                currentImageViewSnapshot.alpha = 1.0
                currentImageViewSnapshot.transform = .identity
                opponentImageViewSnapshot.alpha = 1.0
                opponentImageViewSnapshot.transform = .identity
                
                sendButtonSnapshot.alpha = 1.0
                sendButtonSnapshot.transform = .identity
                closeButtonSnapshot.alpha = 1.0
                closeButtonSnapshot.transform = .identity
                
            }, completion: { (complete) in
                canvas.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
        }else{
            
            visualEffectView.alpha = 1.0
                
            headingSnapshot.alpha = 1.0
            subheadingSnapshot.alpha = 1.0
            
            currentImageViewSnapshot.alpha = 1.0
            opponentImageViewSnapshot.alpha = 1.0
            
            sendButtonSnapshot.alpha = 1.0
            closeButtonSnapshot.alpha = 1.0
            
            UIView.animate(withDuration: duration, animations: {
                
                visualEffectView.alpha = 0.0
                
                headingSnapshot.alpha = 0.0
                headingSnapshot.transform = headingTransform
                
                subheadingSnapshot.alpha = 0.0
                subheadingSnapshot.transform = subheadingTransform
                
                currentImageViewSnapshot.alpha = 0.0
                currentImageViewSnapshot.transform = currentImageTransform
                
                opponentImageViewSnapshot.alpha = 0.0
                opponentImageViewSnapshot.transform = opponentImageTransform
                
                sendButtonSnapshot.alpha = 0.0
                sendButtonSnapshot.transform = sendButtonTransform
                
                closeButtonSnapshot.alpha = 0.0
                closeButtonSnapshot.transform = closeButtonTransform
                
            }, completion: { (complete) in
                canvas.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
    
    func presentingAnimation(){
        
    }
    
    func dismissingAnimation(){
        
    }
    
    func frameForSnapshot(originalView:UIView, container:UIView) -> CGRect{
        return container.convert(originalView.bounds, from: originalView)
    }
}
