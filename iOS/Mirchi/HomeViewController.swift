//
//  HomeViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 12/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import Koloda
import FirebaseUI
import FirebaseDatabase
import MBProgressHUD
import DropletIF

class HomeViewController: UIViewController{

    @IBOutlet weak var cardHolderView: CardHolderView!
    @IBOutlet var pulsingCircles: [PulsingCircle]!
    @IBOutlet weak var profileImageView: ShapeImageView!
    @IBOutlet weak var outOfUsersView: UIView!
    @IBOutlet weak var profileDisabledView: UIView!
    @IBOutlet weak var locationErrorNotice: UIView!
    @IBOutlet weak var passportButton: PassportButton!
    
    var swipedViaButtonPress = false
    var cardImagesNeedPreloading = true
    var swipeCount:Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCardHolder()
        UserService.shared.delegate = self
        
        addNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureProfileDisabledView()
        configurePassportButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LocationService.shared.addDelegate(delegate: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocationService.shared.removeDelegate(delegate: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tryShowingInterstitial(force:Bool){
        if !force && swipeCount < Config.Features.adsSwipeCount{
            swipeCount += 1
            return
        }
        if let interstitial = AdsService.shared.getInterstitial(){
            interstitial.present(fromRootViewController: self)
            swipeCount = 0
        }
    }
    
    func startPulsingCircleAnimation(){
        for (idx, circle) in pulsingCircles.enumerated(){
            //DispatchQueue.main.asyncAfter(deadline: .now() + ((pow(2.0,Double(idx))) * 1.0)) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(idx) * 1.5) {
                circle.startAnimating()
            }
        }
    }
    
    func stopPulsingCircleAnimation(){
        for circle in pulsingCircles{
            circle.stopAnimating()
        }
    }
    
    func configurePassportButton(){
        passportButton.isHome = (UserSettings.shared.activeLocation == -1)
    }
    
    func setupCardHolder(){
        cardHolderView.countOfVisibleCards = 2
        cardHolderView.shouldPassthroughTapsWhenNoVisibleCards = true
        cardHolderView.delegate = self
        cardHolderView.dataSource = self
    }
    
    func addNotificationObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(currentProfileImageUpdated), name: DropletConstants.NotificationName.userProfileImageUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userSettingsUpdated), name: DropletConstants.NotificationName.userSettingsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(accountDeleted), name: Constants.NotificationName.accountDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(accountDeleted), name: Constants.NotificationName.loggedOut, object: nil)
    }
    
    @objc func userSettingsUpdated(){
        configurePassportButton()
        configureProfileDisabledView()
    }
    
    @objc func accountDeleted(){
        profileImageView.image = nil
        stopPulsingCircleAnimation()
    }
    
    @IBAction func didTapRewind(_ sender: Any) {
        if Config.Features.rewindIsPremium && !StoreService.shared.isSubscribed() {
            performSegue(withIdentifier: "showUpgradeViewController", sender: nil)
            return
        }
        guard UserService.shared.isRewindAvailable else { return }
        cardHolderView.revertAction()
        toggleOutOfUsersView(show: false)
        if let user = UserService.shared.getUserForDisplayAt(index: cardHolderView.currentCardIndex){
            UserService.shared.didRewind(user: user)
        }
    }
    
    @IBAction func didTapPass(_ sender: Any) {
        if !UserSettings.shared.haveTappedPass, let name = UserService.shared.getUserForDisplayAt(index: cardHolderView.currentCardIndex)?.name{
            let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("HOME_FIRST_PASS_BUTTON_TAP_ALERT_TITLE", comment: "Title of Alert First Time User Passes"), message: String.init(format: NSLocalizedString("HOME_FIRST_PASS_BUTTON_TAP_ALERT_BODY_WITH_NAME", comment: "Body of Alert First Time User Passes"), name))
            alert.addAction(title: NSLocalizedString("HOME_FIRST_PASS_BUTTON_TAP_ALERT_CANCEL_BUTTON", comment: "Cancel Button"), style: .cancel, handler: nil)
            alert.addAction(title: NSLocalizedString("HOME_FIRST_PASS_BUTTON_TAP_ALERT_PASS_BUTTON", comment: "Confirm Button of Alert First Time User Passes"), style: .default, handler: {
                self.swipedViaButtonPress = true
                UserSettings.shared.haveTappedPass = true
                self.cardHolderView.swipe(.left, force: false)
            })
            alert.transitioningDelegate = self
            present(alert, animated: true, completion: nil)
            return
        }
        swipedViaButtonPress = true
        cardHolderView.swipe(.left, force: false)
    }
    
    @IBAction func didTapLike(_ sender: Any){
        if !UserSettings.shared.haveTappedLike, let name = UserService.shared.getUserForDisplayAt(index: cardHolderView.currentCardIndex)?.name{
            let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("HOME_FIRST_LIKE_BUTTON_TAP_ALERT_TITLE", comment: "Title of Alert First Time User Likes"), message: String.init(format: NSLocalizedString("HOME_FIRST_LIKE_BUTTON_TAP_ALERT_BODY_WITH_NAME", comment: "Body of Alert First Time User Likes"), name))
            alert.addAction(title: NSLocalizedString("HOME_FIRST_LIKE_BUTTON_TAP_ALERT_CANCEL_BUTTON", comment: "Cancel Button"), style: .cancel, handler: nil)
            alert.addAction(title: NSLocalizedString("HOME_FIRST_LIKE_BUTTON_TAP_ALERT_LIKE_BUTTON", comment: "Confirm Button of Alert First Time User Likes"), style: .default, handler: {
                self.swipedViaButtonPress = true
                UserSettings.shared.haveTappedLike = true
                self.cardHolderView.swipe(.right, force: false)
            })
            alert.transitioningDelegate = self
            present(alert, animated: true, completion: nil)
            return
        }
        swipedViaButtonPress = true
        cardHolderView.swipe(.right, force: false)
    }
    
    @IBAction func didTapSuperlike(_ sender: Any) {
        if !UserSettings.shared.haveTappedSuperLike, let name = UserService.shared.getUserForDisplayAt(index: cardHolderView.currentCardIndex)?.name{
            let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("HOME_FIRST_SUPERLIKE_BUTTON_TAP_ALERT_TITLE", comment: "Title of Alert First Time User Super Likes"), message: String.init(format: NSLocalizedString("HOME_FIRST_SUPERLIKE_BUTTON_TAP_ALERT_BODY_WITH_NAME", comment: "Body of Alert First Time User Super Likes"), name))
            alert.addAction(title: NSLocalizedString("HOME_FIRST_SUPERLIKE_BUTTON_TAP_ALERT_CANCEL_BUTTON", comment: "Cancel Button"), style: .cancel, handler: nil)
            alert.addAction(title: NSLocalizedString("HOME_FIRST_SUPERLIKE_BUTTON_TAP_ALERT_SUPERLIKE_BUTTON", comment: "Confirm Button of Alert First Time User Super Likes"), style: .default, handler: {
                self.swipedViaButtonPress = true
                UserSettings.shared.haveTappedSuperLike = true
                self.cardHolderView.swipe(.up, force: false)
            })
            alert.transitioningDelegate = self
            present(alert, animated: true, completion: nil)
            return
        }
        swipedViaButtonPress = true
        cardHolderView.swipe(.up, force: false)
    }
    
    
    @IBAction func didTapEnableProfile(_ sender: Any) {
        UserSettings.shared.showMe = true
        configureProfileDisabledView()
    }
    
    @objc func configureProfileDisabledView(){
        UIView.animate(withDuration: 0.4, animations: {
            self.profileDisabledView.alpha = UserSettings.shared.showMe ? 0.0 : 1.0
        }) { (complete) in
            self.profileDisabledView.isHidden = UserSettings.shared.showMe
        }
    }
    
    // Notification Observers
    
    @objc func currentProfileImageUpdated(){
        print("Current Profile Image Updated, updating profile image")
        
        if let image = AuthService.shared.currentUser?.images.first{
            if let cachedImage = getCachedUserProfileImage(){
                profileImageView.image = cachedImage
                SDImageCache.shared().store(cachedImage, forKey: image, completion: nil)
            }else{
                profileImageView.sd_setImage(with: Storage.storage().reference().child(image), placeholderImage: profileImageView.image, completion: { (image, error, cacheType, ref) in
                    if let img = image, let imageData = img.jpegData(compressionQuality: 0.8){
                        self.storeCachedUserProfileImage(imageData: imageData, ref: ref)
                    }
                })
            }
        }else{
            profileImageView.image = nil
        }
    }
    
    func storeCachedUserProfileImage(imageData:Data, ref:StorageReference){
        var imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]// else { return }
        imageURL.appendPathComponent("cachedProfileImg", isDirectory: true)
        do{
            if FileManager.default.fileExists(atPath: imageURL.path){
                try FileManager.default.removeItem(atPath: imageURL.path)
            }
            try FileManager.default.createDirectory(at: imageURL, withIntermediateDirectories: true, attributes: nil)
            imageURL.appendPathComponent("\(ref.name).jpg")
            try imageData.write(to: imageURL, options: .atomic)
        }catch{
            print("Error saving image to disk", error)
        }
    }
    
    func getCachedUserProfileImage()->UIImage?{
        guard let rawImageRef = AuthService.shared.currentUser?.images.first else { return nil }
        let imageRef = Storage.storage().reference().child(rawImageRef)
        guard var imageURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return nil }
        imageURL.appendPathComponent("cachedProfileImg/\(imageRef.name).jpg")
        if FileManager.default.fileExists(atPath: imageURL.path){
            return UIImage(contentsOfFile: imageURL.path)
        }
        return nil
    }
    
    func tryShowingFirstSwipeAlert(direction:SwipeResultDirection, index:Int) -> Bool{
        if let name = UserService.shared.getUserForDisplayAt(index: index)?.name{
            if direction == .left && !UserSettings.shared.haveSwipedPass{
                
                let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("HOME_FIRST_PASS_SWIPE_ALERT_TITLE", comment: "Title of Alert First Time User Passes"), message: String.init(format: NSLocalizedString("HOME_FIRST_PASS_SWIPE_ALERT_BODY_WITH_NAME", comment: "Body of Alert First Time User Passes"), name))
                alert.addAction(title: NSLocalizedString("HOME_FIRST_PASS_SWIPE_ALERT_CANCEL_BUTTON", comment: "Cancel Button"), style: .cancel, handler: nil)
                alert.addAction(title: NSLocalizedString("HOME_FIRST_PASS_SWIPE_ALERT_PASS_BUTTON", comment: "Confirm Button of Alert First Time User Passes"), style: .default, handler: {
                    UserSettings.shared.haveSwipedPass = true
                    self.cardHolderView.swipe(.left, force: false)
                })
                alert.transitioningDelegate = self
                present(alert, animated: true, completion: nil)
                return false
            }else if direction == .right && !UserSettings.shared.haveSwipedLike{
               
                let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("HOME_FIRST_LIKE_SWIPE_ALERT_TITLE", comment: "Title of Alert First Time User Likes"), message: String.init(format: NSLocalizedString("HOME_FIRST_LIKE_SWIPE_ALERT_BODY_WITH_NAME", comment: "Body of Alert First Time User Likes"), name))
                alert.addAction(title: NSLocalizedString("HOME_FIRST_LIKE_SWIPE_ALERT_CANCEL_BUTTON", comment: "Cancel Button"), style: .cancel, handler: nil)
                alert.addAction(title: NSLocalizedString("HOME_FIRST_LIKE_SWIPE_ALERT_LIKE_BUTTON", comment: "Confirm Button of Alert First Time User Likes"), style: .default, handler: {
                    UserSettings.shared.haveSwipedLike = true
                    self.cardHolderView.swipe(.right, force: false)
                })
                alert.transitioningDelegate = self
                present(alert, animated: true, completion: nil)
                return false
            }else if direction == .up && !UserSettings.shared.haveSwipedSuperLike{
                
                let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("HOME_FIRST_SUPERLIKE_SWIPE_ALERT_TITLE", comment: "Title of Alert First Time User Swipes Super Likes"), message: String.init(format: NSLocalizedString("HOME_FIRST_SUPERLIKE_SWIPE_ALERT_BODY_WITH_NAME", comment: "Body of Alert First Time User Swipes Super Likes"), name))
                alert.addAction(title: NSLocalizedString("HOME_FIRST_SUPERLIKE_SWIPE_ALERT_CANCEL_BUTTON", comment: "Cancel Button"), style: .cancel, handler: nil)
                alert.addAction(title: NSLocalizedString("HOME_FIRST_SUPERLIKE_SWIPE_ALERT_SUPERLIKE_BUTTON", comment: "Confirm Button of Alert First Time User Swipes Super Likes"), style: .default, handler: {
                    UserSettings.shared.haveSwipedSuperLike = true
                    self.cardHolderView.swipe(.up, force: false)
                })
                alert.transitioningDelegate = self
                present(alert, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    func toggleOutOfUsersView(show:Bool){
        outOfUsersView.isHidden = !show
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toVc = segue.destination as? ProfileViewController, let user = sender as? User{
            if user.uid != AuthService.shared.currentUser?.uid{
                toVc.transitioningDelegate = self
                toVc.delegate = self
            }
            toVc.user = user as! CustomUser
            return
        }
    }
    
    // DEBUG METHOD
    func preloadImages(){
        for user in UserService.shared.usersForDisplay{
            if user.images.count > 0{
                //UIImageView(frame: CGRect.zero).sd_setImage(with: Storage.storage().reference(withPath: user.images[0]))
                UIImageView(frame: CGRect.zero).sd_setImage(with: Storage.storage().reference(withPath: user.images[0]), placeholderImage: nil) { (image, error, cacheType, ref) in
                        print("Completed downloading image")
                    SDImageCache.shared().removeImage(forKey: ref.fullPath, fromDisk: false, withCompletion: {
                        print("Removed image from cache")
                    })
                }
            }
        }
    }
}

