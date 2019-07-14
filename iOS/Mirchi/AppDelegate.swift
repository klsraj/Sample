//
//  AppDelegate.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 27/07/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import FirebaseDatabase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleMaps
import GooglePlaces
import GoogleMobileAds
import StoreKit
import UserNotifications
import SDWebImage
import DropletIF

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AuthServiceDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    var fauxLaunchScreen:UIViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
//        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        Configuration.shared.setLicenceKey(key: Config.Licences.dropletKey)
        Configuration.shared.userType = CustomUser.self
        Database.setLoggingEnabled(true)
        
        Messaging.messaging().delegate = self
        registerForNotifications(application: application)
        
        GMSServices.provideAPIKey(Config.Licences.googleMapsKey)
        GMSPlacesClient.provideAPIKey(Config.Licences.googleMapsKey)
        
        Configuration.shared.configureExplorer(premiumOnly: Config.Features.passportIsPremium)
        Configuration.shared.configureLikeLimit(basicLimit: Config.LikeLimits.freeLikeLimit, premiumLimit: Config.LikeLimits.subscribedLikeLimit, waitTime: Config.LikeLimits.likeLimitWaitTime)
        Configuration.shared.configureSuperLikeLimit(basicLimit: Config.LikeLimits.freeSuperLikeLimit, premiumLimit: Config.LikeLimits.subscribedSuperLikeLimit, waitTime: Config.LikeLimits.superlikeLimitWaitTime)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        SKPaymentQueue.default().add(StoreService.shared)
        StoreService.shared.validateReceipt(completion: nil)
        StoreService.shared.setProductIdentifiers(identifiers: [
            Config.ProductID.monthly,
            Config.ProductID.biannually,
            Config.ProductID.annually
        ])
        StoreService.shared.validateProductIdentifiers()
        
        ChatService.shared.addDelegate(delegate: NotificationService.shared)
        
        clearFirebaseKeyStoreOnInitialLaunch()
        
        presentInitialController()
        
        return true
    }
    
    func configureServices(){
        
    }
    
    func clearFirebaseKeyStoreOnInitialLaunch(){
        if !UserDefaults.standard.bool(forKey: "hasPreviouslyLaunched"){
            AuthService.shared.logout(onComplete: nil, onError: nil)
            UserDefaults.standard.set(true, forKey: "hasPreviouslyLaunched")
        }
    }
    
    func clearNotifications(){
        UIApplication.shared.applicationIconBadgeNumber = 0
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        if let currentUser = AuthService.shared.currentUser{
            Database.database().reference().child("badge_count/\(currentUser.uid)").setValue(0)
        }
    }
    
    func registerForNotifications(application:UIApplication){
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
                NotificationService.shared.retrieveNotificationsStatus()
            }
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        NotificationCenter.default.post(name: Constants.NotificationName.legacyNotificationsRegistered, object: notificationSettings)
        NotificationService.shared.retrieveNotificationsStatus()
    }
    
    func presentInitialController(){
        //Add fake launch screen for smooth logged in/out screen appearance
        
        //loginViewController = UIStoryboard(name: "auth", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        fauxLaunchScreen = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()!
        fauxLaunchScreen.view.frame = UIScreen.main.bounds//loginViewController.view.bounds
        fauxLaunchScreen.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        window?.makeKeyAndVisible()
        window?.addSubview(fauxLaunchScreen.view)
        AuthService.shared.delegate = self
    }
    
    //Auth Service Delegate Methods
    
    func didLogin() {
        let rootViewController = window?.rootViewController as? RootViewController
        AuthService.shared.delegate =  rootViewController
        //rootViewController?.didLogin()
        
        guard AuthService.shared.currentUser != nil else {
            AuthService.shared.logout(onComplete: nil, onError: nil)
            return
        }
        
        //User already logged in, hide fake launch screen
        UIView.animate(withDuration: 0.5, animations: {
            self.fauxLaunchScreen.view.alpha = 0
        }, completion: { (_) in
            self.fauxLaunchScreen.view.removeFromSuperview()
        })
    }
    
    func loggedInLoadingUser() {
        let rootViewController = window?.rootViewController as? RootViewController
        AuthService.shared.delegate =  rootViewController
        
        //No user logged in, present login screen then hide fake launch screen
        
        //Using DispatchQueue to prevent "Unbalanced calls to begin/end appearance transitions"
        DispatchQueue.global().async {
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                rootViewController?.presentLoginViewController(animated: false, completion: { (loginVC) in
                    loginVC.showLoading()
                    UIView.animate(withDuration: 0.5, animations: {
                        self.fauxLaunchScreen.view.alpha = 0
                    }, completion: { (_) in
                        self.fauxLaunchScreen.view.removeFromSuperview()
                    })
                })
            }
        }
    }
    
    func didLogoutWith(error: Error?) {
        
        let rootViewController = window?.rootViewController as? RootViewController
        AuthService.shared.delegate =  rootViewController
        
        //No user logged in, present login screen then hide fake launch screen
        
        //Using DispatchQueue to prevent "Unbalanced calls to begin/end appearance transitions"
        DispatchQueue.global().async {
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                rootViewController?.presentLoginViewController(animated: false, completion: { (loginVC) in
                    loginVC.checkForPhoneAuthVerification()
                    UIView.animate(withDuration: 0.5, animations: {
                        self.fauxLaunchScreen.view.alpha = 0
                    }, completion: { (_) in
                        self.fauxLaunchScreen.view.removeFromSuperview()
                    })
                })
            }
        }
    }
    
    func loadedCurrentUser() {
        //
        UserService.shared.loadUsers()
    }
    
    // MARK: - Firebase Messaging Delegate
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        AuthService.shared.uploadFCMToken()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        clearNotifications()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Database.database().goOffline()
        ChatService.shared.removeChatsListener()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        Database.database().goOnline()
        ChatService.shared.addChatsListener()
        NotificationService.shared.retrieveNotificationsStatus()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        clearNotifications()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

