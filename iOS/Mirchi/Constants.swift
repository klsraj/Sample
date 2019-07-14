//
//  Constants.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 21/01/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import Foundation

struct Constants{
    
    struct NotificationName{
        static let accountDeleted = Notification.Name("com.samueljharrison.droplet.notification.accountDeleted")
        static let loggedOut = Notification.Name("com.samueljharrison.droplet.notification.loggedOut")
        static let legacyNotificationsRegistered = Notification.Name("com.samueljharrison.droplet.notification.legacyNotificationsRegistered")
        static let notificationsSettingsChanged = Notification.Name("com.samueljharrison.droplet.notification.notificationSettingsChanged")
    }
}
