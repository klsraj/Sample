//
//  RootViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 05/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

class RootViewController: UIViewController{

    var chatsViewController:ChatsViewController?
    
    var isAnimating = false
    var isShowingMenu = false
    var isPreseningLoginVC = false
    
    var leftBaseTint:UIColor = UIColor.white
    var centerBaseTint:UIColor = UIColor.white
    var rightBaseTint:UIColor = UIColor.white
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var navigationBar: UIView!
    
    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var centerBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!
    
    @IBOutlet weak var leftBarButtonImage: UIImageView!
    @IBOutlet weak var centerBarButtonImage: UIImageView!
    @IBOutlet weak var rightBarButtonImage: UIImageView!
    
    @IBOutlet weak var unreadIndicator: RoundedView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initBaseTint()
        view.layoutIfNeeded()
        goToCenterScreen(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUnreadIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ChatService.shared.addDelegate(delegate: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ChatService.shared.removeDelegate(delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initBaseTint(){
        leftBaseTint = leftBarButton.tintColor
        centerBaseTint = centerBarButton.tintColor
        rightBaseTint = rightBarButton.tintColor
    }
    
    @IBAction func didTapLeftButton(_ sender: Any) {
        goToLeftScreen(animated: true)
    }
    
    @IBAction func didTapCenterButton(_ sender: Any) {
        goToCenterScreen(animated: true)
    }

    @IBAction func didTapRightButton(_ sender: Any) {
        goToRightScreen(animated: true)
    }
    
    func goToLeftScreen(animated:Bool){
        scrollView.setContentOffset(CGPoint.zero, animated: animated)
    }
    
    func goToCenterScreen(animated:Bool){
        let offset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        scrollView.setContentOffset(offset, animated: animated)
    }
    
    func goToRightScreen(animated:Bool){
        let offset = CGPoint(x: 2*scrollView.bounds.size.width, y: 0)
        scrollView.setContentOffset(offset, animated: animated)
    }
    
    func configureNavigationBar(){
        let transX = 22.0 - (scrollView.bounds.size.width/2.0)
        //let transX = -(scrollView.bounds.size.width/2.0)
        let scrollOffset = scrollView.contentOffset.x //min(max(scrollView.contentOffset.x, 0),scrollView.bounds.size.width*2.0)
        let multiplier = (scrollOffset - scrollView.bounds.size.width) / scrollView.bounds.size.width
        navigationBar.transform = CGAffineTransform(translationX: scrollOffset + multiplier * transX, y: 0)
        
        let leftScale = 0.75 - (multiplier * 0.25)
        leftBarButtonImage.transform = CGAffineTransform(scaleX: leftScale, y: leftScale)
        leftBarButtonImage.tintColor = UIColor(hue: leftBaseTint.hsba.h , saturation: leftBaseTint.hsba.s * max(-multiplier,0), brightness: leftBaseTint.hsba.b + ((0.8 - leftBaseTint.hsba.b) * min(1, 1 + multiplier)), alpha: 0.5 - multiplier)
        
        let centerScale = 1 - (abs(multiplier) * 0.25)
        centerBarButtonImage.transform = CGAffineTransform(scaleX: centerScale, y: centerScale)
        centerBarButtonImage.tintColor = UIColor(hue: centerBaseTint.hsba.h, saturation: centerBaseTint.hsba.s * (1 - abs(multiplier)), brightness: centerBaseTint.hsba.b + ((0.8 - centerBaseTint.hsba.b) * abs(multiplier)), alpha: 1 - 0.5*abs(multiplier))
        
        let rightScale = 0.75 + (multiplier * 0.25)
        rightBarButtonImage.transform = CGAffineTransform(scaleX: rightScale, y: rightScale)
        rightBarButtonImage.tintColor = UIColor(hue: rightBaseTint.hsba.h, saturation: rightBaseTint.hsba.s * max(multiplier, 0), brightness: rightBaseTint.hsba.b + ((0.8 - rightBaseTint.hsba.b) * min(1, 1 - multiplier)), alpha: 0.5 + multiplier)
    }
    
    func updateUnreadIndicator(){
        unreadIndicator.isHidden = !ChatService.shared.haveUnreadMessages()
    }
    
    func presentLoginViewController(animated:Bool, completion:((LoginViewController)->Void)?){
        guard !isPreseningLoginVC else { return }
        isPreseningLoginVC = true
        let loginNavVC = UIStoryboard(name: "auth", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let loginVC = loginNavVC.viewControllers.first as! LoginViewController
        present(loginNavVC, animated: animated) {
            completion?(loginVC)
        }
    }
    
    func dismissLoginViewController(animated: Bool, completion:(()->Void)?){
        dismiss(animated: true, completion: completion)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Initialization of Child View Controllers
        if let toVc = segue.destination as? ChatsViewController{
            self.chatsViewController = toVc
        }
        
        if let toVc = segue.destination as? NewMatchViewController, let user = sender as? User{
            toVc.transitioningDelegate = self
            toVc.user = user
            toVc.delegate = self
            return
        }
        if let toVc = segue.destination as? ChatViewController, let chat = sender as? Chat{
            toVc.chat = chat
        }
    }

}

extension RootViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView{
            configureNavigationBar()
            for childVC in children{
                childVC.view.endEditing(true)
            }
        }
    }
}

extension RootViewController: AuthServiceDelegate{
    func didLogin() {
        guard isPreseningLoginVC else { return }
        AuthService.shared.delegate = self
        isPreseningLoginVC = false
        dismissLoginViewController(animated: true) {
            UserService.shared.loadUsers()
        }
    }
    
    func loggedInLoadingUser() {
        //
    }
    
    func didLogoutWith(error: Error?) {
        NotificationCenter.default.post(name: Constants.NotificationName.loggedOut, object: nil)
        goToCenterScreen(animated: true)
        if isPreseningLoginVC{
            return
        }
        if let _ = presentedViewController{
            dismiss(animated: true, completion: {
                self.presentLoginVCAfterLogout(error: error)
            })
            return
        }
        presentLoginVCAfterLogout(error: error)
    }
    
    func presentLoginVCAfterLogout(error:Error?){
        self.presentLoginViewController(animated: true) { (loginVC) in
            if let error = error{
                loginVC.handleError(error: error)
            }
        }
    }
    
    func loadedCurrentUser() {
        guard let currentUser = AuthService.shared.currentUser as? CustomUser else {
            AuthService.shared.logout(onComplete: nil, onError: nil)
            return
        }
        if currentUser.privacyAccepted() && currentUser.userSetupComplete() && currentUser.images.count > 0{
            UserService.shared.loadUsers()
        }else{
            isPreseningLoginVC = true
            let sb = UIStoryboard(name: "auth", bundle: nil)
            let navVC = sb.instantiateInitialViewController() as! UINavigationController
            var vcToPush:UIViewController
            if !currentUser.privacyAccepted(){
                vcToPush = sb.instantiateViewController(withIdentifier: "PrivacyViewController")
            }else if currentUser.userSetupComplete(){
                vcToPush = sb.instantiateViewController(withIdentifier: "PictureViewController")
            }else{
                vcToPush = sb.instantiateViewController(withIdentifier: "FirstNameViewController")
            }
            navVC.pushViewController(vcToPush, animated: false)
            present(navVC, animated: true, completion: nil)
        }
    }
}

extension RootViewController: ChatServiceDelegate{
    func didReceiveNewMatch(user:User) {
        performSegue(withIdentifier: "toNewMatchViewController", sender: user)
    }
    
    func chatUpdated(chat: Chat, deleted:Bool) {
        updateUnreadIndicator()
    }
}

extension RootViewController: NewMatchViewControllerDelegate{
    func goToChatWithUser(user:User){
        goToRightScreen(animated: true)
        chatsViewController?.goToChatWithUser(user: user)
    }
}
