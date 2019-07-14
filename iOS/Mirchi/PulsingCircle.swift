//
//  PulsingCircles.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 10/12/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

@IBDesignable
class PulsingCircle: UIView {
    
    @IBInspectable var borderWidth:CGFloat = 0.0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor:UIColor = .clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBOutlet var topFinalConstraint:NSLayoutConstraint!
    @IBOutlet var bottomFinalConstraint:NSLayoutConstraint!
    var animationTimer:Timer?
    var animating:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //layer.shouldRasterize = true
        updateCornerRadius()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
    func updateCornerRadius() {
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
    
    override func action(for layer: CALayer, forKey event: String) -> CAAction? {
        if event == "cornerRadius" {
            if let boundsAnimation = layer.animation(forKey: "bounds.size") as? CABasicAnimation {
                let animation = boundsAnimation.copy() as! CABasicAnimation
                animation.keyPath = "cornerRadius"
                let action = Action()
                action.pendingAnimation = animation
                action.priorCornerRadius = layer.cornerRadius
                return action
            }
        }
        return super.action(for: layer, forKey: event)
    }
    
    class Action: NSObject, CAAction {
        var pendingAnimation: CABasicAnimation?
        var priorCornerRadius: CGFloat = 0
        public func run(forKey event: String, object anObject: Any, arguments dict: [AnyHashable : Any]?) {
            if let layer = anObject as? CALayer, let pendingAnimation = pendingAnimation {
                if pendingAnimation.isAdditive {
                    pendingAnimation.fromValue = priorCornerRadius - layer.cornerRadius
                    pendingAnimation.toValue = 0
                } else {
                    pendingAnimation.fromValue = priorCornerRadius
                    pendingAnimation.toValue = layer.cornerRadius
                }
                layer.add(pendingAnimation, forKey: "cornerRadius")
            }
        }
    }
    
    @objc func startAnimating(){
        guard !animating else { return }
        animating = true
        animate()
    }
    
    @objc func animate(){
        guard animating else { return }
        self.superview?.layoutIfNeeded()
        UIView.animate(withDuration: 5.0, delay: 0.0, options: [/*.repeat*/], animations: {
            self.topFinalConstraint.priority = UILayoutPriority.init(rawValue: 900)
            self.bottomFinalConstraint.priority = UILayoutPriority.init(rawValue: 900)
            self.alpha = 0.0
            self.superview!.setNeedsLayout()
            self.superview!.layoutIfNeeded()
        }) { (complete) in
            self.resetCircle()
        }
    }
    
    func stopAnimating(){
        animating = false
        self.layer.removeAllAnimations()
        UIView.animate(withDuration: 1.0, animations: {
            self.alpha = 0.0
        }, completion: { (complete) in
            self.resetCircle()
        })
    }
    
    func resetCircle(){
        topFinalConstraint.priority = UILayoutPriority.defaultLow
        bottomFinalConstraint.priority = UILayoutPriority.defaultLow
        self.alpha = 1.0
        self.superview?.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.animate()
        }
    }

}
