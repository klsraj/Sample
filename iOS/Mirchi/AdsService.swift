//
//  AdsService.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 04/02/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import UIKit
import GoogleMobileAds
import DropletIF

class AdsService: NSObject{

    static let shared = AdsService()
    private var interstitial:GADInterstitial?

    private override init() {
        super.init()
        createAndLoadInterstitial()
    }

    func getRequest()->GADRequest{
        let request = GADRequest()
        //request.testDevices = ["17d28b59968103a6c86c45d10ce666e0"]
        return request
    }

    func createAndLoadInterstitial(){
        interstitial = GADInterstitial(adUnitID: Config.AdMob.interstitialID)
        interstitial?.delegate = self
        interstitial?.load(getRequest())
    }

    func getInterstitial() -> GADInterstitial?{
        if !Config.Features.adsEnabled{
            return nil
        }
        if Config.Features.adsRemovedIfSubscribed && StoreService.shared.isSubscribed(){
            return nil
        }
        guard let ad = self.interstitial else{
            createAndLoadInterstitial()
            return nil
        }
        if ad.isReady{
            return interstitial
        }
        return nil
    }

}

extension AdsService: GADInterstitialDelegate{
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        createAndLoadInterstitial()
    }
}
