//
//  NotificationService.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 16/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import CoreMedia
import JDStatusBarNotification
import UserNotifications
import DropletIF
import FirebaseDatabase

class NotificationService: NSObject, ChatServiceDelegate {

    static let shared = NotificationService()
    var currentChat:Chat?
    var newMessageSoundID:SystemSoundID = 0
    var newMatchSoundID:SystemSoundID = 0
    var customSounds:[String:SystemSoundID] = [String:SystemSoundID]()
    var notificationsEnabled:Bool = true{
        didSet{
            if oldValue != notificationsEnabled{
                NotificationCenter.default.post(name: Constants.NotificationName.notificationsSettingsChanged, object: nil)
            }
        }
    }

    override init() {
        super.init()
        preloadSounds()
        setupNotificationStyles()
    }

    func retrieveNotificationsStatus(){
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized{
                    if settings.alertSetting == .enabled || settings.badgeSetting == .enabled || settings.soundSetting == .enabled{
                        self.notificationsEnabled = true
                        return
                    }
                }
                self.notificationsEnabled = false
            }
        } else {
            let notificationSettings:UIUserNotificationSettings = UIApplication.shared.currentUserNotificationSettings ?? UIUserNotificationSettings(types: [], categories: nil)
            notificationsEnabled = !notificationSettings.types.isEmpty
        }
    }

    func getRemoteNotificationStatus(complete:@escaping (_ registered:Bool)->Void){
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus == .denied{
                    complete(false)
                }else{
                    complete(true)
                }
            }
        } else {
            let notificationSettings:UIUserNotificationSettings = UIApplication.shared.currentUserNotificationSettings ?? UIUserNotificationSettings(types: [], categories: nil)
            if notificationSettings.types.isEmpty{
                complete(false)
            }
            complete(true)
        }
    }

    func tryRegisteringForNotifications(){
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func setupNotificationStyles(){
        JDStatusBarNotification.addStyleNamed("NewMatchStyle") { (style) -> JDStatusBarStyle? in
            style.barColor = Colors.darkPurple
            style.textColor = UIColor.white
            style.font = UIFont.boldSystemFont(ofSize: 14.0)
            style.animationType = JDStatusBarAnimationType.bounce
            return style
        }

        JDStatusBarNotification.addStyleNamed("NewMessageStyle") { (style) -> JDStatusBarStyle? in
            style.barColor = UIColor.white
            style.textColor = Colors.darkPurple
            style.font = UIFont.boldSystemFont(ofSize: 14.0)
            style.animationType = JDStatusBarAnimationType.bounce
            return style
        }
    }

    func setMessageSound(filename:String, fileExtension:String){
        newMessageSoundID = createSoundIDWithName(filename, fileExtension: fileExtension)
    }

    func setMatchSound(filename:String, fileExtension:String){
        newMatchSoundID = createSoundIDWithName(filename, fileExtension: fileExtension)
    }

    func showNewMatchNotification(withSound:Bool){
        JDStatusBarNotification.show(withStatus: NSLocalizedString("NOTIFICATION_NEW_MATCH_TITLE", comment: "New Match Notification Text"), dismissAfter: 3.0, styleName: "NewMatchStyle")
        if withSound{
            playNewMatchSound()
        }
    }

    func showNewMessageNotification(withSound:Bool){
        JDStatusBarNotification.show(withStatus: NSLocalizedString("NOTIFICATION_NEW_MESSAGE_TITLE", comment: "New Message Notification Text"), dismissAfter: 3.0, styleName: "NewMessageStyle")
        if withSound{
            playNewMessageSound()
        }
    }

    func playNewMessageSound(){
        guard UserSettings.shared.inAppSounds else { return }
        AudioServicesPlayAlertSound(newMessageSoundID)
    }

    func playNewMatchSound(){
        guard UserSettings.shared.inAppSounds else { return }
        AudioServicesPlayAlertSound(newMatchSoundID)
    }

    private func preloadSounds(){
        setMessageSound(filename: "NewMessage", fileExtension: "mp3")
        setMatchSound(filename: "NewMatch", fileExtension: "mp3")
    }

    private func createSoundIDWithName(_ filename:String,fileExtension:String)->SystemSoundID{
        let fileURL = Bundle.main.url(forResource: filename, withExtension: fileExtension)
        if(fileURL != nil && FileManager.default.fileExists(atPath: fileURL!.path)){
            var soundID:SystemSoundID = 0
            let error = AudioServicesCreateSystemSoundID(fileURL! as CFURL, &soundID)
            if(error != kAudioServicesNoError){
                print("Error! SystemSoundID could not be created")
                return 0
            }else{
                return soundID
            }
        }
        print("Error: audio file not found: \(String(describing: fileURL))")
        return 0
    }

    // MARK: - Chat Service Delegate

    func didReceiveNewMatch(user: User) {
        showNewMatchNotification(withSound: UserSettings.shared.inAppSounds)
    }

    func chatDidReceiveMessage(chat: Chat, message: Message, isNew: Bool) {
        if isNew && chat.chatId != currentChat?.chatId && message.senderId != AuthService.shared.currentUser?.uid{
            showNewMessageNotification(withSound: UserSettings.shared.inAppSounds)
        }
    }
}
