//
//  Journal.swift
//  ContentKit
//
//  Created by Sharkey, Justin (ELS-CON) on 10/10/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension String {
    func int() -> Int? {
        return Int(self)
    }
}

@objc(Journal)
open class Journal: NSManagedObject {
    
    static var entityName = "Journal"
    
    // Ads
    
    @NSManaged var adBannerPortraitIPad: String?
    @NSManaged var adBannerPortraitIPhone: String?
    @NSManaged var adFullPageLandscapeIPad: String?
    @NSManaged var adFullPagePortraitIPad: String?
    @NSManaged var adFullPagePortraitIPhone4: String?
    @NSManaged var adFullPagePortraitIPhone5: String?
    @NSManaged var adSkyscraperPortraitIPad: String?

    // Subscriptions
    
    @NSManaged var subscriptionId: String?
    @NSManaged var subscriptionPrice: String?
    
    // Timestamps
    
    @NSManaged var lastModified: Date?
    @NSManaged var lastUpdated: Date?
    
    // HTML
    
    @NSManaged var isAimScopeAvailable: Bool
    @NSManaged var aimScopeHTML: String?
    @NSManaged var isEditorialAvailable: Bool
    @NSManaged var editorialHTML: String?
    
    // Social
    
    @NSManaged private var facebookId: String?
    @NSManaged var journalTwitterURL: String?
    @NSManaged var journalFacebookURL: String?
    
    // Info
    
    @NSManaged var journalId: NSNumber!
    @NSManaged var journalShortCode: String?
    @NSManaged var journalTitle: String?
    @NSManaged var journalTitleIPhone: String?
    @NSManaged var issn: String!
    @NSManaged var journalDescription: String?
    @NSManaged var journalType: String?
    
    // Sequence
    
    @NSManaged var sequence: NSNumber?
    
    // AIP
    
    @NSManaged var aipDescription: String?
    @NSManaged var aipTitle: String?
    @NSManaged var isAipAvailable: Bool
    
    
    
    
    @NSManaged var abstractSummary: String?
    @NSManaged var accessType: String?
    @NSManaged private var baseContentURL: String?
    @NSManaged var baseContentURL45: String?
    @NSManaged var colorCode: String?
    @NSManaged private var coverImagePath: String?
    @NSManaged var societyLoginType: String?
    @NSManaged private var themeId: NSNumber?

    @NSManaged private var isCoverPageAvailable: Bool
    
    
    // Relationships
    
    @NSManaged var openAccess      : OA!
    @NSManaged var publisher       : Publisher!
    @NSManaged var articles        : NSSet?
    @NSManaged var authentication  : Authentication?
    @NSManaged var issues          : NSSet?
    @NSManaged fileprivate var links           : NSSet?
    @NSManaged fileprivate var partners        : NSSet?
}

// MARK: - Core Data Helpers -

extension Journal {
    
    static func getFetchRequest() -> NSFetchRequest<Journal> {
        return NSFetchRequest<Journal>(entityName: entityName)
    }
    
    static func new(context: NSManagedObjectContext) -> Journal {
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Journal
    }
}

// MARK: - Relationships -

extension Journal {
    
    var allAips: [Article] {
        return DatabaseManager.SharedInstance.getAips(journal: self)
    }
    
    var allLinks: [Link] {
        guard let response = links?.allObjects as? [Link] else {
            return []
        }
        return response
    }
    
    var allPartners: [Partner] {
        guard let partners = partners?.allObjects as? [Partner] else {
            return []
        }
        return partners
    }
    
    var allTopArticles: [Article] {
        return DatabaseManager.SharedInstance.getTopArticles(journal: self)
    }
    
    var firstIssue: Issue? {
        return DatabaseManager.SharedInstance.getMostRecentIssue(self)
    }
}

// MARK: - Authentication -

extension Journal {
    
    var isAuthenticated: Bool {
        if authentication == .none { return false }
        return true
    }
    
    var userIsAuthenticated: Bool {
        return isAuthenticated
    }
    
    var isJournalOpenAccess: Bool {
        switch openAccess.type {
        case .openAccess, .openAccessFundedBy, .openAccessFundedByIssue, .openAccessSinceWithOpenArchive:
            return true
        default:
            return false
        }
    }
    
    var isJournalOpenArchive: Bool {
        switch openAccess.type {
        case .openArchive, .openAccessSinceWithOpenArchive:
            return true
        default:
            return false
        }
    }
    
    var isJournalOpenAccessOrArchive: Bool {
        if isJournalOpenAccess || isJournalOpenArchive {
            return true
        }
        return false
    }
    
    var isJournalFree: Bool {
        if accessType == "Free Access" {
            return true
        }
        return false
    }
    
    var isJournalPurchased: Bool {
        guard let featureId = self.subscriptionId else {
            return false
        }
        return MKStoreManager.shared().isSubscriptionActive(featureId)
    }
    
    
    var userHasAccess: Bool {
        if isJournalOpenAccessOrArchive {
            return true
        }
        if isJournalFree {
            return true
        }
        if userIsAuthenticated {
            return true
        }
        if isJournalPurchased {
            return true
        }
        return false
    }
}

// MARK: - File System -

extension Journal {
    
    var basePath: String {
        return CachesDirectoryPath + issn + "/"
    }
    
    var abstractsPath: String {
        return basePath + "abstract/"
    }
    
    var fullTextPath: String {
        return basePath + "fullText/"
    }
    
    var brandImagesPath: String {
        return basePath + "brandImages/"
    }
    
