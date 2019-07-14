//
//  CountryCodes.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 08/12/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit

let JSON_COUNTRY_NAME_KEY = "name";
let JSON_LOCALIZED_COUNTRY_NAME_KEY = "localized_name";
let JSON_COUNTRY_CODE_KEY = "iso2_cc";
let JSON_DIALCODE_KEY = "e164_cc";
let JSON_LEVEL_KEY = "level";
let JSON_EXAMPLE_KEY = "example";
let JSON_COUNTRY_CODE_PREDICATE = "(iso2_cc like[c] %)";
let JSON_COUNTRY_NAME_PREDICATE = "(localized_name beginswith[cd] %)";
let FUIDefaultCountryCode = "US";

class CountryCodeInfo:NSObject {
    var countryName:String?
    var localizedCountryName:String?
    var countryCode:String?
    var dialCode:String?
    var level:String?
    var example:String?
    
    func countryFlagEmoji()->String?{
        guard let code = countryCode else { return nil }
        let base:UInt32 = 127397
        var s = ""
        for v in code.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
}

class CountryCodes: NSObject {
    
    static let shared = CountryCodes()
    var countryCodesArray = [[String:AnyObject]]()
    
    override init() {
        super.init()
        guard let countryCodesFile = Bundle.main.path(forResource: "country-codes", ofType: "json"), let rawData = FileManager.default.contents(atPath: countryCodesFile) else {
            print("Country codes file not found!")
            return
        }
        guard let object = (((try? JSONSerialization.jsonObject(with: rawData, options: .mutableContainers) as? [[String:AnyObject]]) as [[String : AnyObject]]??)) else {
            print("Error reading json file!")
            return
        }
        countryCodesArray = object!
        localizeCountryCodeArray()
        sortCountryCodeArray()
    }
    
    func localizeCountryCodeArray(){
        var array = [[String:AnyObject]]()
        for dict in countryCodesArray{
            var newDict = dict
            newDict[JSON_LOCALIZED_COUNTRY_NAME_KEY] = localizedCountryNameForCode(countryCode: dict[JSON_COUNTRY_CODE_KEY] as? String) as AnyObject
            array.append(newDict)
        }
        countryCodesArray = array
    }
    
    func sortCountryCodeArray(){
        countryCodesArray.sort { (dict1, dict2) -> Bool in
            return (dict1[JSON_LOCALIZED_COUNTRY_NAME_KEY] as? String ?? "") < (dict2[JSON_LOCALIZED_COUNTRY_NAME_KEY] as? String ?? "")
        }
    }
    
    func localizedCountryNameForCode(countryCode:String?) -> String?{
        guard let code = countryCode else { return nil }
        return (Locale.current as NSLocale).displayName(forKey: .countryCode, value: code)
    }
    
    func countryCodeInfoForDict(dict:[String:AnyObject]) -> CountryCodeInfo{
        let info = CountryCodeInfo()
        info.countryName = dict[JSON_COUNTRY_NAME_KEY] as? String
        info.localizedCountryName = dict[JSON_LOCALIZED_COUNTRY_NAME_KEY] as? String
        info.countryCode = dict[JSON_COUNTRY_CODE_KEY] as? String
        info.dialCode = dict[JSON_DIALCODE_KEY] as? String
        info.level = dict[JSON_LEVEL_KEY] as? String
        info.example = dict[JSON_EXAMPLE_KEY] as? String
        return info
    }
    
    func countryCodeInfoAtIndex(index:Int) -> CountryCodeInfo{
        return countryCodeInfoForDict(dict: countryCodesArray[index])
    }
    
    func infoForCountryCode(countryCode:String) -> CountryCodeInfo{
        return countryCodeInfoForDict(dict: countryCodesArray.first(where: {$0[JSON_COUNTRY_CODE_KEY] as? String == countryCode}) ?? countryCodesArray[0])
    }
    
    func indexForCountryCode(countryCode:String?) -> Int?{
        guard let code = countryCode else { return nil }
        return countryCodesArray.firstIndex(where: {$0[JSON_COUNTRY_CODE_KEY] as? String == code})
    }
    
    func indexForDialCode(dialCode:String?) -> Int?{
        guard let code = dialCode else { return nil }
        return countryCodesArray.firstIndex(where: {$0[JSON_DIALCODE_KEY] as? String == code})
    }
}
