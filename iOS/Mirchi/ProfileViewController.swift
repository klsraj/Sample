//
//  ProfileViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 17/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import FirebaseUI
import MapKit
import FirebaseDatabase
import FBSDKCoreKit
import DropletIF

protocol ProfileDelegate{
    func passProfile(user:User)
    func likeProfile(user:User)
    func superLikeProfile(user:User)
}

class ProfileViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var closeButton: ShapeButton!
    @IBOutlet weak var editButton: ShapeButton!
    
    @IBOutlet weak var imagesScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var imagesScrollViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var infoContainer: UIView!
    
    @IBOutlet weak var optionsButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var communityLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var schoolTopToWorkConstraint: NSLayoutConstraint!
    @IBOutlet weak var schoolTopToNameConstraint: NSLayoutConstraint!
    @IBOutlet weak var communityTopToSchoolConstraint: NSLayoutConstraint!
    @IBOutlet weak var communityTopToWorkConstraint: NSLayoutConstraint!
    @IBOutlet weak var communityTopToNameConstraint: NSLayoutConstraint!
    @IBOutlet weak var distanceTopToCommunityConstraint: NSLayoutConstraint!
    @IBOutlet weak var distanceTopToSchoolConstraint: NSLayoutConstraint!
    @IBOutlet weak var distanceTopToWorkConstraint: NSLayoutConstraint!
    @IBOutlet weak var distanceTopToNameConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var aboutLabel: UILabel!
    
    @IBOutlet weak var fauxButtonBackgroundView: GradientView!
    @IBOutlet weak var buttonsBackgroundView: GradientView!
    @IBOutlet weak var passButton: ShapeButton!
    @IBOutlet weak var superButton: ShapeButton!
    @IBOutlet weak var likeButton: ShapeButton!
    
    var toEditScreen:Bool = false
    var delegate:ProfileDelegate?
    var user:CustomUser!
    var haveSetAspectRatio = false
    var defaultScrollViewOffset:CGFloat = 0.0
    @IBOutlet weak var defaultImageAspect: NSLayoutConstraint!
    var haveSetDefaultOffset = false
    
    var mutualFriendsRequestRef:DatabaseReference?
    var mutualFriendsReceiptRef:DatabaseReference?
    var mutualFriends:[[String:String]] = [[String:String]]()
    
    @IBOutlet weak var mutualFriendsHeading: UILabel!
    @IBOutlet weak var mutualFriendsView: UIView!
    @IBOutlet weak var mutualFriendsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mutualFriendsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user.uid == AuthService.shared.currentUser?.uid{
            editButton.isHidden = false
            optionsButton.isHidden = true
        }else{
            editButton.isHidden = true
            optionsButton.isHidden = false
            
            //Mutual Friends API has been deprecated by Facebook
            //requestMutualFriends()
        }
        
        if delegate == nil{
            passButton.isHidden = true
            likeButton.isHidden = true
            superButton.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureForUser()
        user.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if toEditScreen{
            performSegue(withIdentifier: "toEditProfileViewController", sender: nil)
            toEditScreen = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func configureForUser(){
        configureImages()
        
        nameLabel.text = user.name
        if let age = user.age{
            nameLabel.text = String(format: NSLocalizedString("PROFILE_NAME_AGE_HEADING", comment: "Profile Name/Age Heading"), arguments: [nameLabel.text ?? "", age] )
        }
        occupationLabel.text = user.work
        schoolLabel.text = user.school
        aboutLabel.text = user.about
        communityLabel.text = user.community
        
        schoolTopToWorkConstraint.priority = (user.work?.isEmpty ?? true ? .defaultLow : .defaultHigh)
        schoolTopToNameConstraint.priority = (user.work?.isEmpty ?? true ? .defaultHigh : .defaultLow)
        communityTopToSchoolConstraint.priority = (user.school?.isEmpty ?? true ? .defaultLow : .defaultHigh)
        communityTopToWorkConstraint.priority = (!(user.work?.isEmpty ?? true) && user.school?.isEmpty ?? true ? .defaultHigh : .defaultLow)
        communityTopToNameConstraint.priority = (user.work?.isEmpty ?? true && user.school?.isEmpty ?? true ? .defaultHigh : .defaultLow)
        distanceTopToCommunityConstraint.priority = (user.community?.isEmpty ?? true ? .defaultLow : .defaultHigh)
        distanceTopToSchoolConstraint.priority = (!(user.school?.isEmpty ?? true) && user.community?.isEmpty ?? true ? .defaultHigh : .defaultLow)
        distanceTopToWorkConstraint.priority = (!(user.work?.isEmpty ?? true) && user.school?.isEmpty ?? true && user.community?.isEmpty ?? true ? .defaultHigh : .defaultLow)
        distanceTopToNameConstraint.priority = (user.work?.isEmpty ?? true && user.school?.isEmpty ?? true && user.community?.isEmpty ?? true ? .defaultHigh : .defaultLow)
        
        configureDistanceLabel()
    }
    
    func configureImages(){
        for subview in imagesScrollView.subviews{
            subview.removeFromSuperview()
        }
        var leftView:UIView = imagesScrollView
        for image in user.images{
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.sd_setImage(with: Storage.storage().reference().child(image))
            imagesScrollView.addSubview(imageView)
            imagesScrollView.addConstraints([
                NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: leftView, attribute: (leftView == imagesScrollView ? .leading : .trailing), multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imagesScrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: imagesScrollView, attribute: .top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imagesScrollView, attribute: .height, multiplier: 1.0, constant: 0.0)
            ])
            leftView = imageView
        }
        imagesScrollView.layoutIfNeeded()
        imagesScrollView.contentSize = CGSize(width: CGFloat(max(1, user.images.count)) * imagesScrollView.bounds.size.width, height: imagesScrollView.bounds.size.height)
        pageControl.numberOfPages = user.images.count
    }
    
    func configureDistanceLabel(){
        guard let location = user.location, let currentLocation = LocationService.shared.currentLocation else {
            distanceLabel.text = nil
            distanceLabel.isHidden = true
            return
        }
        
        
        var dist = currentLocation.location().distance(from: location)
        
        // Make sure displayed distance never larger than users max dist setting if viewing from cards
        // (allows us to show users further away, pretending they are within limits)
        if delegate != nil{
            dist = min(dist, Double(UserSettings.shared.maxDistance * 1000))
        }
        
        let distFormatter = MKDistanceFormatter()
        
        //Obfuscate location slightly by setting min to 0.25km
        if dist < 1000 {
            distanceLabel.text = String.init(format: NSLocalizedString("PROFILE_DISTANCE_AWAY_BELOW_MINIMUM", comment: "Profile Distance Minimum"), distFormatter.string(fromDistance: 1000))
        }else{
            distanceLabel.text = String.init(format: NSLocalizedString("PROFILE_DISTANCE_AWAY", comment: "Profile Distance"), distFormatter.string(fromDistance: dist))
        }
    }

    @IBAction func didTapClose(_ sender: Any) {
        if let presentingVC = presentingViewController{
            presentingVC.dismiss(animated: true, completion: nil)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func didTapOptions(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        /*actionSheet.addAction(UIAlertAction(title: NSLocalizedString("PROFILE_OPTIONS_SHARE_BUTTON", comment: "Profile Options Menu Share"), style: .default, handler: { (action) in
            self.shareUser()
        }))*/
        let reportText:String = {
            guard let name = user.name else { return NSLocalizedString("PROFILE_OPTIONS_REPORT_BUTTON", comment: "Report Button") }
            return String(format: NSLocalizedString("PROFILE_OPTIONS_REPORT_BUTTON_WITH_NAME", comment: "Report Button (with user's name)"), name)
        }()
        actionSheet.addAction(UIAlertAction(title: reportText, style: .destructive, handler: { (action) in
            //
            self.performSegue(withIdentifier: "toReportViewController", sender: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("PROFILE_OPTIONS_CANCEL_BUTTON", comment: "Cancel Button"), style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    /*func shareUser(){
        let shareItems:[AnyObject] = [
            NSLocalizedString("PROFILE_SHARE_MESSAGE", comment: "Share Profile Text") as AnyObject,
            URL(string: "http://thedropletapp.com")! as AnyObject
        ]
        let activityController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityController.excludedActivityTypes = [
            .addToReadingList,
            .airDrop,
            .assignToContact,
            .openInIBooks,
            .print,
            .saveToCameraRoll
        ]
        present(activityController, animated: true, completion: nil)
    }*/
    
    func dismiss(){
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapLike(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: {
            self.delegate?.likeProfile(user: self.user)
        })
    }
    
    @IBAction func didTapSuperLike(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: {
            self.delegate?.superLikeProfile(user: self.user)
        })
    }
    
    @IBAction func didTapPass(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: {
            self.delegate?.passProfile(user: self.user)
        })
    }
    
    // MARK: - Mutual Friends
    
    func requestMutualFriends(){
        
        guard let to_fbid = user.fbid, let accessToken = FBSDKAccessToken.current()?.tokenString else{
            return
        }
        
        mutualFriendsRequestRef = Database.database().reference().child("mutual_friends/req").childByAutoId()
        
        // Add result listener before making request
        mutualFriendsReceiptRef = Database.database().reference().child("mutual_friends/rec/\(mutualFriendsRequestRef!.key)")
        Database.database().reference().child("mutual_friends/rec/\(mutualFriendsRequestRef!.key)").observe(.value) { [weak self] (snapshot) in
            if let object = snapshot.value as? [String:AnyObject], let friends = object["friends"] as? [[String:String]], let strongSelf = self{
                strongSelf.mutualFriends.append(contentsOf: friends)
                strongSelf.mutualFriendsCollectionView.reloadData()
                strongSelf.mutualFriendsReceiptRef?.removeAllObservers()
            }
        }
        
        mutualFriendsRequestRef!.setValue([
            "access_token" : accessToken,
            "to_fbid" : to_fbid
        ])
        
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toVC = segue.destination as? ReportViewController{
            toVC.transitioningDelegate = self
            toVC.user = user
            toVC.delegate = self
        }
    }
    
    @IBAction func unwindToProfile(segue: UIStoryboardSegue){
        //
    }
    
    deinit {
        mutualFriendsReceiptRef?.setValue(nil)
        mutualFriendsRequestRef?.setValue(nil)
    }

}

extension ProfileViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == imagesScrollView{
            let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.size.width))
            pageControl.currentPage = page
        }
        if scrollView == scrollView{
            let offset = scrollView.contentOffset
            if offset.y < 0.0 {
                let scaleFactor = 1 + abs(2 * offset.y) / imagesScrollView.bounds.size.height
                let transform = CGAffineTransform(translationX: 0, y: offset.y)
                imagesScrollView.transform = transform.scaledBy(x: scaleFactor, y: scaleFactor)
            } else {
                imagesScrollView.transform = .identity
            }
        }
    }
}

extension ProfileViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = mutualFriends.count
        mutualFriendsView.isHidden = (count == 0)
        mutualFriendsViewHeightConstraint.priority = (count == 0 ? UILayoutPriority.init(751) : UILayoutPriority.defaultLow)
        mutualFriendsHeading.text = String(format: NSLocalizedString("PROFILE_MUTUAL_FRIENDS_HEADING_WITH_COUNT", comment: "Mutual Friends Heading"), arguments: [count])
        return mutualFriends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MutualFriendCell", for: indexPath) as! NewMatchCell
        
        let friend = mutualFriends[indexPath.row]
        cell.configureCell(name: friend["name"], imageUrl: friend["image"])
        
        return cell
    }
}

extension ProfileViewController: ReportViewControllerDelegate{
    func didCancelReport() {
        dismiss(animated: true, completion: nil)
    }
    
    func didSendReport(user: User) {
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: UserDelegate{
    func userUpdated() {
        configureForUser()
    }
}
