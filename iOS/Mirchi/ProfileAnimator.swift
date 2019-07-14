//
//  ProfileAnimator.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 26/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

class ProfileAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.6
    var presenting = true
    var fromCard = false
    var originFrame = CGRect.zero
    
    init(presenting:Bool, fromCard:Bool){
        self.presenting = presenting
        self.fromCard = fromCard
        super.init()
    }
    
    // MARK: - Animated Transitioning

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return fromCard ? duration : duration/2.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        
        containerView.addSubview(toView)
        
        let profileViewController = transitionContext.viewController(forKey: presenting ? .to : .from) as! ProfileViewController
        
        profileViewController.view.layoutIfNeeded()
        toView.layoutIfNeeded()
        
        let canvas = UIView(frame: containerView.bounds)
        canvas.backgroundColor = .white
        containerView.addSubview(canvas)
        
        let outgoingSnapshot = fromView.snapshotView(afterScreenUpdates: true)!
        outgoingSnapshot.alpha = presenting ? 1.0 : 0.0
        
        let incomingSnapshot = toView.snapshotView(afterScreenUpdates: true)!
        incomingSnapshot.alpha = presenting ? 0.0 : 1.0
        
        let imageViewSnapshot = profileViewController.imagesScrollView.snapshotView(afterScreenUpdates: true)!
        let infoContainerSnapshot = profileViewController.infoContainer.snapshotView(afterScreenUpdates: false)!
        
        let closeButtonSnapshot = profileViewController.closeButton.snapshotView(afterScreenUpdates: false)!
        let editButtonSnapshot = profileViewController.editButton.snapshotView(afterScreenUpdates: false)!
        
        let buttonsBackgroundSnapshot = profileViewController.fauxButtonBackgroundView.snapshotView(afterScreenUpdates: false)!
        let passButtonSnapshot = profileViewController.passButton.snapshotView(afterScreenUpdates: false)!
        let superButtonSnapshot = profileViewController.superButton.snapshotView(afterScreenUpdates: false)!
        let likeButtonSnapshot = profileViewController.likeButton.snapshotView(afterScreenUpdates: false)!
        
        canvas.addSubview(outgoingSnapshot)
        canvas.addSubview(incomingSnapshot)
        
        canvas.addSubview(imageViewSnapshot)
        canvas.addSubview(infoContainerSnapshot)
        
        canvas.addSubview(closeButtonSnapshot)
        canvas.addSubview(editButtonSnapshot)
        
        canvas.addSubview(buttonsBackgroundSnapshot)
        canvas.addSubview(passButtonSnapshot)
        canvas.addSubview(superButtonSnapshot)
        canvas.addSubview(likeButtonSnapshot)
        
        imageViewSnapshot.frame = frameForSnapshot(originalView: profileViewController.imagesScrollView, container: containerView)
        let imageViewTransform = CGAffineTransform(translationX: 0, y: -imageViewSnapshot.bounds.size.height)
        imageViewSnapshot.transform = presenting ? imageViewTransform : .identity
        imageViewSnapshot.alpha = presenting ? 0.0 : 1.0
        
        infoContainerSnapshot.frame = frameForSnapshot(originalView: profileViewController.infoContainer, container: containerView)
        let infoContainerTransform = CGAffineTransform(translationX: 0, y: (containerView.bounds.size.height - infoContainerSnapshot.frame.origin.y))
        infoContainerSnapshot.transform = presenting ? infoContainerTransform : .identity
        infoContainerSnapshot.alpha = presenting ? 0.0 : 1.0
        
        closeButtonSnapshot.frame = frameForSnapshot(originalView: profileViewController.closeButton, container: containerView)
        let closeButtonTransform = CGAffineTransform(translationX: -(closeButtonSnapshot.frame.origin.x + closeButtonSnapshot.frame.size.width), y: 0)
        closeButtonSnapshot.transform = presenting ? closeButtonTransform : .identity
        closeButtonSnapshot.alpha = presenting ? 0.0 : 1.0
        
        editButtonSnapshot.frame = frameForSnapshot(originalView: profileViewController.editButton, container: containerView)
        let editButtonTransform = CGAffineTransform(translationX: containerView.bounds.size.width - editButtonSnapshot.frame.origin.x, y: 0)
        editButtonSnapshot.transform = presenting ? editButtonTransform : .identity
        editButtonSnapshot.alpha = presenting ? 0.0 : 1.0
        
        buttonsBackgroundSnapshot.frame = containerView.convert(profileViewController.buttonsBackgroundView.bounds, from: profileViewController.buttonsBackgroundView)
        buttonsBackgroundSnapshot.alpha = presenting ? 0.0 : 1.0
        
        passButtonSnapshot.frame = containerView.convert(profileViewController.passButton.bounds, from: profileViewController.passButton)
        let passButtonTransform = CGAffineTransform(translationX: -passButtonSnapshot.frame.origin.x - passButtonSnapshot.frame.size.width, y: 0)
        passButtonSnapshot.transform = presenting ? passButtonTransform : .identity
        
        superButtonSnapshot.frame = containerView.convert(profileViewController.superButton.bounds, from: profileViewController.superButton)
        let superButtonTransform = CGAffineTransform(translationX: 0, y: 2*(canvas.bounds.size.height - superButtonSnapshot.frame.origin.y) + superButtonSnapshot.frame.size.height)
        superButtonSnapshot.transform = presenting ? superButtonTransform : .identity
        
        likeButtonSnapshot.frame = containerView.convert(profileViewController.likeButton.bounds, from: profileViewController.likeButton)
        let likeButtonTransform = CGAffineTransform(translationX: 2*(canvas.bounds.size.width - likeButtonSnapshot.frame.origin.x) + likeButtonSnapshot.frame.size.width, y: 0)
        likeButtonSnapshot.transform = presenting ? likeButtonTransform : .identity
        
        
        if presenting{
            // Presenting Animation
            
            UIView.animate(withDuration: duration/2.0, animations: {
                imageViewSnapshot.alpha = 1.0
                imageViewSnapshot.transform = .identity
                
                infoContainerSnapshot.alpha = 1.0
                infoContainerSnapshot.transform = .identity
                
            }) { (completed) in
            
                UIView.animate(withDuration: self.duration/2.0, animations: {
                    
                    closeButtonSnapshot.transform = .identity
                    closeButtonSnapshot.alpha = 1.0
                    
                    editButtonSnapshot.transform = .identity
                    editButtonSnapshot.alpha = 1.0
                    
                    buttonsBackgroundSnapshot.alpha = 1.0
                    
                    passButtonSnapshot.transform = CGAffineTransform.identity
                    superButtonSnapshot.transform = CGAffineTransform.identity
                    likeButtonSnapshot.transform = CGAffineTransform.identity
                    
                }, completion: { (completed) in
                    canvas.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
                
            }
            
        }else{
            //Dismissing animation
            
            UIView.animate(withDuration: self.duration/2.0, animations: {
                
                closeButtonSnapshot.transform = closeButtonTransform
                closeButtonSnapshot.alpha = 0.0
                
                editButtonSnapshot.transform = editButtonTransform
                editButtonSnapshot.alpha = 0.0
                
                buttonsBackgroundSnapshot.alpha = 0.0
                
                passButtonSnapshot.transform = passButtonTransform
                superButtonSnapshot.transform = superButtonTransform
                likeButtonSnapshot.transform = likeButtonTransform
                
            }, completion: { (complete) in
                
                UIView.animate(withDuration: self.duration/2.0, animations: {
                    
                    imageViewSnapshot.alpha = 0.0
                    imageViewSnapshot.transform = imageViewTransform
                    
                    infoContainerSnapshot.alpha = 0.0
                    infoContainerSnapshot.transform = infoContainerTransform
                    
                }) { (completed) in
                    canvas.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            })
            
        }
        
    }
    
    func frameForSnapshot(originalView:UIView, container:UIView) -> CGRect{
        return container.convert(originalView.bounds, from: originalView)
    }
    

}
