//
//  PushNotificationManager.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/9/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

class PushNotification {
    
    private struct JSONKeys {
        static let extra           = "extra"
        static let journalIdLegacy = "journalid"
        static let alert           = "alert"
        static let articleInfoId   = "articlePii"
        static let issuePii        = "issuePii"
        static let journalIssn     = "issn"
        static let contentType     = "contentType"
        static let screenId        = "screenId"
        static let aps             = "aps"
        static let download        = "download"
    }
    
    class Manager: NSObject, UAPushNotificationDelegate, UARegistrationDelegate {
        
        
        
        
        
        static let shared = Manager()
        
        var activePayload: Payload?
        
        // MARK: - Push Callbacks -
        
        func receivedBackgroundNotification(_ notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            guard let payload = Payload(json: notification) else {
                return
            }
            BackgroundManager.StartBackgroundRequest()
            switch payload.contentType {
            case .DeepLink:
                if Payload.contains(payload: payload) {
                    return
                }
                activePayload = payload
                preFetch(payload: payload, completion: { (success) in
                    self.activePayload = nil
                    switch UIApplication.shared.applicationState {
                    case .active:
                        self.navigateForDeepLink(payload: payload)
                    default:
                        break
                    }
                })
            default:
                break
            }
        }
        
        func receivedForegroundNotification(_ notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            guard let payload = Payload(json: notification) else {
                return
            }
            switch payload.contentType {
            case .DeepLink:
                postFetch(payload: payload) { (success) in
                    self.presentForegroundAlert(payload: payload)
                }
            default:
                break
            }
            
        }
        
        // MARK: - Notification Click -
        
        func launched(fromNotification notification: [AnyHashable : Any]) {
            guard let payload = Payload(json: notification) else {
                return
            }
            switch payload.contentType {
            case .DeepLink:
                
                AppDelegate.shared.overlord.removeAllAndPushViewController(SplashScreenViewController(deepLink: true), animated: false)
                
                if Payload.contains(payload: payload) {
                    navigateForDeepLink(payload: payload)
                    return
                }
                
                if let activePayload = self.activePayload {
                    if activePayload == payload {
                        return
                    }
                }
                
                postFetch(payload: payload) { (success) in
                    self.navigateForDeepLink(payload: payload)
                }
                
            default:
                break
            }
        }
        
        // MARK: - Fetch Data -
        
        private func preFetch(payload: Payload, completion: ((Bool)->Void)?) {
            downloadContent(payload: payload) { (success) in
                completion?(success)
            }
        }

        private func postFetch(payload: Payload, completion: ((Bool)->Void)?) {
            downloadContent(payload: payload) { (success) in
                completion?(success)
            }
        }
        
        private func presentForegroundAlert(payload: Payload) {
            let title = Bundle.appName()
            let icon = Bundle.appIcon()
            let subTitle = payload.alert
            let onTapBlock = blockToHandleNotification(payload: payload)
            let notificationAlert = JBSMPushNotificationView(title: title, subTitle: subTitle, onTapBlock: onTapBlock, onDismissBlock: nil, backgroundColor: UIColor.black, image: icon)
            notificationAlert.type = .dark
            notificationAlert.show()
        }
        
