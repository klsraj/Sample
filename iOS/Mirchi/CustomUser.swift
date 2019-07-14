//
//  CustomUser.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 16/02/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import UIKit
import FirebaseDatabase
import DropletIF

class CustomUser: User {
    
    public var privacyAcceptedDate:Date?{
        didSet{
            if oldValue != privacyAcceptedDate && isCurrentUser(){// && !isUpdating{
                Database.database().reference().child("users/\(uid)/privacyAccepted").setValue(privacyAcceptedDate?.timeIntervalSince1970)
            }
        }
    }
    
    public var religion:String? {
        didSet{
            if oldValue != religion && isCurrentUser() && !isUpdating{
                Database.database().reference().child("users/\(uid)/religion").setValue(religion)
            }
        }
    }
    
    public var community:String? {
        didSet{
            if oldValue != community && isCurrentUser(){ //&& !isUpdating{
                Database.database().reference().child("users/\(uid)/community").setValue(community)
            }
        }
    }
    
    public var country:String? {
        didSet{
            if oldValue != country && isCurrentUser() && !isUpdating{
                Database.database().reference().child("users/\(uid)/filters/country").setValue(country)
            }
        }
    }
    
    override func customUpdateWithObject(object: [String : Any]) {
        if let filters = object["filters"] as? [String:Any]{
            self.country = filters["country"] as? String
        }
        self.religion = object["religion"] as? String
        if let privacyTimestamp = object["privacyAccepted"] as? TimeInterval{
            self.privacyAcceptedDate = Date(timeIntervalSince1970: privacyTimestamp)
        }
        self.community = object["community"] as? String
    }
    
    override func isSuitableFor(user: User) -> Bool {
        return super.isSuitableFor(user: user)
    }
    
    func privacyAccepted()->Bool{
        return self.privacyAcceptedDate != nil
    }
}
