//
//  Publisher.swift
//  ContentKit
//
//  Created by Sharkey, Justin (ELS-CON) on 10/10/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(Publisher)
open class Publisher: NSManagedObject {
    
    @NSManaged open var adBannerPortraitIPad: String?
    @NSManaged open var adBannerPortraitIPhone: String?
    @NSManaged open var adBannerPortraitSplashIPad: String?
    @NSManaged open var adBannerPortraitSplashIPhone: String?
    @NSManaged open var adFullPageLandscapeIPad: String?
    @NSManaged open var adFullPagePortraitIPad: String?
    @NSManaged open var adFullPagePortraitIPhone4: String?
    @NSManaged open var adFullPagePortraitIPhone5: String?
    @NSManaged open var adInterval: NSNumber?
    @NSManaged open var adMobDownloadKeyIPad: String?
    @NSManaged open var adMobDownloadKeyIPhone: String?
    @NSManaged open var adMobFullPageLandscapeKeyIPad: String?
    @NSManaged open var adMobFullPageLandscapeKeyIPhone: String?
    @NSManaged open var adMobFullPagePortraitKeyIPad: String?
    @NSManaged open var adMobFullPagePortraitKeyIPhone: String?
    @NSManaged open var adMobHomeKeyIPad: String?
    @NSManaged open var adMobHomeKeyIPhone: String?
    @NSManaged open var adMobNavKeyIPad: String?
    @NSManaged open var adMobNavKeyIPhone: String?
    @NSManaged open var adMobSkyScrapperIPad: String?
    @NSManaged open var adMobSkyScrapperIPhone: String?
    @NSManaged open var adMobTOCKeyIPad: String?
    @NSManaged open var adMobTOCKeyIPhone: String?
    @NSManaged open var appId: NSNumber?
    @NSManaged open var appShortCode: String?
    @NSManaged open var appTitle: String?
    @NSManaged open var appTitleIPhone: String?
    @NSManaged open var appVersion: String?
    @NSManaged open var dartId: String?
    @NSManaged open var desc: String?
    @NSManaged open var flurryId: String?
    @NSManaged open var googleAnalyticsCode: String?
    @NSManaged open var isSocietyInfoAvailable: NSNumber?
    @NSManaged open var lastModified: Date?
    @NSManaged open var s3BaseURL: String?
    @NSManaged open var societyFacebookURL: String?
    @NSManaged open var societyTwitterURL: String?
    @NSManaged open var updateLinkDescription: String?
    @NSManaged open var updateLinkTitle: String?
    @NSManaged open var updateLinkURL: String?
    @NSManaged open var updateVersion: String?
    @NSManaged open var faq: String?
    @NSManaged open var terms: String?
    @NSManaged open var support: String?
    
    @NSManaged open var journals: NSSet?
    @NSManaged open var links: NSSet?

    func create(_ metadata:[String: AnyObject]) {
        self.update(metadata)
    }
    
