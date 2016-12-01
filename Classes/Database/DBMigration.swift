//
//  DBMigration.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/22/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

import FMDB

private extension Strings {
    class DB {
        
        struct DateTimeTbl {
            static let TableName = "DateTimeTbl"
            
            static let css_date = "css_date"
            static let issue_id = "issue_id"
            static let article_datetime = "article_datetime"
            static let aip_datetime = "aip_datetime"
            static let journal_id = "journal_id"
            static let issue_datetime = "issue_datetime"
        }

        struct HIGHLIGHTOBJECT {
            static let TableName = "HIGHLIGHTOBJECT"
            
            static let HIGHLIGHT_ID = "HIGHLIGHT_ID"
            static let NOTE = "NOTE"
            static let SELECTED_TEXT = "SELECTED_TEXT"
            static let SAVED_ON_DATE = "SAVED_ON_DATE"
            static let SELECTED_ARTICLE_INFO_ID = "SELECTED_ARTICLE_INFO_ID"
            static let NOTE_POSITION = "NOTE_POSITION"
            static let JOURNAL_ID = "JOURNAL_ID"
        }

        struct highlighttbl {
            static let TableName = "highlighttbl"
            
            static let id = "id"
            static let highlight_id = "highlight_id"
            static let selection_text = "selection_text"
            static let articleId = "articleId"
            static let myNotes = "myNotes"
            static let article_info_id = "article_info_id"
        }

        struct thumbstbl {
            static let TableName = "thumbstbl"
            
            static let Thumb_ID = "Thumb_ID"
            static let Ref_ID = "Ref_ID"
            static let Thumb = "Thumb"
            static let Fig_No = "Fig_No"
            static let Caption = "Caption"
            static let article_info_id = "article_info_id"
        }
    }
}

// MARK: - Base -

class DBMigration {
    
