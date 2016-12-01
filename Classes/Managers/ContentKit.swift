//
//  ContentKit.swift
//  ContentKit
//
//  Created by Sharkey, Justin (ELS-CON) on 10/9/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import Foundation

open class ContentKit {
    
    open static let SharedInstance = ContentKit()
    open static let API = APIManager()
    open static let Database = DatabaseManager()
    open static let FileSystem = FileSystemManager()
    
    lazy var api:APIManager = {
        return ContentKit.API
    }()
    
    lazy var database = {
       return ContentKit.Database
    }()
    
    lazy var fileSystem = {
       return ContentKit.FileSystem
    }()
    
    // MARK: - Initializers -
    
    init() {
    }
    
    public func updateTopArticles(journal: Journal, completion:((Bool)->Void)?) {
//        DatabaseManager.SharedInstance.removeAllTopArticles()
        Networking.MostReadService(issn: journal.issn) { (success) in
            completion?(success)
        }
    }
    
    // MARK: - App -
    
    @discardableResult
    public func updateAppMetadataSynchronously() -> Bool {
        // TODO: implement sync metadata call
        return false
    }
    
    public func updateApp(appShortCode: String, completion:((Bool)->())?) {
        Networking.AppMetadataService(appShortCode: appShortCode) { (success) in
            completion?(success)
        }
    }
    
    // MARK: - Journal -
    
    public func updateJournal(journal: Journal, completion:((Bool)->())?) {
        Networking.JournalService(issn: journal.issn) { (success) in
            completion?(success)
        }
    }
    
    // MARK: - Issue -
    
    public func updateIssues(journal: Journal, completion:((Bool)->())?) {
        Networking.IssueListService(issn: journal.issn) { (success) in
            completion?(success)
            MKStoreManager.shared().sendingProductRequests()
        }
    }
    
    // MARK: - AIP -
    
    public func updateAIPs(journal:Journal, completion:((Bool)->())?) {
        Networking.AIPListService(issn: journal.issn) { (success) in
            completion?(success)
        }
    }
    
    public func updateAIP(article: Article, journal: Journal, completion:((Bool)->())?) {
        Networking.AipArticleService(issn: journal.issn, articlePii: article.articleInfoId) { (success) in
            completion?(success)
        }
    }
    
    // MARK: - Article -
    
    public func updateArticles(issue: Issue, completion:((Bool)->Void)?) {
        Networking.IssueArticlesService(issn: issue.journal.issn, issuePii: issue.issuePii) { (success) in
            completion?(success)
        }
    }
    
    /*@discardableResult
    public func updateIssueArticlesSynchronously(_ issue: Issue) -> Bool {
        // TODO: implement sync metadata call
        return false
    }*/
    
    func updatePreDeepLink(journal: Journal, completion: @escaping (Bool)->()) {
        APIManager.sharedInstance.downloadAppImages { (success) in
            APIManager.sharedInstance.getCSSForJournal(journal, success: { (themeSuccess) in
                completion(true)
            })
        }
    }
    
    func updateForAipArticleDeepLink(journalIssn: String, articlePii: String, completion: @escaping (Bool)->Void) {
        Networking.JournalService(issn: journalIssn) { (success) in
            guard let journal = DatabaseManager.SharedInstance.getJournal(issn: journalIssn) else {
                completion(false)
                return
            }
            self.updatePreDeepLink(journal: journal, completion: { (preDeepLinkSuccess) in
                guard preDeepLinkSuccess else {
                    completion(false)
                    return
                }
                Networking.AipArticleService(issn: journalIssn, articlePii: articlePii, completion: { (aipArticleSuccess) in
                    guard aipArticleSuccess else {
                        completion(false)
                        return
                    }
                    if let article = DatabaseManager.SharedInstance.getArticle(articleInfoId: articlePii) {
                        DMManager.sharedInstance.downloadAIPAbstract(article: article)
                        if article.userHasAccess {
                            DMManager.sharedInstance.download(article: article, withSupplement: false)
                        }
                    }
                    completion(true)
                })
            })
        }
    }
    
