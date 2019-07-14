//
//  Config.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 19/03/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import Foundation

struct Config{
    
    struct Features{
        static let minimumUserAge:Int = 18
        static let rewindIsPremium = true
        static let passportIsPremium = true
        static let adsEnabled = true
        static let adsSwipeCount = 10
        static let adsRemovedIfSubscribed = true
    }
    
    struct LikeLimits{
        static let freeLikeLimit = 50
        static let subscribedLikeLimit = -1
        static let likeLimitWaitTime:TimeInterval = 24*60*60
        
        static let freeSuperLikeLimit = 1
        static let subscribedSuperLikeLimit = 5
        static let superlikeLimitWaitTime:TimeInterval = 24*60*60
    }
    
    struct Licences{
        static let dropletKey = "e922158a04cff12f365c60589c14361c"
        static let googleMapsKey = "AIzaSyB1PWpIh-Wv6xPeriby1XTZyz49hjLsNgE"
        
    }
    
    struct ProductID{
        static let monthly = "com.Mirchi_Co.Mirchi.iap.monthly"
        static let biannually = "com.Mirchi_Co.Mirchi.iap.biannual"
        static let annually =  "com.Mirchi_Co.Mirchi.iap.annual"
    }
    
    struct AdMob{
        static let appID = "ca-app-pub-4760370857956267~6360852158"
        static let matchesBannerID = "ca-app-pub-4760370857956267/3037341354"
        static let interstitialID = "ca-app-pub-4760370857956267/8485109159"
        static let chatBannerID = "ca-app-pub-4760370857956267/2195689516"
    }

}
