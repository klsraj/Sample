//
//  ProfileCardView.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 15/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import FirebaseUI
import DropletIF

@IBDesignable
class ProfileCardView: CardView {

    @IBOutlet weak var superlikeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var profileImageView: ShapeImageView!
    @IBOutlet weak var guideView: UIView!
    var user:User!
    var currentImageIndex:Int = 0
    var isSuperLike:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //layer.shouldRasterize = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !previousBounds.equalTo(bounds){
            print("Updating shadow path!")
            previousBounds = bounds
            layer.shadowPath = UIBezierPath(roundedRect: profileImageView.bounds, cornerRadius: profileImageView.cornerRadius).cgPath
        }
    }
    
    func configureForUser(user:User){
        self.user = user
        if let name = user.name{
            nameLabel.text = "\(name), "
        }
        if let age = user.age{
            ageLabel.text = "\(age)"
        }
        schoolLabel.text = user.school
        workLabel.text = user.work
        if user.images.count > 0{
            //profileImageView.sd_setImage(with: Storage.storage().reference().child(user.images[0]), placeholderImage: nil)
            profileImageView.sd_setImage(with: Storage.storage().reference().child(user.images[0]), placeholderImage: nil) { (image, error, cacheType, ref) in
                    print("Completed Downloading Card Image")
            }
            preloadImages()
        }else{
            profileImageView.image = nil
        }
        isSuperLike = user.isSuperLike
        configureSuperlikeImage()
    }
    
    func configureSuperlikeImage(){
        if isSuperLike{
            superlikeImageView.isHidden = false
            superlikeImageView.layer.shadowColor = nameLabel.layer.shadowColor
            superlikeImageView.layer.shadowOffset = nameLabel.layer.shadowOffset
            superlikeImageView.layer.shadowOpacity = nameLabel.layer.shadowOpacity
            superlikeImageView.layer.shadowRadius = nameLabel.layer.shadowRadius
        }else{
            superlikeImageView.isHidden = true
        }
    }
    
    func configureSuperlikeShadow(){
        
        if isSuperLike{
            
            layer.shadowColor = Colors.lightOrange.cgColor
            layer.shadowRadius = 20.0
            layer.shadowOpacity = 1.0
            layer.shadowOffset = CGSize.zero
            
            /*let animation = CABasicAnimation(keyPath: "shadowOpacity")
            animation.fromValue = layer.shadowOpacity
            animation.toValue = 1.0
            animation.duration = 1.0
            layer.add(animation, forKey: animation.keyPath)
            layer.shadowOpacity = 1.0*/
        }else{
        }
    }
    
    func showGuideView(){
        guideView.alpha = 0.0
        guideView.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 2.0, options: [], animations: {
            self.guideView.alpha = 1.0
        }, completion: nil)
    }
    
    @IBAction func guideViewTapped(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "hasShownCardGuide")
        UIView.animate(withDuration: 0.5, animations: {
            self.guideView.alpha = 0.0
        }) { (complete) in
            self.guideView.isHidden = true
        }
    }
    
    func preloadImages(){
        for image in user.images.dropFirst(){
            UIImageView(frame: CGRect.zero).sd_setImage(with: Storage.storage().reference().child(image))
        }
    }
    
    @IBAction func showPreviousImage(_ sender: UITapGestureRecognizer) {
        guard currentImageIndex > 0 else {
            perspectiveAnimate(angle: -Double.pi/8)
            return
        }
        currentImageIndex -= 1
        profileImageView.sd_setImage(with: Storage.storage().reference().child(user.images[currentImageIndex]))
    }
    
    @IBAction func showNextImage(_ sender: UITapGestureRecognizer) {
        guard currentImageIndex < (user.images.count - 1) else {
            perspectiveAnimate(angle: Double.pi/8)
            return
        }
        currentImageIndex += 1
        profileImageView.sd_setImage(with: Storage.storage().reference().child(user.images[currentImageIndex]))
    }
    
    func perspectiveAnimate(angle:Double){
        var identity = CATransform3DIdentity
        identity.m34 = -1.0 / 1000.0;
        let rotateTransform = CATransform3DRotate(identity, CGFloat(angle), 0.0, 1.0, 0.0)
        UIView.animate(withDuration: 0.15, animations: {
            self.layer.transform = rotateTransform
        }) { (complete) in
            UIView.animate(withDuration: 0.15, animations: {
                self.layer.transform = CATransform3DIdentity
            })
        }
    }
    
    deinit {
        for imageRef in user.images{
            SDImageCache.shared().removeImage(forKey: imageRef, fromDisk: false, withCompletion: nil)
        }
    }
    
}