extension HomeViewController: LocationServiceDelegate{
    
    func needLocationRequest() {
        let storyboard = UIStoryboard(name: "permission_requests", bundle: nil)
        if let vc = storyboard.instantiateInitialViewController(){
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func locationDidChange() {
        locationErrorNotice.isHidden = true
    }
    
    func locationFetchFailed(withError error: Error) {
        locationErrorNotice.isHidden = false
    }
}

extension HomeViewController: KolodaViewDataSource{
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        let count = UserService.shared.usersForDisplay.count
        if count > 0{
            stopPulsingCircleAnimation()
        }else{
            startPulsingCircleAnimation()
        }
        return count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let cardView = Bundle.main.loadNibNamed("profile_card", owner: nil, options: nil)![0] as! ProfileCardView
        print(cardView.bounds)
        guard let user = UserService.shared.getUserForDisplayAt(index: index) else {
            cardHolderView.reloadData()
            return cardView
        }
        cardView.configureForUser(user: user)
        if cardImagesNeedPreloading{
            cardImagesNeedPreloading = false
            preloadImages()
        }
        return cardView
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("ProfileCardOverlayView", owner: self, options: nil)![0] as! ProfileCardOverlayView
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return DragSpeed.default
    }
}

extension HomeViewController: KolodaViewDelegate{
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        if let profileCard = koloda.viewForCard(at: index) as? ProfileCardView{
            profileCard.configureSuperlikeShadow()
            if !UserDefaults.standard.bool(forKey: "hasShownCardGuide"){
                profileCard.showGuideView()
            }
        }
        
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        cardImagesNeedPreloading = true
        UserService.shared.loadUsers()
        startPulsingCircleAnimation()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        guard let user = UserService.shared.getUserForDisplayAt(index: index) else { return }
        performSegue(withIdentifier: "toProfileViewController", sender: user)
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [SwipeResultDirection.left, SwipeResultDirection.right, SwipeResultDirection.up]
    }
    