    func update(_ metadata:[String: AnyObject]) {
        
        if let adBannerPortraitIPad = metadata["Ad_Banner_Portrait_Ipad"] as? String {
            if adBannerPortraitIPad != "" {
                self.adBannerPortraitIPad = adBannerPortraitIPad
            }
        }
        
        if let adBannerPortraitIPhone = metadata["Ad_Banner_Portrait_Iphone"] as? String {
            if adBannerPortraitIPhone != "" {
                self.adBannerPortraitIPhone = adBannerPortraitIPhone
            }
        }
        
        if let adBannerPortraitSplashIPad = metadata["Ad_Banner_Portrait_Splash_Ipad"] as? String {
            self.adBannerPortraitSplashIPad = adBannerPortraitSplashIPad
        }
        
        if let adBannerPortraitSplashIPhone = metadata["Ad_Banner_Portrait_Splash_Iphone"] as? String {
            self.adBannerPortraitSplashIPhone = adBannerPortraitSplashIPhone
        }
        
        if let adFullPageLandscapeIPad = metadata["Ad_Fullpage_Landscape_Ipad"] as? String {
            self.adFullPageLandscapeIPad = adFullPageLandscapeIPad
        }
        
        if let adFullPagePortraitIPad = metadata["Ad_Fullpage_Portrait_Ipad"] as? String {
            self.adFullPagePortraitIPad = adFullPagePortraitIPad
        }
        
        if let adFullPagePortraitIPhone4 = metadata["Ad_Fullpage_Portrait_Iphone4"] as? String {
            self.adFullPagePortraitIPhone4 = adFullPagePortraitIPhone4
        }
        
        if let adFullPagePortraitIPhone5 = metadata["Ad_Fullpage_Portrait_Iphone5"] as? String {
            self.adFullPagePortraitIPhone5 = adFullPagePortraitIPhone5
        }
        
        if let adInterval = metadata["ADInterval"] as? Int {
            self.adInterval = adInterval as NSNumber?
        } else if let adInterval = metadata["ADInterval"] as? NSString {
            self.adInterval = adInterval.integerValue as NSNumber?
        }
        
        if let adMobDownloadKeyIPad = metadata["AdMobDownloadKeyIpad"] as? String {
            if adMobDownloadKeyIPad != "" {
                self.adMobDownloadKeyIPad = adMobDownloadKeyIPad
            }
        }
        
        if let adMobDownloadKeyIPhone = metadata["AdMobDownloadKeyIphone"] as? String {
            if adMobDownloadKeyIPhone != "" {
                self.adMobDownloadKeyIPhone = adMobDownloadKeyIPhone
            }
        }
        
        if let adMobFullPageLandscapeKeyIPad = metadata["AdMobFullPageLandscapeKeyIpad"] as? String {
            if adMobFullPageLandscapeKeyIPad != "" {
                self.adMobFullPageLandscapeKeyIPad = adMobFullPageLandscapeKeyIPad
            }
        }
        
        if let adMobFullPageLandscapeKeyIPhone = metadata["AdMobFullPageLandscapeKeyIPhone"] as? String {
            if adMobFullPageLandscapeKeyIPhone != "" {
                self.adMobFullPageLandscapeKeyIPhone = adMobFullPageLandscapeKeyIPhone
            }
        }
        
        if let adMobFullPagePortraitKeyIPad = metadata["AdMobFullPagePortraitKeyIpad"] as? String {
            if adMobFullPagePortraitKeyIPad != "" {
                self.adMobFullPagePortraitKeyIPad = adMobFullPagePortraitKeyIPad
            }
        }
        
        if let adMobFullPagePortraitKeyIPhone = metadata["AdMobFullPagePortraitKeyIphone"] as? String {
            if adMobFullPagePortraitKeyIPhone != "" {
                self.adMobFullPagePortraitKeyIPhone = adMobFullPagePortraitKeyIPhone
            }
        }
        
        if let adMobHomeKeyIPad = metadata["AdMobHomeKeyIpad"] as? String {
            if adMobHomeKeyIPad != "" {
                self.adMobHomeKeyIPad = adMobHomeKeyIPad
            }
        }
        
        if let adMobHomeKeyIPhone = metadata["AdMobHomeKeyIphone"] as? String {
            if adMobHomeKeyIPhone != "" {
                self.adMobHomeKeyIPhone = adMobHomeKeyIPhone
            }
        }
        
        if let adMobNavKeyIPad = metadata["AdMobNavKeyIpad"] as? String {
            if adMobNavKeyIPad != "" {
                self.adMobNavKeyIPad = adMobNavKeyIPad
            }
        }
        
        if let adMobNavKeyIPhone = metadata["AdMobNavKeyIphone"] as? String {
            if adMobNavKeyIPhone != "" {
                self.adMobNavKeyIPhone = adMobNavKeyIPhone
            }
        }
        
        if let adMobSkyScrapperIPad = metadata["AdMobSkyScrapperIpad"] as? String {
            if adMobSkyScrapperIPad != "" {
                self.adMobSkyScrapperIPad = adMobSkyScrapperIPad
            }
        }
        
        if let adMobSkyScrapperIPhone = metadata["AdMobSkyScrapperIphone"] as? String {
            if adMobSkyScrapperIPhone != "" {
                self.adMobSkyScrapperIPhone = adMobSkyScrapperIPhone
            }
        }
        
        if let adMobTOCKeyIPad = metadata["AdMobTOCKeyIpad"] as? String {
            if adMobTOCKeyIPad != "" {
                self.adMobTOCKeyIPad = adMobTOCKeyIPad
            }
        }
        
        if let adMobTOCKeyIPhone = metadata["AdMobTOCKeyIphone"] as? String {
            if adMobTOCKeyIPhone != "" {
                self.adMobTOCKeyIPhone = adMobTOCKeyIPhone
            }
        }
        
        if let appId = metadata["App_ID"] as? NSString {
            self.appId = appId.integerValue as NSNumber?
        }
        
        if let appShortCode = metadata["App_Short_Code"] as? String {
            self.appShortCode = appShortCode
        }
        
        if let appTitle = metadata["App_Title"] as? String {
            self.appTitle = appTitle
        }
        
        if let appTitleIPhone = metadata["App_Title_iPhone"] as? String {
            self.appTitleIPhone = appTitleIPhone
        }
        
        if let appVersion = metadata["AppVersion"] as? String {
            self.appVersion = appVersion
        }
        
        if let dartId = metadata["Dart_ID"] as? String {
            self.dartId = dartId
        }
        
        if let desc = metadata["Description"] as? String {
            self.desc = desc
        }
        
        if let flurryId = metadata["Flurry_ID"] as? String {
            self.flurryId = flurryId
        }
        
        if let isSocietyInfoAvailable = metadata["isSocietyInfoAvailable"] as? NSString {
            self.isSocietyInfoAvailable = isSocietyInfoAvailable.boolValue as NSNumber?
        }
        
        if let lastModified = metadata["Last_Modified"] as? String {
            let dateFromatter = DateFormatter()
            dateFromatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            if let date = dateFromatter.date(from: lastModified) {
                self.lastModified = date
            }
        }
        
        if let s3BaseURL = metadata["s3_base_url"] as? String {
            self.s3BaseURL = s3BaseURL
        }
        
        if let societyFacebookURL = metadata["Society_Facebook_URL"] as? String {
            self.societyFacebookURL = societyFacebookURL
        }
        
        if let societyTwitterURL = metadata["Society_Twitter_URL"] as? String {
            self.societyTwitterURL = societyTwitterURL
        }
        
        if let updateLinkDescription = metadata["Update_Link_Description"] as? String {
            self.updateLinkDescription = updateLinkDescription
        }
        
        if let updateLinkTitle = metadata["Update_Link_Title"] as? String {
            self.updateLinkTitle = updateLinkTitle
        }
        
        if let updateLinkURL = metadata["Update_Link_URL"] as? String {
            self.updateLinkURL = updateLinkURL
        }
        
        if let updateVersion = metadata["Update_Version"] as? String {
            self.updateVersion = updateVersion
        }
    }
    