        private func navigateForDeepLink(payload: Payload) {
            switch payload.contentType {
                
            case .DeepLink:
                guard let overlord = AppDelegate.shared.overlord else {
                    return
                }
                let publisher = DatabaseManager.SharedInstance.getAppPublisher()
                
                switch payload.screenType {
                    
                case .TopArticle:
                    let journal = DatabaseManager.SharedInstance.getJournal(issn: payload.journalIssn)
                    let appInfo = Overlord.CurrentAppInformation(publisher: publisher, journal: journal, issue: nil, article: nil)
                    overlord.navigateToViewControllerType(.topArticles, appInfo: appInfo)
                    
                case .AIPSection:
                    let journal = DatabaseManager.SharedInstance.getJournal(issn: payload.journalIssn)
                    let appInfo = Overlord.CurrentAppInformation(publisher: publisher, journal: journal, issue: nil, article: nil)
                    overlord.navigateToViewControllerType(.aips, appInfo: appInfo)
                    
                case .AIPArticle:
                    let journal = DatabaseManager.SharedInstance.getJournal(issn: payload.journalIssn)
                    let article = DatabaseManager.SharedInstance.getArticle(articleInfoId: payload.articleInfoId)
                    let appInfo = Overlord.CurrentAppInformation(publisher: publisher, journal: journal, issue: nil, article: article)
                    overlord.navigateToViewControllerType(.aipArticle, appInfo: appInfo)
                    
                case .TableOfContents:
                    let journal = DatabaseManager.SharedInstance.getJournal(issn: payload.journalIssn)
                    let issue = DatabaseManager.SharedInstance.getIssue(payload.issuePii)
                    let appInfo = Overlord.CurrentAppInformation(publisher: publisher, journal: journal, issue: issue, article: nil)
                    overlord.navigateToViewControllerType(.issueTOC, appInfo: appInfo)
                    
                case .IssueArticle:
                    let journal = DatabaseManager.SharedInstance.getJournal(issn: payload.journalIssn)
                    let issue = DatabaseManager.SharedInstance.getIssue(payload.issuePii)
                    let article = DatabaseManager.SharedInstance.getArticle(articleInfoId: payload.articleInfoId)
                    let appInfo = Overlord.CurrentAppInformation(publisher: publisher, journal: journal, issue: issue, article: article)
                    overlord.navigateToViewControllerType(.issueArticle, appInfo: appInfo)
                    
                default:
                    break
                }
                break
            default:
                break
            }
        }
        
        func blockToHandleNotification(payload:Payload) -> voidBlock {
            return { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.navigateForDeepLink(payload: payload)
            }
        }
        
        /*
         *  General Deep Link
        */
        
        private func downloadContent(payload: Payload, completion: @escaping (Bool)->Void) {
            switch payload.screenType {
                
            case .AIPArticle:
                ContentKit.SharedInstance.updateForAipArticleDeepLink(journalIssn: payload.journalIssn, articlePii: payload.articleInfoId, completion: { (success) in
                    Payload.add(payload: payload)
                    completion(success)
                })
                
            case .IssueArticle:
                ContentKit.SharedInstance.updateForIssueArticleDeepLink(journalIssn: payload.journalIssn, issuePii: payload.issuePii, articlePii: payload.articleInfoId, completion: { (success) in
                    Payload.add(payload: payload)
                    completion(success)
                })
                
            case .TopArticle:
                ContentKit.SharedInstance.updateForTopArticlesDeepLink(journalIssn: payload.journalIssn, completion: { (success) in
                    Payload.add(payload: payload)
                    completion(success)
                })
                
            case .AIPSection:
                ContentKit.SharedInstance.updateForAipSectionDeepLink(journalIssn: payload.journalIssn, completion: { (success) in
                    Payload.add(payload: payload)
                    completion(success)
                })
                
            case .TableOfContents:
                ContentKit.SharedInstance.updateForIssueTocDeepLink(journalIssn: payload.journalIssn, issuePii: payload.issuePii, download: payload.download, completion: { (success) in
                    Payload.add(payload: payload)
                    completion(success)
                })
                
            default:
                break
            }
        }
        
        // MARK: - Article -
        
        private func download(article: Article) {
            if article.issue == nil {
                if article.userHasAccess {
                    DMManager.sharedInstance.downloadAIP(article, withSupplement: false)
                } else {
                    DMManager.sharedInstance.downloadAIPAbstract(article: article)
                }
            } else {
                if article.userHasAccess {
                    DMManager.sharedInstance.download(article: article, withSupplement: false)
                } else {
                    DMManager.sharedInstance.downloadAbstract(article: article)
                }
            }
        }
        
        private func download(issue: Issue) {
            DMManager.sharedInstance.downloadIssue(issue, withSupplement: false, startingWith: nil)
        }
    }
    
    enum ScreenType: Int {
        case AIPArticle      = 1
        case LatestIssue     = 2
        case IssueArticle    = 3
        case TopArticle      = 4
        case AIPSection      = 5
        case TableOfContents = 6
    }
    
    enum ContentType: String {
        case ContentOnly     = "contentonly"
        case DeepLink        = "deeplink"
        
        static func from(string: String) -> ContentType? {
            if string.lowercased() == "deeplink" {
                return .DeepLink
            }
            return nil
        }
    }
    
    
    
    struct Payload {
        
        static private let pastPayloadsPath: String = "\(Strings.AppShortCode.lowercased()).pastPayloads"
        