    func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool {
        guard let currentUser = AuthService.shared.currentUser else { return false }
        guard ConnectionService.shared.connected else{
            print("No Connection")
            return false
        }
        if direction == .right && !currentUser.isAllowedToLike() && !StoreService.shared.isSubscribed(){
            self.performSegue(withIdentifier: "showLikeLimitViewController", sender: nil)
            return false
        }
        if direction == .up && !currentUser.isAllowedToSuperLike(){
            self.performSegue(withIdentifier: "showSuperLikeLimitViewController", sender: nil)
            return false
        }
        if !swipedViaButtonPress{
            return tryShowingFirstSwipeAlert(direction: direction, index: index)
        }
        return true
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        guard let user = UserService.shared.getUserForDisplayAt(index: index) else { return }
        if direction == .left{
            UserService.shared.passUser(user: user, completion: nil, onError: nil)
            tryShowingInterstitial(force: false)
        }else if direction == .right{
            UserService.shared.likeUser(user: user, completion: nil, onError: nil)
            tryShowingInterstitial(force: false)
        }else if direction == .up{
            UserService.shared.superLikeUser(user: user, completion: nil, onError: nil)
            tryShowingInterstitial(force: true)
        }
        swipedViaButtonPress = false
    }
}

extension HomeViewController: UserServiceDelegate{
    
    func finishedLoadingUsers() {
        toggleOutOfUsersView(show: false)
        cardHolderView.reloadData()
    }
    
    func usersDidReset(){
        toggleOutOfUsersView(show: false)
        cardHolderView.reloadData()
    }
    
    func outOfUsers() {
        print("Out of users!")
        toggleOutOfUsersView(show: true)
    }
}

extension HomeViewController: ProfileDelegate{
    
    func likeProfile(user: User) {
        if UserService.shared.getUserForDisplayAt(index: cardHolderView.currentCardIndex)?.uid == user.uid{
            cardHolderView.swipe(.right)
        }
    }
    
    func superLikeProfile(user:User){
        if UserService.shared.getUserForDisplayAt(index: cardHolderView.currentCardIndex)?.uid == user.uid{
            cardHolderView.swipe(.up)
        }
    }
    
    func passProfile(user: User) {
        if UserService.shared.getUserForDisplayAt(index: cardHolderView.currentCardIndex)?.uid == user.uid{
            cardHolderView.swipe(.left)
        }
    }
}