    let db = FMDatabase(path: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] + "/dbJAT.sqlite")
    
    init?() {
        if !(db?.open())! {
            return nil
        }
    }
    
    func migrate() {
        self.migrateConfiguration()
        self.migrateAnnouncements()
        self.migrateSocietyLinks()
        self.migrateJournals()
        self.migratePartners()
        self.migrateJournalLinks()
        self.migrateAimScope()
        self.migrateEditors()
        self.migrateIssues()
        self.migrateArticles()
        self.migrateFileSize()
        self.migrateAuthors()
        self.migrateSections()
        self.migrateMedias()
        self.migrateAuthentication()
        self.migrateNotes()
        DatabaseManager.SharedInstance.save()
    }
    
    func responseForQuery(_ query: String) -> [[String: AnyObject]] {
        var container: [[String: AnyObject]] = []
        do {
            let response = try db?.executeQuery(query, values: nil)
            while (response?.next())! {
                var item: [String: AnyObject] = [:]
                let columns = response?.columnNameToIndexMap
                for (value, _) in columns! {
                    if let v = value as? String {
                        item[v] = response?.string(forColumn: v) as AnyObject?
                    }
                }
                container.append(item)
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return container
    }
    
    
    func runQuery(_ query: String) {
        
    }

}

// MARK: - Config -

struct Configtbl {
    static let TableName = "Configtbl"
    
    static let MjBannerPortraitAdIphone = "MjBannerPortraitAdIphone"
    static let MJBannerPortraitAdIpad = "MJBannerPortraitAdIpad"
    static let MjFullPagePortraitAdIphone4 = "MjFullPagePortraitAdIphone4"
    static let MJFullPagePortraitAdIphone5 = "MJFullPagePortraitAdIphone5"
    static let MJFullPagePortraitAdIpad = "MJFullPagePortraitAdIpad"
    static let MJFullPageLandscapeAdIpad = "MJFullPageLandscapeAdIpad"
    static let AppBannerPortraitSplashScreenAdIpad = "AppBannerPortraitSplashScreenAdIpad"
    static let AppBannerPortraitSplashScreenAdIPhone = "AppBannerPortraitSplashScreenAdIPhone"
    static let AdGapInterval = "AdGapInterval"
    static let isSocietyInfoAvailable = "isSocietyInfoAvailable"
    static let AppTitle = "AppTitle"
    static let AppId = "AppId"
    static let App_Short_Code = "App_Short_Code"
    static let Description = "Description"
    static let Facebook_URL = "Facebook_URL"
    static let Last_Modified = "Last_Modified"
    static let Twitter_URL = "Twitter_URL"
    static let Google_Analytics_Code = "Google_Analytics_Code"
    static let Email_Subject = "Email_Subject"
    static let flurryKey = "flurryKey"
    static let update_link = "update_link"
    static let update_title = "update_title"
    static let update_description = "update_description"
    static let update_version = "update_version"
}

extension DBMigration {
    func migrateConfiguration() {
        let query = "SELECT * FROM \(Configtbl.TableName)"
        let response = responseForQuery(query)
        for item in response {
            let dictionary = NSDictionary(dictionary: item)
            let publisher = DatabaseManager.SharedInstance.newAppPublisher()
            
            publisher.adBannerPortraitSplashIPad = dictionary[Configtbl.AppBannerPortraitSplashScreenAdIpad.lowercased()] as? String
            publisher.adBannerPortraitSplashIPhone = dictionary[Configtbl.AppBannerPortraitSplashScreenAdIPhone.lowercased()] as? String
            publisher.adFullPageLandscapeIPad = dictionary[Configtbl.MJFullPageLandscapeAdIpad.lowercased()] as? String
            publisher.adFullPagePortraitIPad = dictionary[Configtbl.MJFullPagePortraitAdIpad.lowercased()] as? String
            publisher.adFullPagePortraitIPhone4 = dictionary[Configtbl.MjFullPagePortraitAdIphone4.lowercased()] as? String
            publisher.adFullPagePortraitIPhone5 = dictionary[Configtbl.MJFullPagePortraitAdIphone5.lowercased()] as? String
            publisher.adBannerPortraitIPad = dictionary[Configtbl.MJBannerPortraitAdIpad.lowercased()] as? String
            publisher.adBannerPortraitIPhone = dictionary[Configtbl.MjBannerPortraitAdIphone.lowercased()] as? String
            if let adInterval = dictionary[Configtbl.AdGapInterval.lowercased()] as? String {
                publisher.adInterval = Int(adInterval) as NSNumber?
            }
            if let isSocietyInfoAvailable = dictionary[Configtbl.isSocietyInfoAvailable.lowercased()] as? String {
                publisher.isSocietyInfoAvailable = Int(isSocietyInfoAvailable) as NSNumber?
            }
            publisher.appTitle = dictionary[Configtbl.AppTitle.lowercased()] as? String
            if let appId = dictionary[Configtbl.AppId.lowercased()] as? String {
                publisher.appId = Int(appId) as NSNumber?
            }
            publisher.appShortCode = dictionary[Configtbl.App_Short_Code.lowercased()] as? String
            publisher.desc = dictionary[Configtbl.Description.lowercased()] as? String
            publisher.societyFacebookURL = dictionary[Configtbl.Facebook_URL.lowercased()] as? String
            if let lastModified = dictionary[Configtbl.Last_Modified.lowercased()] as? String {
                let dateFormatter = DateFormatter(dateFormat: "YYYY-MM-dd HH-mm-ss")
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                publisher.lastModified = dateFormatter.date(from: lastModified)
            }
            publisher.societyTwitterURL = dictionary[Configtbl.Twitter_URL.lowercased()] as? String
            publisher.googleAnalyticsCode = dictionary[Configtbl.Google_Analytics_Code.lowercased()] as? String
            if let emailSubject = dictionary[Configtbl.Email_Subject.lowercased()] as? String {
                log.info(emailSubject)
                assertionFailure()
            }
            publisher.flurryId = dictionary[Configtbl.flurryKey.lowercased()] as? String
            if let updateLink = dictionary[Configtbl.update_link.lowercased()] as? String {
                if updateLink != "" {
                    publisher.updateLinkURL = updateLink
                }
            }
            publisher.updateLinkTitle = dictionary[Configtbl.update_title.lowercased()] as? String
            publisher.updateLinkDescription = dictionary[Configtbl.update_description.lowercased()] as? String
            publisher.updateVersion = dictionary[Configtbl.update_version.lowercased()] as? String
        }
    }
}

// MARK: - Society Links -

struct SocietyLinktbl {
    static let TableName = "SocietyLinktbl"
    
    static let id = "id"
    static let society_link_title = "society_link_title".lowercased()
    static let society_link_url = "society_link_url".lowercased()
}

extension DBMigration {
    func migrateSocietyLinks() {
        let query = "SELECT * FROM \(SocietyLinktbl.TableName)"
        let response = responseForQuery(query)
        for item in response {
            let dictionary:[String: String] = NSDictionary(dictionary: item) as! [String : String]
            let societyLink = DatabaseManager.SharedInstance.newSocietyLink()
            let publisher = DatabaseManager.SharedInstance.getAppPublisher()
            
            societyLink.title = dictionary[SocietyLinktbl.society_link_title]
            societyLink.url = dictionary[SocietyLinktbl.society_link_url]
            
            societyLink.app = publisher
        }
    }
}

// MARK: - Journal -

struct Journaltbl {
    static let TableName = "Journaltbl" // 38
    
    static let OA_Identifier = "OA_Identifier"
    static let OA_Status_Archive = "OA_Status_Archive"
    static let OA_Since_Date = "OA_Since_Date"
    static let OA_Status_Display = "OA_Status_Display"
    static let sequence = "sequence"
    static let BannerPortraitAdIPhone = "BannerPortraitAdIPhone"
    static let BannerPortraitAdIpad = "BannerPortraitAdIpad"
    static let SkyCrapperPortraitAdIpad = "SkyCrapperPortraitAdIpad"
    static let FullPagePortraitAdIphone4 = "FullPagePortraitAdIphone4"
    static let FullPagePortraitAdIphone5 = "FullPagePortraitAdIphone4"
    static let FullPagePortraitAdIpad = "FullPagePortraitAdIpad"
    static let FullPageLandscapeAdIpad = "FullPageLandscapeAdIpad"
    static let abstract_summary = "abstract_summary" //
    static let journal_color_code = "journal_color_code"
    static let isIssueCoverImageAvailable = "isIssueCoverImageAvailable"
    static let IsAIPAvailable = "IsAIPAvailable"
    static let IsEditorsAndBoardAvailable = "IsEditorsAndBoardAvailable"
    static let coverImagePath = "coverImagePath"
    static let baseContentURL = "baseContentURL"
    static let JSocietytype = "JSocietytype"
    static let JShortCode = "JShortCode"
    static let AIPTitle = "AIPTitle"
    static let AIPBadgeNumber = "AIPBadgeNumber"
    static let AIPDescription = "AIPDescription"
    static let JPurSubsID = "JPurSubsID"
    static let JId = "JId"
    static let JName = "JName"
    static let JDescription = "JDescription"
    static let JImage_Url = "JImage_Url"
    static let JInfo = "JInfo"
    static let JLasModified = "JLastModified"
    static let JTwitterConsumerKey = "JTwitterConsumerKey"
    static let JTwitterSecretKey = "JTwitterSecretKey"
    static let JFacebookUrl = "JFacebookUrl"
    static let JTwitterUrl = "JTwitterUrl"
    static let JFacebookId = "JFacebookId"
    static let JEmailSubject = "JEmailSubject"
    static let JAccessType = "JAcessType"
    static let JAppId = "JAppId"
    static let JSubscriptionID = "JSubscriptionID"
    static let JSubscriptionPrice = "JSubscriptionPrice"
    static let JISSN = "JISSN"
    static let JType = "JType"
    static let JFreeSubscriptionID = "JFreeSubscriptionID"
    static let IsAimAndScopeAvailable = "IsAimAndScopeAvailable"
}

extension DBMigration {
    func migrateJournals() { // 44
        let query = "SELECT * FROM \(Journaltbl.TableName)"
        let response = responseForQuery(query)
        for item in response {
            let dictionary = NSDictionary(dictionary: item)
            let journal = DatabaseManager.SharedInstance.newJournal()
            journal.setupForMigratioin()
            
            journal.abstractSummary = dictionary[Journaltbl.abstract_summary.lowercased()] as? String
            if let isAipAvailable = dictionary[Journaltbl.IsAIPAvailable.lowercased()] as? String {
                if let bool = Bool(isAipAvailable) {
                    //journal.isAipAvailable = bool
                }
            }
            journal.aipDescription = dictionary[Journaltbl.AIPDescription.lowercased()] as? String
            journal.aipTitle = dictionary[Journaltbl.AIPTitle.lowercased()] as? String
            
            if let accessType = dictionary[Journaltbl.JAccessType.lowercased()] as? String {
                journal.accessType = accessType
            }
            
            journal.adBannerPortraitIPad = dictionary[Journaltbl.BannerPortraitAdIpad.lowercased()] as? String
            journal.adBannerPortraitIPhone = dictionary[Journaltbl.BannerPortraitAdIPhone.lowercased()] as? String
            journal.adFullPageLandscapeIPad = dictionary[Journaltbl.FullPageLandscapeAdIpad.lowercased()] as? String
            journal.adFullPagePortraitIPad = dictionary[Journaltbl.FullPagePortraitAdIpad.lowercased()] as? String
            journal.adFullPagePortraitIPhone4 = dictionary[Journaltbl.FullPagePortraitAdIphone4.lowercased()] as? String
            journal.adFullPagePortraitIPhone5 = dictionary[Journaltbl.FullPagePortraitAdIphone5.lowercased()] as? String
            
            if let adSkyscrapperPortraitIPad = dictionary[Journaltbl.SkyCrapperPortraitAdIpad.lowercased()] as? String {
                journal.adSkyscraperPortraitIPad = adSkyscrapperPortraitIPad
            }
            
            //journal.baseContentURL = dictionary[Journaltbl.baseContentURL.lowercased()] as? String
            journal.baseContentURL45 = dictionary[Journaltbl.baseContentURL.lowercased()] as? String
            //journal.coverImagePath = dictionary[Journaltbl.coverImagePath.lowercased()] as? String
            //journal.facebookId = dictionary[Journaltbl.JFacebookId.lowercased()] as? String
            
            /*if let isAimAndScopeAvailable = dictionary[Journaltbl.IsAimAndScopeAvailable.lowercased()] as? String {
                journal.isAimScopeAvailable = Int(isAimAndScopeAvailable))
            }
            
            journal.isCoverPageAvailable = (dictionary[Journaltbl.isIssueCoverImageAvailable.lowercased()] as? String)?.int() as NSNumber?
            journal.isEditorialAvailable = (dictionary[Journaltbl.IsEditorsAndBoardAvailable.lowercased()]as? String)?.int() as NSNumber?*/
            journal.issn = dictionary[Journaltbl.JISSN.lowercased()] as? String
            
            journal.journalDescription = dictionary[Journaltbl.JDescription.lowercased()]as? String
            
            if let journalFacebookURL = dictionary[Journaltbl.JFacebookUrl.lowercased()] as? String {
                journal.journalFacebookURL = journalFacebookURL
            }
            
            journal.journalId = (dictionary[Journaltbl.JId.lowercased()] as? String)?.int() as NSNumber!
            journal.journalShortCode = dictionary[Journaltbl.JShortCode.lowercased()]as? String
            journal.journalTitle = dictionary[Journaltbl.JName.lowercased()] as? String
            journal.journalTitleIPhone = dictionary[Journaltbl.JName.lowercased()] as? String
            journal.journalTwitterURL = dictionary[Journaltbl.JTwitterUrl.lowercased()] as? String
            journal.journalType = dictionary[Journaltbl.JType.lowercased()] as? String
            if let lastModified = dictionary[Journaltbl.JLasModified.lowercased()] as? String {
                let dateFormatter = DateFormatter(dateFormat: "YYYY-MM-dd HH:mm:ss")
                journal.lastModified = dateFormatter.date(from: lastModified)
            }
            journal.subscriptionId = dictionary[Journaltbl.JSubscriptionID.lowercased()] as? String
            journal.societyLoginType = dictionary[Journaltbl.JSocietytype.lowercased()] as? String
            journal.subscriptionPrice = dictionary[Journaltbl.JSubscriptionPrice.lowercased()] as? String
            journal.sequence = (dictionary[Journaltbl.sequence.lowercased()] as? String)?.int() as NSNumber?
            journal.colorCode = dictionary[Journaltbl.journal_color_code.lowercased()] as? String
            journal.openAccess.oaIdentifier = (dictionary[Journaltbl.OA_Identifier.lowercased()] as? String)?.int() as NSNumber!
            if let oaSinceDate = dictionary[Journaltbl.OA_Since_Date.lowercased()] as? String {
                let dateFormatter = DateFormatter(dateFormat: "YYYY-MM-dd HH:mm:ss")
                journal.openAccess.oaSinceDate = dateFormatter.date(from: oaSinceDate)
            }
            journal.openAccess.oaStatusArchive = dictionary[Journaltbl.OA_Status_Archive.lowercased()] as? String
            journal.openAccess.oaStatusDisplay = dictionary[Journaltbl.OA_Status_Display.lowercased()] as? String
            
            journal.publisher = DatabaseManager.SharedInstance.getAppPublisher()
            FileSystemManager.sharedInstance.setupJournal(journal)
        }
    }
}

// MARK: - Journal Link -

struct JournalLinkTable {
    static let TableName = "JournalLinkTable"
    
    static let journal_id = "journal_id"
    static let Journal_Title = "Journal_Title"
    static let Journal_URL = "Journal_URL"
}

extension DBMigration {
    func migrateJournalLinks() {
        let query = "SELECT * FROM \(JournalLinkTable.TableName)"
        let response = responseForQuery(query)
        for item in response {
            let dictionary:[String: String] = NSDictionary(dictionary: item) as! [String : String]
            let journalLink = DatabaseManager.SharedInstance.newJournalLink()
            if let journalId = dictionary[JournalLinkTable.journal_id] {
                if let journal = DatabaseManager.SharedInstance.getJournal(journalId: Int(journalId)!) {
                    
                    journalLink.journal = journal
                    
                    journalLink.journalTitle = dictionary[JournalLinkTable.Journal_Title.lowercased()]
                    journalLink.journalURL = dictionary[JournalLinkTable.Journal_URL.lowercased()]
                }
            }
        }
    }
}

// MARK: - Editors -

struct Editors {
    static let TableName = "Editors"
    
    static let journal_id = "journal_id"
    static let htmltxt = "htmltxt"
}

extension DBMigration {
    func migrateEditors() {
        func migrateIssues() {
            let query = "SELECT * FROM \(Editors.TableName)"
            let response = responseForQuery(query)
            for item in response {
                let dictionary:[String: String] = NSDictionary(dictionary: item) as! [String : String]
                let editor = DatabaseManager.SharedInstance.newEditor()
                if let journalId = dictionary[Editors.journal_id] {
                    if let journal = DatabaseManager.SharedInstance.getJournal(journalId: Int(journalId)!) {
                        editor.htmlText = dictionary[Editors.htmltxt]
                        editor.journal = journal
                    }
                }
            }
        }
    }
}

// MARK: - Aim Scope -

struct Aim_Scope_tbl {
    static let TableName = "Aim_Scope_tbl"
    
    static let journal_id = "journal_id".lowercased()
    static let home_txt = "home_txt".lowercased()
    static let html_txt = "html_txt".lowercased()
}

extension DBMigration {
    func migrateAimScope() {
        func migrateIssues() {
            let query = "SELECT * FROM \(Aim_Scope_tbl.TableName)"
            let response = responseForQuery(query)
            for item in response {
                let dictionary:[String: String] = NSDictionary(dictionary: item) as! [String : String]
                let aimAndScope = DatabaseManager.SharedInstance.newAimAndScope()
                if let journalId =  dictionary[Aim_Scope_tbl.journal_id] {
                    let journal = DatabaseManager.SharedInstance.getJournal(journalId: Int(journalId)!)
                    
                    aimAndScope.htmlTxt = dictionary[Aim_Scope_tbl.html_txt]
                    aimAndScope.homeTxt = dictionary[Aim_Scope_tbl.home_txt]
                    aimAndScope.journal = journal
                }
            }
        }
    }
}

// MARK: - Issue -

struct IssueTbl {
    static let TableName = "IssueTbl"
    
    
    static let OA_Status_Display = "OA_Status_Display"
    static let OA_Since_Date = "OA_Since_Date"
    static let OA_Display_Sponsor_Name = "OA_Display_Sponsor_Name"
    static let OA_Identifier = "OA_Identifier"
    static let release_date_abbr_display = "release_date_abbr_display"
    static let sequence = "sequence"
    static let issue_label_display = "issue_label_display"
    static let release_date_display = "release_date_display"
    static let Editors = "Editors"
    static let ID = "ID"
    static let IssueNo = "IssueNo"
    static let IssueName = "IssueName"
    static let VolNo = "VolNo"
    static let Date = "Date"
    static let PageRange = "PageRange"
    static let issue_title = "issue_title"
    static let special_editors = "special_editors"
    static let CoverImage = "CoverImage"
    static let isAllArticledDownloaded = "isAllArticledDownloaded"
    static let isArticleMetaDataDownloaded = "isArticleMetaDataDownloaded"
    static let ProductID = "ProductID"
    static let ProductPrice = "ProductPrice"
    static let TotalArticles = "TotalArticles"
    static let isIssuePurchased = "isIssuePurchased"
    static let version = "version"
    static let journal_id = "journal_id"
    static let IssuePII = "IssuePII"
    static let issue_type_display = "issue_type_display"
}

extension DBMigration {
    func migrateIssues() {
        let query = "SELECT * FROM \(IssueTbl.TableName)"
        let response = responseForQuery(query)
        for item in response {
            let dictionary:[String: String] = NSDictionary(dictionary: item) as! [String : String]
            let issue = Issue.new(context: DatabaseManager.SharedInstance.moc!)
            issue.setupForMigration()
            
            if let allArticlesDownloaded = dictionary[IssueTbl.isAllArticledDownloaded.lowercased()] {
                issue.allArticlesDownloaded = Int(allArticlesDownloaded) as NSNumber?
            }
            
            if let coverImage = dictionary[IssueTbl.CoverImage.lowercased()] {
                issue.coverImage = coverImage
                issue.coverImageDownloadStatus = .notDownloaded
            } else {
                issue.coverImageDownloadStatus = .notAvailable
            }
            
            if let date = dictionary[IssueTbl.Date.lowercased()] {
                let dateFormatter = DateFormatter(dateFormat: "YYYY-MM-dd")
                issue.dateOfRelease = dateFormatter.date(from: date)
            }
            issue.editors = dictionary[IssueTbl.Editors.lowercased()]
            issue.issueId = dictionary[IssueTbl.ID.lowercased()]?.int() as NSNumber! // IssueID??? IssueNo?
            issue.issueLabelDisplay = dictionary[IssueTbl.issue_label_display]
            issue.issueName = dictionary[IssueTbl.IssueName.lowercased()]
            
            if let issueNumber = dictionary[IssueTbl.IssueNo.lowercased()] {
                issue.issueNumber = issueNumber
            }
            
            if let purchased = dictionary[IssueTbl.isIssuePurchased.lowercased()] {
                issue.purchased = Int(purchased) as NSNumber!
            }
            
            issue.issuePii = dictionary[IssueTbl.IssuePII.lowercased()]
            issue.issueTitle = dictionary[IssueTbl.issue_title.lowercased()]
            
            if let issueTypeDisplay = dictionary[IssueTbl.issue_type_display.lowercased()] {
                issue.issueTypeDisplay = issueTypeDisplay
            }
            
            /*if let date = metadata["last_modified"] as? String {
                let dateFormatter = NSDateFormatter(dateFormat: "YYYY-MM-dd HH:mm:ss")
                issue.lastModified = dateFormatter.dateFromString(date)
            }*/
            
            issue.pageRange = dictionary[IssueTbl.PageRange.lowercased()]
            issue.productId = dictionary[IssueTbl.ProductID.lowercased()]
            issue.price = dictionary[IssueTbl.ProductPrice.lowercased()]
            issue.releaseDateAbbrDisplay = dictionary[IssueTbl.release_date_abbr_display.lowercased()]
            
            if let releaseDateDisplay = dictionary[IssueTbl.release_date_display.lowercased()] {
                issue.releaseDateDisplay = releaseDateDisplay
            }
            
            issue.sequence = dictionary[IssueTbl.sequence.lowercased()]
            issue.specialEditors = dictionary[IssueTbl.special_editors.lowercased()]
            //issue.specialIssue = (metadata["special_Issue"] as? String)?.int()
            //issue.video = dictionary[IssueTbl.CoverImage]?.int()
            issue.volume = dictionary[IssueTbl.VolNo.lowercased()]
            issue.openAccess.oaIdentifier = dictionary[IssueTbl.OA_Identifier.lowercased()]?.int() as NSNumber!
            if let oaSinceDate = dictionary[IssueTbl.OA_Since_Date.lowercased()] {
                let dateFormatter = DateFormatter(dateFormat: "YYYY-MM-dd HH:mm:ss")
                issue.openAccess.oaSinceDate = dateFormatter.date(from: oaSinceDate)
            }
            //issue.oaStatusArchive = metadata["OA_Status_Archive"] as? String
            issue.openAccess.oaStatusDisplay = dictionary[IssueTbl.OA_Status_Display.lowercased()]
            
            let journalId = dictionary[IssueTbl.journal_id.lowercased()]!
            let journal = DatabaseManager.SharedInstance.getJournal(journalId: Int(journalId)!)
            issue.journal = journal
        }
    }
}

// MARK: - Article -

struct Articletbl {
    static let TableName = "Articletbl"
    
    static let Abstract = "Abstract"
    
    static let IsOA_Info_Updated = "IsOA_Info_Updated"
    static let OA_Identifier = "OA_Identifier"
    static let OA_Info_Html = "OA_Info_Html"
    static let OA_Display_Sponsor_Name = "OA_Display_Sponsor_Name"
    static let OA_Status_Display = "OA_Status_Display"
    static let section_color = "section_color"
    static let abstract_html_text = "abstract_html_text"
    static let fulltext_html_text = "fulltext_html_text"
    static let copyrightInformation = "copyrightInformation"
    static let isAbstractPresent = "isAbstractPresent"
    static let isArticleDownloaded = "isArticleDownloaded"
    static let citationText = "citationText"
    static let hasSupplements = "hasSupplements"
    static let hasVideos = "hasVideos"
    static let hasFigures = "hasFigures"
    static let hasAudios = "hasAudios"
    static let hasDocuments = "hasDocuments"
    static let DOI = "DOI"
    static let ID = "ID"
    static let IssueID = "IssueID"
    static let Title = "Title"
    static let Author = "Author"
    static let HTML = "HTML"
    static let PDF = "PDF"

    static let Keywords = "Keywords"
    static let DateOfRel = "DateOfRel"
    static let AType = "Type"
    static let ArticleInPress = "ArticleInPress"
    static let isBookmarked = "isBookmarked"
    static let PageRange = "PageRange"
    static let ArticleDownloaded = "ArticleDownloaded"
    static let article_info_id = "article_info_id"
    static let DOI_Link = "DOI_Link"
    static let SequenceNo = "SequenceNo"
    static let isArticleAbstractDownloaded = "isArticleAbstractDownloaded"
    static let article_sub_type = "article_sub_type"
    static let isSupplementDownloaded = "isSupplementDownloaded"
    static let version = "version"
    static let journal_id = "journal_id"
    static let bookmarkCreatedDate = "bookmarkCreatedDate"
    static let isCmeArticle = "isCmeArticle"
    static let articleRole = "articleRole"
    static let IssuePII = "IssuePII"
    static let sectionSequenceNo = "sectionSequenceNo"
    static let article_sub_type2 = "article_sub_type2"
    static let article_sub_type3 = "article_sub_type3"
    static let article_sub_type4 = "article_sub_type4"
    static let hasAbstractSupplement = "hasAbstractSupplement"
    static let isAbstractSupplementDownloaded = "isAbstractSupplementDownloaded"
    static let articleColorName = "articleColorName"
}

extension DBMigration {
    func migrateArticles() {
        let query = "SELECT * FROM \(Articletbl.TableName)"
        let response = responseForQuery(query)
        for item in response {
            let dictionary:[String: String] = NSDictionary(dictionary: item) as! [String : String]
            
            let article = DatabaseManager.SharedInstance.newArticle()
            article.setupForMigration()
            
            if let abstract = dictionary[Articletbl.abstract_html_text.lowercased()] {
                article.abstract = abstract
            }
            
            article.hasAbstractImages = true
            
            //article.aipIdentifier = metadata["AIP_Identifier"] as? String
            article.articleId = dictionary[Articletbl.ID.lowercased()]?.int() as NSNumber?
            article.articleInfoId = dictionary[Articletbl.article_info_id.lowercased()]
            article.articleSubType = dictionary[Articletbl.article_sub_type.lowercased()]
            article.articleSubType2 = dictionary[Articletbl.article_sub_type2.lowercased()]
            article.articleSubType3 = dictionary[Articletbl.article_sub_type3.lowercased()]
            article.articleSubType4 = dictionary[Articletbl.article_sub_type4.lowercased()]
            article.articleTitle = dictionary[Articletbl.Title.lowercased()]
            article.articleType = dictionary[Articletbl.AType.lowercased()]
            article.author = dictionary[Articletbl.Author.lowercased()]
            article.citationText = dictionary[Articletbl.citationText.lowercased()]
            article.copyright = dictionary[Articletbl.copyrightInformation.lowercased()]
            article.dateOfRelease = Date.JBSMShortDateFromString(dictionary[Articletbl.DateOfRel.lowercased()])
            article.doi = dictionary[Articletbl.DOI.lowercased()]
            article.doiLink = dictionary[Articletbl.DOI_Link.lowercased()]
            article.issueId = dictionary[Articletbl.IssueID.lowercased()]?.int() as NSNumber?
            article.issuePII = dictionary[Articletbl.IssuePII.lowercased()]
            article.keywords = dictionary[Articletbl.Keywords.lowercased()]
            if let color = dictionary[Articletbl.section_color.lowercased()] {
                article.lancetArticleColor = color
            }
            article.lancetGroupSequence = dictionary[Articletbl.sectionSequenceNo.lowercased()]
            article.pageRange = dictionary[Articletbl.PageRange.lowercased()]
            article.sequence = dictionary[Articletbl.Keywords.lowercased()]?.int() as NSNumber?
            article.version = dictionary[Articletbl.version.lowercased()]?.int() as NSNumber?
            if let isAbstractPresent = dictionary[Articletbl.isAbstractPresent.lowercased()] {
                if Int(isAbstractPresent) == 1 {
                    article.downloadInfo.abstractDownloadStatus = DownloadStatus.notDownloaded
                }
            }
            article.abstract = dictionary[Articletbl.Abstract.lowercased()]
            article.downloadInfo.fullTextFileName = dictionary[Articletbl.HTML.lowercased()]
            if let fullTextSupplExists = dictionary[Articletbl.hasSupplements.lowercased()] {
                if Int(fullTextSupplExists) == 1 {
                    article.downloadInfo.fullTextSupplDownloadStatus = DownloadStatus.notDownloaded
                }
            }
            if let isSupplementDownloaded = dictionary[Articletbl.isSupplementDownloaded.lowercased()] {
                if Int(isSupplementDownloaded) == 1 || Int(isSupplementDownloaded) == 2 {
                    article.downloadInfo.fullTextSupplDownloadStatus = DownloadStatus.downloaded
                }
            }
            article.hasVideo = dictionary[Articletbl.hasVideos.lowercased()]?.int() as NSNumber!
            article.hasAudio = dictionary[Articletbl.hasAudios.lowercased()]?.int() as NSNumber!
            article.hasImage = dictionary[Articletbl.hasFigures.lowercased()]?.int() as NSNumber!
            article.hasOthers = dictionary[Articletbl.hasDocuments.lowercased()]?.int() as NSNumber!
            article.downloadInfo.abstractFileName = dictionary[Articletbl.Abstract.lowercased()]
            article.isArticleInPress = dictionary[Articletbl.ArticleInPress.lowercased()]?.int() as NSNumber!
            article.downloadInfo.pdfFileName = dictionary[Articletbl.PDF.lowercased()]
            article.openAccess.oaStatusDisplay = dictionary[Articletbl.OA_Status_Display.lowercased()]
            article.openAccess.oaDisplaySponsorName = dictionary[Articletbl.OA_Display_Sponsor_Name.lowercased()]
            article.openAccess.oaIdentifier = dictionary[Articletbl.OA_Identifier.lowercased()]?.int() as NSNumber!
            
            // Abstract
            
            article.downloadInfo.abstractDownloadStatus = .notAvailable
            article.downloadInfo.abstractSupplDownloadStatus = .notAvailable
            
            if let isAbstractPresent = dictionary[Articletbl.isAbstractPresent.lowercased()] {
                if Int(isAbstractPresent) == 1 {
                    article.downloadInfo.abstractDownloadStatus = .notDownloaded
                }
            }
            
            // Abstract Available
            if let isArticleAbstractDownloaded = dictionary[Articletbl.isArticleAbstractDownloaded.lowercased()] {
                if Int(isArticleAbstractDownloaded) == 1 {
                    article.downloadInfo.abstractDownloadStatus = .downloaded
                }
            }
            
            // Abstract Suppl Available
            if let isAbstractSupplementDownloaded = dictionary[Articletbl.isAbstractSupplementDownloaded.lowercased()] {
                if Int(isAbstractSupplementDownloaded) == 1 || Int(isAbstractSupplementDownloaded) == 2 {
                    article.downloadInfo.abstractSupplDownloadStatus = .downloaded
                }
                
            }
            
            if let isArticleDownloaded = dictionary[Articletbl.isArticleDownloaded.lowercased()] {
                if Int(isArticleDownloaded) == 2 {
                    article.downloadInfo.fullTextDownloadStatus = .downloaded
                } else {
                    article.downloadInfo.fullTextDownloadStatus = .notDownloaded
                }
            }
            
            if let starred = dictionary[Articletbl.isBookmarked.lowercased()] {
                article.starred = Int(starred) as NSNumber!
            }
            
            let issue = DatabaseManager.SharedInstance.getIssue(dictionary[Articletbl.IssuePII.lowercased()])
            article.issue = issue
            
            if let journalId = dictionary[Articletbl.journal_id.lowercased()] {
                if let journalIdInt = Int(journalId) {
                    article.journal = DatabaseManager.SharedInstance.getJournal(journalId: journalIdInt)
                }
            }
            
            if let sequenceNo = dictionary[Articletbl.SequenceNo.lowercased()] {
                article.sequence = Int(sequenceNo) as NSNumber?
            }
            
            if let bookmarkCreatedDate = dictionary[Articletbl.bookmarkCreatedDate.lowercased()] {
                let dateFormatter = DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss")
                article.starredDate = dateFormatter.date(from: bookmarkCreatedDate)
            }
        }
    }
}

// MARK: - File Size -

struct FilesizeTbl {
    static let TableName = "FilesizeTbl"
    
    static let article_info_id = "article_info_id"
    static let fulltext_article_size = "fulltext_article_size"
    static let supplement_size = "supplement_size"
    static let pdf_filesize = "pdf_filesize"
    static let unzipped_fulltext_article_size = "unzipped_fulltext_article_size"
    static let unzipped_supplement_size = "unzipped_supplement_size"
    static let unzipped_pdf_filesize = "unzipped_pdf_filesize"
    static let abstract_supplement_size = "abstract_supplement_size"
}

extension DBMigration {
    func migrateFileSize() {
        let query = "SELECT * FROM \(FilesizeTbl.TableName)"
        let response = responseForQuery(query)
        for item in response {
            let dictionary:[String: String] = NSDictionary(dictionary: item) as! [String : String]
            guard let article = DatabaseManager.SharedInstance.getArticle(articleInfoId: dictionary[FilesizeTbl.article_info_id]!) else {
                return
            }

            /*if let fulltext_article_size = dictionary[FilesizeTbl.fulltext_article_size.lowercased()] {
                article.downloadInfo.fullTextFileSize = Float(fulltext_article_size) 
            }
            if let supplement_size = dictionary[FilesizeTbl.supplement_size.lowercased()] {
                article.downloadInfo.fullTextSupplFileSize = Float(supplement_size) 
            }
            if let pdfFileSize = dictionary[FilesizeTbl.pdf_filesize.lowercased()] {
                article.downloadInfo.pdfFileSize = Float(pdfFileSize) 
                if Float(pdfFileSize) > 0 {
                    article.downloadInfo.pdfDownloadStatus = .notDownloaded
                }
            }
            if let fullTextFileSizeUnzipped = dictionary[FilesizeTbl.unzipped_fulltext_article_size.lowercased()] {
                article.downloadInfo.fullTextFileSizeUnzipped = Float(fullTextFileSizeUnzipped) 
            }
            if let fullTextSupplementSizeUnzipped = dictionary[FilesizeTbl.unzipped_supplement_size.lowercased()] {
                article.downloadInfo.fullTextSupplFileSizeUnzipped = Float(fullTextSupplementSizeUnzipped) 
            }
            if let pdfUnzippedFileSize = dictionary[FilesizeTbl.unzipped_pdf_filesize.lowercased()] {
                article.downloadInfo.pdfFileSizeUnzipped = Float(pdfUnzippedFileSize) 
            }
            if let abstractSupplementSize = dictionary[FilesizeTbl.abstract_supplement_size] {
                article.downloadInfo.abstractSupplFileSize = Float(abstractSupplementSize) 
            }*/
        }
    }
}

// MARK: - Author -

struct Authortbl {
    static let TableName = "Authortbl"
    
    static let AuthorID = "AuthorID"
    static let AuthorName = "AuthorName"
    static let AuthorDescription = "AuthorDescription"
    static let article_info_id = "article_info_id"
}

extension DBMigration {
    func migrateAuthors() {
        let query = "SELECT * FROM \(Authortbl.TableName)"
        let response = responseForQuery(query)
        for item in response {
            let dictionary:[String: String] = NSDictionary(dictionary: item) as! [String : String]
            let author = DatabaseManager.SharedInstance.newAuthor()
            let article = DatabaseManager.SharedInstance.getArticle(articleInfoId: dictionary[Authortbl.article_info_id]!)
            
            author.desc = dictionary[Authortbl.AuthorDescription.lowercased()]
            author.name = dictionary[Authortbl.AuthorName.lowercased()]
            author.identifier = dictionary[Authortbl.AuthorID.lowercased()]?.int() as NSNumber?
            author.article = article
        }
    }
}

// MARK: - Section -

struct SectionTbl {
    static let TableName = "SectionTbl"
    
    static let last_modified = "last_modified".lowercased()
    static let ReferenceID = "RererenceID".lowercased()
    static let section_id = "section_id".lowercased()
    static let section_title = "section_title".lowercased()
    static let is_this_sub_section = "is_this_sub_section".lowercased()
    static let article_info_id = "article_info_id".lowercased()
}

extension DBMigration {
    func migrateSections() {
        let query = "SELECT * FROM \(SectionTbl.TableName)"
        let response = responseForQuery(query)
        for item in response {
            let dictionary:[String: String] = NSDictionary(dictionary: item) as! [String : String]
            let section = DatabaseManager.SharedInstance.newSection()
            let article = DatabaseManager.SharedInstance.getArticle(articleInfoId: dictionary[Authortbl.article_info_id]!)
            
            if let referenceId = dictionary[SectionTbl.ReferenceID] {
                section.referenceId = Int(referenceId) as NSNumber?
            }
            section.sectionId = dictionary[SectionTbl.section_id]
            section.sectionTitle = dictionary[SectionTbl.section_title]
            if let isThisSubSection = dictionary[SectionTbl.is_this_sub_section] {
                section.isThisSubSection = Int(isThisSubSection) as NSNumber?
            }
            if let lastModified = dictionary[SectionTbl.last_modified] {
                section.lastModified = Date.JBSMLongDateFromString(lastModified)
            }
            
            section.article = article
        }
    }
}

// MARK: - Media -

struct announcementTbl {
    static let TableName = "announcementTbl"
    
    static let announcement_Date = "announcement_Date".lowercased()
    static let isReaded = "isReaded".lowercased()
    static let announcement_id = "announcement_id".lowercased()
    static let Announcement_Text = "Announcement_Text".lowercased()
    static let Announcement_Title = "Announcement_Title".lowercased()
}

extension DBMigration {
    func migrateAnnouncements() {
        let query = "SELECT * FROM \(announcementTbl.TableName)"
        let response = responseForQuery(query)
        for item in response {
            let dictionary:[String: String] = NSDictionary(dictionary: item) as! [String : String]
            let announcement = DatabaseManager.SharedInstance.newAnnouncement()
            let publisher = DatabaseManager.SharedInstance.getAppPublisher()
            
            if let announcementDate = dictionary[announcementTbl.announcement_Date] {
                announcement.announcementDate = Date.JBSMLongDateFromString(announcementDate)
            }
            if let announcementId = dictionary[announcementTbl.announcement_id] {
                announcement.announcementId = Int(announcementId) as NSNumber?
            }
            announcement.announcementText = dictionary[announcementTbl.Announcement_Text]
            announcement.announcementTitle = dictionary[announcementTbl.Announcement_Title]
            
            announcement.app = publisher
        }
    }
}

// MARK: - Media -

struct Article_media_type_tbl {
    static let TableName = "Article_media_type_tbl"
    
    static let media_text = "media_text".lowercased()
    static let article_media_type_id = "article_media_type_id".lowercased()
    static let article_info_id = "article_info_id".lowercased()
    static let media_type_id = "media_type_id".lowercased()
    static let media_url = "media_url".lowercased()
    static let media_caption = "media_caption".lowercased()
    static let media_thumb_image_name = "media_thumb_image_name".lowercased()
    static let media_title = "media_title".lowercased()
    static let media_duration = "media_duration".lowercased()
    static let issharableItem = "issharableItem".lowercased()
    static let article_media_sequence = "article_media_sequence".lowercased()
}

extension DBMigration {
    func migrateMedias() {
        let query = "SELECT * FROM \(Article_media_type_tbl.TableName)"
        let response = responseForQuery(query)
        for item in response {
            let dictionary:[String: String] = NSDictionary(dictionary: item) as! [String : String]
            let media = DatabaseManager.SharedInstance.getNewMedia()
            let article = DatabaseManager.SharedInstance.getArticle(articleInfoId: dictionary[Article_media_type_tbl.article_info_id]!)
            
            media.type = dictionary[Article_media_type_tbl.media_type_id]
            media.thumbImageName = dictionary[Article_media_type_tbl.media_thumb_image_name]
            if let shareable = dictionary[Article_media_type_tbl.issharableItem] {
                media.shareable = Int(shareable) as NSNumber! 
            }
            media.fileName = dictionary[Article_media_type_tbl.media_url]
            media.text = dictionary[Article_media_type_tbl.media_text]
            media.caption = dictionary[Article_media_type_tbl.media_caption]
            if let sequence = dictionary[Article_media_type_tbl.article_media_sequence] {
                media.sequence = Int(sequence) as NSNumber! 
            }
            
            media.article = article
        }
    }
}

// MARK: - Authentication -

struct AuthenticationTbl {
    static let TableName = "AuthenticationTbl"
    
    static let article_info_id = "article_info_id".lowercased()
    static let session = "session".lowercased()
    static let primary_usage_info = "primary_usage_info".lowercased()
    static let title_id = "title_id".lowercased()
    static let auth_token = "auth_token".lowercased()
    static let ip_address = "ip_address".lowercased()
    static let organization_name = "organization_name".lowercased()
    static let banner_text = "banner_text".lowercased()
}



// MARK: - Login -

struct LoginUsertbl {
    static let TableName = "LoginUsertbl"
    
    static let lastname = "lastname".lowercased()
    static let sessionid = "sessionid".lowercased()
    static let loginid = "loginid".lowercased()
    static let password = "password".lowercased()
    static let partnerid = "partnerid".lowercased() //
    static let partnername = "partnername".lowercased()
    static let userid = "userid".lowercased()
    static let emailid = "emailid".lowercased()
    static let rememberme = "rememberme".lowercased()
    static let journalid = "journalid".lowercased()
    static let societytype = "societytype".lowercased()
    static let issn = "issn".lowercased()
}

extension DBMigration {
    func migrateAuthentication() {
        let query = "SELECT * FROM \(LoginUsertbl.TableName)"
        let response = responseForQuery(query)
        for item in response {
            let dictionary:[String: String] = NSDictionary(dictionary: item) as! [String : String]
            let authentication = DatabaseManager.SharedInstance.newAuthentication()
            
            authentication.lastName = dictionary[LoginUsertbl.lastname]
            authentication.sessionId = dictionary[LoginUsertbl.sessionid]
            authentication.loginId = dictionary[LoginUsertbl.loginid]
            authentication.password = dictionary[LoginUsertbl.password]
            if let partnerId = dictionary[LoginUsertbl.partnerid], let partnerName = dictionary[LoginUsertbl.partnername] {
                authentication.partner = DatabaseManager.SharedInstance.getPartner(partnerId: Int(partnerId)!, partnerName: partnerName)
            }
            authentication.userId = dictionary[LoginUsertbl.userid]
            authentication.emailId = dictionary[LoginUsertbl.emailid]
            if let rememberMe = dictionary[LoginUsertbl.rememberme] {
                authentication.rememberMe = Int(rememberMe) as NSNumber?
            }
            if let journalIdString = dictionary[LoginUsertbl.journalid] {
                if let journalId = Int(journalIdString) {
                    if let journal = DatabaseManager.SharedInstance.getJournal(journalId: journalId) {
                        journal.authentication = authentication
                        if let partnerIdString = dictionary[LoginUsertbl.partnerid] {
                            if let partnerId = Int(partnerIdString) {
                                for partner in journal.allPartners {
                                    if partner.partnerId?.intValue == partnerId {
                                        authentication.partner = partner
                                    }
                                }
                            }
                        }
                    }
                }
            }
            authentication.societyType = dictionary[LoginUsertbl.societytype]
        }
    }
}

// MARK: - Partners -

struct partnerTable {
    static let TableName = "partnerTable"
    
    static let forgotPasswordUrl = "forgotPasswordUrl".lowercased()
    static let forgotPasswordService = "forgotPasswordService".lowercased()
    static let helptext = "helptext".lowercased()
    static let ISSN = "ISSN".lowercased()
    static let partnerId = "partnerId".lowercased()
    static let partnerName = "partnerName".lowercased()
}

extension DBMigration {
    func migratePartners() {
        let query = "SELECT * FROM \(partnerTable.TableName)"
        let response = responseForQuery(query)
        for item in response {
            let dictionary:[String: String] = NSDictionary(dictionary: item) as! [String : String]
            let partner = DatabaseManager.SharedInstance.newPartner()
            
            partner.forgotPasswordURL = dictionary[partnerTable.forgotPasswordUrl]
            partner.forgotPasswordService = dictionary[partnerTable.forgotPasswordService]
            partner.helpText = dictionary[partnerTable.helptext]
            partner.journal = DatabaseManager.SharedInstance.getJournal(issn: dictionary[partnerTable.ISSN]!)
            if let partnerId = dictionary[partnerTable.partnerId] {
                partner.partnerId = Int(partnerId) as NSNumber?
            }
            partner.partnerName = dictionary[partnerTable.partnerName]
            if let journal = DatabaseManager.SharedInstance.getJournal(issn: dictionary[partnerTable.ISSN]!) {
                partner.journal = journal
            }
        }
    }
}

// MARK: - Notes

struct HIGHLIGHTOBJECT {
    static let TableName = "HIGHLIGHTOBJECT"
    
    static let HIGHLIGHT_ID = "HIGHLIGHT_ID"
    static let NOTE = "NOTE"
    static let SELECT_TEXT = "SELECT_TEXT"
    static let SAVED_ON_DATE = "SAVED_ON_DATE"
    static let SELECTED_ARTICLE_INFO_ID = "SELECTED_ARTICLE_INFO_ID"
    static let NOTE_POSITION = "NOTE_POSITION"
    static let JOURNAL_ID = "JOURNAL_ID"
}

extension DBMigration {
    func migrateNotes() {
        let query = "SELECT * FROM \(HIGHLIGHTOBJECT.TableName)"
        let response = responseForQuery(query)
        
        for item in response {
            let dictionary: [String: String] = NSDictionary(dictionary: item) as! [String: String]
            let note = Note.new(context: DatabaseManager.SharedInstance.moc!)
            
            note.highlightId = dictionary[HIGHLIGHTOBJECT.HIGHLIGHT_ID.lowercased()]
            note .noteText = dictionary[HIGHLIGHTOBJECT.NOTE.lowercased()]
            note.selectedText = dictionary[HIGHLIGHTOBJECT.SELECT_TEXT.lowercased()]
            
            if let savedDate = dictionary[HIGHLIGHTOBJECT.SAVED_ON_DATE.lowercased()] {
                let dateFormatter = DateFormatter(dateFormat: "MMM dd, yyyy HH:mm:ss")
                let date = dateFormatter.date(from: savedDate)
                note.savedDate = date
            }
            
            if let articleInfoId = dictionary[HIGHLIGHTOBJECT.SELECTED_ARTICLE_INFO_ID.lowercased()] {
                if let article = DatabaseManager.SharedInstance.getArticle(articleInfoId: articleInfoId) {
                    note.article = article
                }
            }

            
        }
    }
}