    public func createWithCase(metadata: [String: AnyObject]) {
        updateWithCase(metadata: metadata)
    }
    
    public func updateWithCase(metadata: [String: AnyObject]) {
        
        /*self.adMobDownloadKeyIPad = metadata["AdMobDownloadKeyIpad"] as? String
         self.adMobDownloadKeyIPhone = metadata["AdMobDownloadKeyIphone"] as? String
         self.adMobFullPageLandscapeKeyIPad = metadata["AdMobFullPageLandscapeKeyIpad"] as? String
         self.adMobFullPageLandscapeKeyIPhone = metadata["AdMobFullPageLandscapeKeyIPhone"] as? String
         self.adMobFullPagePortraitKeyIPad = metadata["AdMobFullPagePortraitKeyIpad"] as? String
         self.adMobFullPagePortraitKeyIPhone = metadata["AdMobFullPagePortraitKeyIphone"] as? String
         self.adMobHomeKeyIPad = metadata["adMobHomeKeyIpad"] as? String
         self.adMobHomeKeyIPhone = metadata["adMobHomeKeyIphone"] as? String
         self.adMobNavKeyIPad = metadata["adMobNavKeyIpad"] as? String
         self.adMobNavKeyIPhone = metadata["adMobNavKeyIphone"] as? String
         self.adMobSkyScrapperIPad = metadata["AdMobSkyScrapperIpad"] as? String
         self.adMobSkyScrapperIPhone = metadata["AdMobSkyScrapperIphone"] as? String
         self.adMobTOCKeyIPad = metadata["AdMobTOCKeyIpad"] as? String
         self.adMobTOCKeyIPhone = metadata["AdMobTOCKeyIphone"] as? String
         self.dartId = metadata["Dart_ID"] as? String
         self.flurryId = metadata["Flurry_ID"] as? String
         self.s3BaseURL = metadata["s3_base_url"] as? String*/
        
        self.adBannerPortraitIPad = metadata["adBannerPortraitIpad"] as? String
        self.adBannerPortraitIPhone = metadata["adBannerPortraitIphone"] as? String
        self.adBannerPortraitSplashIPad = metadata["adBannerPortraitSplashIpad"] as? String
        self.adBannerPortraitSplashIPhone = metadata["adBannerPortraitSplashIPhone"] as? String
        self.adFullPageLandscapeIPad = metadata["adFullpageLandscapeIpad"] as? String
        self.adFullPagePortraitIPad = metadata["adFullpagePortraitIpad"] as? String
        self.adFullPagePortraitIPhone4 = metadata["adFullpagePortraitIphone4"] as? String
        self.adFullPagePortraitIPhone5 = metadata["adFullpagePortraitIphone5"] as? String
        if let adInterval = metadata["adInterval"] as? Int {
            self.adInterval = adInterval as NSNumber
        }
        if let appId = metadata["appId"] as? Int {
            self.appId = appId as NSNumber
        }
        self.appShortCode = metadata["appShortCode"] as? String
        self.appTitle = metadata["appTitle"] as? String
        self.appTitleIPhone = metadata["appTitleIPhone"] as? String
        self.appVersion = metadata["appVersion"] as? String
        self.desc = metadata["description"] as? String
        if let isSocietyInfoAvailable = metadata["societyInfoAvailable"] as? Bool {
            self.isSocietyInfoAvailable = isSocietyInfoAvailable as NSNumber
        }
        if let lastModified = metadata["lastModified"] as? String {
            let dateFromatter = DateFormatter(dateFormat: "YYYY-MM-dd HH:mm:ss")
            if let date = dateFromatter.date(from: lastModified) {
                self.lastModified = date
            }
        }
        self.societyFacebookURL = metadata["soceityFacebookUrl"] as? String
        self.societyTwitterURL = metadata["soceityTwitterUrl"] as? String
        self.updateLinkDescription = metadata["updateLinkDescription"] as? String
        self.updateLinkTitle = metadata["updateLinkTitle"] as? String
        self.updateLinkURL = metadata["updateLinkUrl"] as? String
        self.updateVersion = metadata["updateVersion"] as? String
    }
    
    var journalListXML: String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        xml += "<issns>"
        if let journalList = journals?.allObjects as? [Journal] {
            for journal in journalList {
                xml += "<issn>\(journal.issn)</issn>"
            }
        }
        xml += "</issns>"
        return xml
    }

    var allJournals: [Journal] {
        if let allJournals = self.journals?.allObjects as? [Journal] {
            return allJournals
        }
        return []
    }
    
    var allLinks: [SocietyLink] {
        guard let links = self.links?.allObjects as? [SocietyLink] else {
            return []
        }
        return links
    }
}