    var coverImagesPath: String {
        return basePath + "coverImages/"
    }
    
    var pdfPath: String {
        return basePath + "pdf/"
    }
}

// MARK: - Colors -

extension Journal {
    var color: UIColor? {
        if let color = colorCode {
            let colorNoString = color.replacingOccurrences(of: " ", with: "")
            let colorArray = colorNoString.components(separatedBy: ",")
            if colorArray.count == 3 {
                if let redInt = Int(colorArray[0]), let greenInt = Int(colorArray[1]), let blueInt = Int(colorArray[2]) {
                    return UIColor(red: CGFloat(redInt)/255, green: CGFloat(greenInt)/255, blue: CGFloat(blueInt)/255, alpha: 1.0)
                }
            }
        }
        return nil
    }
    
    var hexColorCode: UIColor {
        if let color = colorCode {
            let colorNoString = color.replacingOccurrences(of: " ", with: "")
            let colorArray = colorNoString.components(separatedBy: ",")
            if colorArray.count == 3 {
                if let redInt = Int(colorArray[0]), let greenInt = Int(colorArray[1]), let blueInt = Int(colorArray[2]) {
                    return UIColor(red: CGFloat(redInt)/255, green: CGFloat(greenInt)/255, blue: CGFloat(blueInt)/255, alpha: 1.0)
                }
            }
        }
        return UIColor.black
    }
}

// MARK: - Setup -

extension Journal {
    
    func create(metadata: [String: AnyObject], publisher: Publisher) {
        self.publisher = publisher
        openAccess = DatabaseManager.SharedInstance.newOpenAccess()
        openAccess.journal = self
        openAccess.create(json: metadata)
        update(metadata: metadata)
    }
    
    func create(metadata: [String: AnyObject]) {
        openAccess = DatabaseManager.SharedInstance.newOpenAccess()
        openAccess.journal = self
        openAccess.create(json: metadata)
        update(metadata: metadata)
    }
    
    func setupForMigratioin() {
        openAccess = DatabaseManager.SharedInstance.newOpenAccess()
        openAccess.journal = self
        openAccess.setupDefaults()
    }
    
    func update(metadata:[String: AnyObject]) {
        
        self.abstractSummary = metadata["abstractSummary"] as? String
        if let isAipAvailable = metadata["isAipAvailable"] as? Bool {
            self.isAipAvailable = isAipAvailable
        }
        self.aipDescription = metadata["aipDescription"] as? String
        self.aipTitle = metadata["aipTitle"] as? String
        self.aimScopeHTML = metadata["aimScopeHtml"] as? String
        self.accessType = metadata["journalAccessType"] as? String
        self.adBannerPortraitIPad = metadata["adBannerPortraitIpad"] as? String
        self.adBannerPortraitIPhone = metadata["adBannerPortraitIphone"] as? String
        self.adFullPageLandscapeIPad = metadata["adFullPageLandscapeIpad"] as? String
        self.adFullPagePortraitIPad = metadata["adFullpagePortraitIpad"] as? String
        self.adFullPagePortraitIPhone4 = metadata["adFullpagePortraitIphone4"] as? String
        self.adFullPagePortraitIPhone5 = metadata["adFullpagePortraitIphone5"] as? String
        self.adSkyscraperPortraitIPad = metadata["adSkyscraperPortraitIpad"] as? String
        self.baseContentURL45 = metadata["baseContentURL45"] as? String
        //self.coverImagePath = metadata["coverImagePath"] as? String
        self.editorialHTML = metadata["editorialHtml"] as? String
        //self.facebookId = metadata["facebookId"] as? String
        if let isAimScopeAvailable = metadata["isAimScopeAvailable"] as? Bool {
            self.isAimScopeAvailable = isAimScopeAvailable
        }
        
        if let isEditorialAvailable = metadata["isEditorialAvailable"] as? Bool {
            self.isEditorialAvailable = isEditorialAvailable
        }
        self.issn = metadata["journalIssn"] as? String
        self.journalDescription = metadata["journalDescription"] as? String
        if let journalFacebookURL = metadata["journalFacebookUrl"] as? String {
            self.journalFacebookURL = journalFacebookURL != "" ? journalFacebookURL : nil
        } else {
            self.journalFacebookURL = nil
        }
        if let journalId = metadata["journalId"] as? Int {
            self.journalId = journalId as NSNumber
        }
        self.journalShortCode = metadata["journalShortCode"] as? String
        self.journalTitle = metadata["journalTitle"] as? String
        self.journalTitleIPhone = metadata["journalTitleIPhone"] as? String
        if let journalTwitterURL = metadata["journalTwitterUrl"] as? String {
            self.journalTwitterURL = journalTwitterURL != "" ? journalTwitterURL : nil
        } else {
            self.journalTwitterURL = nil
        }
        self.journalType = metadata["journalType"] as? String
        if let lastModified = metadata["lastModified"] as? String {
            let dateFormatter = DateFormatter(dateFormat: "YYYY-MM-dd HH:mm:ss")
            self.lastModified = dateFormatter.date(from: lastModified)
        }
        self.subscriptionId = metadata["subscriptionId"] as? String
        self.subscriptionPrice = metadata["subscriptionPrice"] as? String
        self.societyLoginType = metadata["societyLoginType"] as? String
        if let sequence = metadata["sequence"] as? Int {
            self.sequence = sequence as NSNumber
        }
        self.colorCode = metadata["colorCode"] as? String
        self.baseContentURL45 = metadata["baseContentURL45"] as? String
    }
}