        static var pastPayloads: [Payload] {
            get {
                guard let payloadData = UserDefaults.standard.data(forKey: pastPayloadsPath) else { return [] }
                do {
                    guard let json = try JSONSerialization.jsonObject(with: payloadData, options: .allowFragments) as? [[String: Any]] else { return [] }
                    return json.map({ (payloadJson) -> Payload in
                        return Payload(json: payloadJson)!
                    })
                } catch _ {
                    return []
                }
            }
            set(payloads) {
                let encodedPayloads = payloads.map { (payload) -> [String: Any] in
                    return payload.encode()
                }
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: encodedPayloads, options: .prettyPrinted)
                    UserDefaults.standard.set(jsonData, forKey: pastPayloadsPath)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        
        static func add(payload: Payload) {
            var _pastPayloads = pastPayloads
            _pastPayloads.append(payload)
            pastPayloads = _pastPayloads
        }
        
        static func contains(payload: Payload) -> Bool {
            for _payload in pastPayloads {
                if _payload == payload {
                    return true
                }
            }
            return false
        }

        static func ==(left: Payload, right: Payload) -> Bool {
            guard left.journalIssn == right.journalIssn else {
                return false
            }
            guard left.issuePii == right.issuePii else {
                return false
            }
            guard left.articleInfoId == right.articleInfoId else {
                return false
            }
            guard left.screenType == right.screenType else {
                return false
            }
            return true
        }
        
        let contentType   : ContentType
        let screenType    : ScreenType
        
        var journalid     : String = ""
        var alert         : String = ""
        var articleInfoId : String = ""
        var issuePii      : String = ""
        var journalIssn   : String = ""
        var journalId     : String = ""
        var download      : Bool   = false
        
        func encode() -> [String: Any] {
            var final: [String: Any] = [:]
            final[JSONKeys.screenId]      = screenType.rawValue
            final[JSONKeys.journalIssn]   = journalIssn
            final[JSONKeys.issuePii]      = issuePii
            final[JSONKeys.articleInfoId] = articleInfoId
            final[JSONKeys.contentType]   = contentType.rawValue
            return final
        }
        
        init?(json: [AnyHashable: Any]) {
            
            guard let contentTypeString = json[JSONKeys.contentType] as? String, let contentType = ContentType.from(string: contentTypeString) else {
                return nil
            }

            guard let screenId = json[JSONKeys.screenId] as? Int, let screenType = ScreenType(rawValue: screenId) else {
                return nil
            }
            
            self.screenType = screenType
            self.contentType = contentType
            
            if let aps = json[JSONKeys.aps] as? [String: AnyObject] {
                if let alert = aps[JSONKeys.alert] as? String {
                    self.alert = alert
                }
            }
            
            if let download = json[JSONKeys.download] as? Bool {
                self.download = download
            }
            
            switch contentType {
            case .ContentOnly:
                break
            case .DeepLink:
                
                switch screenType {
                    
                case .TopArticle, .LatestIssue, .AIPSection:
                    
                    guard let journalIssn = json[JSONKeys.journalIssn] as? String else {
                        return nil
                    }
                    self.journalIssn = journalIssn.jbsmClean()
                    
                case .TableOfContents:
                    
                    guard let journalIssn = json[JSONKeys.journalIssn] as? String else {
                        return nil
                    }
                    guard let issuePii = json[JSONKeys.issuePii] as? String else {
                        return nil
                    }
                    self.journalIssn = journalIssn.jbsmClean()
                    self.issuePii = issuePii.jbsmClean()
                
                case .AIPArticle:
                    
                    guard let journalIssn = json[JSONKeys.journalIssn] as? String else {
                        return nil
                    }
                    guard let articleInfoId = json[JSONKeys.articleInfoId] as? String else {
                        return nil
                    }
                    self.journalIssn = journalIssn.jbsmClean()
                    self.articleInfoId = articleInfoId.jbsmClean()
                    
                case .IssueArticle:
                    
                    guard let journalIssn = json[JSONKeys.journalIssn] as? String else {
                        return nil
                    }
                    guard let issuePii = json[JSONKeys.issuePii] as? String else {
                        return nil
                    }
                    guard let articleInfoId = json[JSONKeys.articleInfoId] as? String else {
                        return nil
                    }
                    self.journalIssn = journalIssn.jbsmClean()
                    self.issuePii = issuePii.jbsmClean()
                    self.articleInfoId = articleInfoId.jbsmClean()
                }
            }
        }
        
        private func cleanIssn(_ issn: String) -> String {
            return ""
        }
    }
}