    func updateForIssueArticleDeepLink(journalIssn: String, issuePii: String, articlePii: String, completion: @escaping (Bool)->Void) {
        Networking.JournalService(issn: journalIssn) { (journalSuccess) in
            guard journalSuccess else {
                completion(false)
                return
            }
            guard let journal = DatabaseManager.SharedInstance.getJournal(issn: journalIssn) else {
                completion(false)
                return
            }
            self.updatePreDeepLink(journal: journal, completion: { (preSuccess) in
                guard preSuccess else {
                    completion(false)
                    return
                }
                Networking.IssueService(issn: journalIssn, issuePii: issuePii, completion: { (issueSuccess) in
                    guard issueSuccess else {
                        completion(false)
                        return
                    }
                    Networking.IssueArticlesService(issn: journalIssn, issuePii: issuePii, completion: { (articlesSuccess) in
                        guard articlesSuccess else {
                            completion(false)
                            return
                        }
                        if let article = DatabaseManager.SharedInstance.getArticle(articleInfoId: articlePii) {
                            DMManager.sharedInstance.downloadAbstract(article: article)
                            if article.userHasAccess {
                                DMManager.sharedInstance.download(article: article, withSupplement: false)
                            }
                        }
                        completion(true)
                    })
                })
            })
        }
    }
    
    func updateForTopArticlesDeepLink(journalIssn: String, completion: @escaping (Bool)->Void) {
        Networking.JournalService(issn: journalIssn) { (journalSuccess) in
            guard journalSuccess else {
                completion(false)
                return
            }
            guard let journal = DatabaseManager.SharedInstance.getJournal(issn: journalIssn) else {
                completion(false)
                return
            }
            self.updatePreDeepLink(journal: journal, completion: { (preSuccess) in
                guard preSuccess else {
                    completion(false)
                    return
                }
                Networking.MostReadService(issn: journalIssn, completion: { (mostReadSuccess) in
                    guard mostReadSuccess else {
                        completion(false)
                        return
                    }
                    completion(true)
                })
            })
        }
    }
    
    func updateForAipSectionDeepLink(journalIssn: String, completion: @escaping (Bool)->Void) {
        Networking.JournalService(issn: journalIssn) { (journalSuccess) in
            guard journalSuccess else {
                completion(false)
                return
            }
            guard let journal = DatabaseManager.SharedInstance.getJournal(issn: journalIssn) else {
                completion(false)
                return
            }
            ContentKit.SharedInstance.updatePreDeepLink(journal: journal, completion: { (preSuccess) in
                guard preSuccess else {
                    completion(false)
                    return
                }
                Networking.AIPListService(issn: journalIssn) { (aipListSuccess) in
                    guard aipListSuccess else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            })
        }
    }
    
    func updateForIssueTocDeepLink(journalIssn: String, issuePii: String, download: Bool = false, completion: @escaping (Bool)->Void) {
        Networking.JournalService(issn: journalIssn) { (journalSuccess) in
            guard journalSuccess else {
                completion(false)
                return
            }
            guard let journal = DatabaseManager.SharedInstance.getJournal(issn: journalIssn) else {
                completion(false)
                return
            }
            ContentKit.SharedInstance.updatePreDeepLink(journal: journal, completion: { (preSuccess) in
                guard preSuccess else {
                    completion(false)
                    return
                }
                Networking.IssueService(issn: journalIssn, issuePii: issuePii, completion: { (issueSuccess) in
                    guard issueSuccess else {
                        completion(false)
                        return
                    }
                    Networking.IssueArticlesService(issn: journalIssn, issuePii: issuePii, completion: { (articlesSuccess) in
                        guard articlesSuccess else {
                            completion(false)
                            return
                        }
                        guard let issue = DatabaseManager.SharedInstance.getIssue(issuePii) else {
                            completion(false)
                            return
                        }
                        if download {
                            DMManager.sharedInstance.downloadIssue(issue, withSupplement: false, startingWith: nil)
                        }
                        completion(true)
                    })
                })
            })
        }
    }

    // MARK: - CSS -
    
    open func updateCSSForJournal(_ journal: Journal) {
        APIManager.sharedInstance.getCSSForJournal(journal, success: nil)
    }
    
    // MARK: - Misc -
    
    open func performChangesAndSave(_ closure:@escaping ()->()) {
        DispatchQueue.main.async { () -> Void in
            self.database.performChangesAndSave(closure)
        }
    }
    
    func reauthorizeAllJournals() {
        let journals = DatabaseManager.SharedInstance.getAllJournals()
        for journal in journals {
            if let authentication = journal.authentication {
                APIManager.sharedInstance.loginAuthorization(authentication, journal: journal, completion: { (authorized) -> () in
                    if authorized == true {
                        
                    }
                })
            }
        }
    }
}
