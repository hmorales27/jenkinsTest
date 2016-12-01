//
//  DMSection.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 4/3/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

enum DMSectionType {
    case issue
    case aip
    case oa
}

protocol DMSectionDelegate: class {
    func sectionDidUpdate(section: DMSection)
}

class DMSection {
    
    var type: DMSectionType
    
    weak var session: URLSession?
    
    weak var issue: Issue?
    weak var article: Article?
    
    weak var issueTitleView: DMSectionDelegate?
    
    var supplementDownloading: Bool = false
    
    var progress: Float {
        get {
            switch type {
            case .issue:
                return 0
            case .aip:
                return 0
            case .oa:
                return 0
            }
        }
    }
    
    var count: Int {
        return (priorityItems + normalItems).count
    }
    
    var allItems: [DMItem] {        
        return priorityItems + normalItems
    }
    
    var allFullTextItems: [AnyObject]? {
        return nil
    }
    
    var tableViewItems: [DMTableViewItem] {
        
        var items: [DMTableViewItem] = []
        
        for item in priorityItems {
            if let _item = item.fullTextTableViewItem {
                items.append(_item)
            }
            if let _item = item.fullTextSupplementTableViewItem {
                items.append(_item)
            }
            if let _item = item.abstractSupplementTableViewItem {
                items.append(_item)
            }
        }
        
        for item in normalItems {
            if let _item = item.fullTextTableViewItem {
                items.append(_item)
            }
        }
        
        for item in normalItems {
            if let _item = item.fullTextSupplementTableViewItem {
                items.append(_item)
            }
            if let _item = item.abstractSupplementTableViewItem {
                items.append(_item)
            }
        }
        return items
    }
    
    var priorityItems: [DMItem] = []
    var normalItems: [DMItem] = []
    
    var nextItem: DMItem? {
        if priorityItems.count > 0 {
            return priorityItems[0]
        }
        if normalItems.count > 0 {
            return normalItems[0]
        }
        return nil
    }
    
    weak var currentItem: DMItem?
    
    var hasFullTextTasks: Bool {
        for item in allItems {
            if item.hasFullTextTasks {
                return true
            }
        }
        return false
    }
    
    var hasAbstractTasks: Bool {
        for item in allItems {
            if item.hasAbstractTasks {
                return true
            }
        }
        return false
    }
    
    var hasSupplementTasks: Bool {
        
        for item in allItems {
            
            
            if item.hasSupplementTasks {
                return true
            }
        }
        return false
    }
    
    
    // MARK: - Initializers -
    
    init(issue: Issue, type: DMSectionType) {
        self.issue = issue
        self.type = type
    }
    
    init(issue: Issue, type: DMSectionType, session: URLSession?) {
        self.issue = issue
        self.type = type
        self.session = session
    }
    
    init(article: Article, type: DMSectionType) {
        self.article = article
        self.type = type
    }
    
    // MARK: - Add Items -
    
    func addItemsForArticles(_ articles: [Article], withSupplement supplement: Bool, andPriorityArticle priorityArticle: Article?) {
        
        if supplement == true {
            supplementDownloading = true
        }
        
        guard let issue = self.issue else {
            return
        }
        
        var _authentication: IPAuthentication?
        if let date = issue.dateOfRelease {
            
            if IPInfo.Instance.isDate(date, validForISSN: issue.journal.issn) {
                IPInfo.Instance.save()
                _authentication = IPInfo.Instance.currentIPAuthentication
            }
        }
        
        for article in articles {
            
            var item: DMItem
            var newItem: Bool
            
            if let _item = itemForArticle(article) {
                item = _item
                newItem = false
            } else {
                item = DMItem(article: article)
                item.section = self
                newItem = true
            }
            
            if item.fulltextAuthentication == .none {
                item.fulltextAuthentication = _authentication
            }
            
            if item.createFullTextTasks() == true {
                
            }
            
            if supplement == true {
                if item.createFullTextSupplementTasks() == true {
                    
                }
            }
            
            if article == priorityArticle {
                priorityItems.append(item)
            } else {
                if newItem == true {
                    normalItems.append(item)
                }
            }
            
        }
    }
    
    // MARK: - Resume -
    
    @discardableResult func resume() -> Bool {
        switch type {
        case .issue:
            return resumeForIssue()
        case .aip:
            return resumeForAIP()
        case .oa:
            return resumeForOA()
        }
    }
    
    func resumeForIssue() -> Bool {
        currentItem = nil
        
        for item in priorityItems {
            if item.resume(.All) {
                currentItem = item
                return true
            }
        }
        
        for item in normalItems {
            if item.resume(.FullText) {
                currentItem = item
                return true
            }
        }
        
        for item in normalItems {
            if item.resume(.FullTextWithSupplement) {
                currentItem = item
                return true
            }
        }
        
        for item in normalItems {
            if item.resume(.Abstract) {
                currentItem = item
                return true
            }
        }
        
        for item in normalItems {
            if item.resume(.AbstractWithSupplement) {
                currentItem = item
                return true
            }
        }
        
        performOnMainThread { 
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Issue.DownloadComplete), object: self.issue)
        }
        return false
    }
    
    func resumeForAIP() -> Bool {
        for item in priorityItems {
            if item.resume(.All) {
                currentItem = item
                return true
            }
        }
        for item in normalItems {
            if item.resume(.All) {
                currentItem = item
                return true
            }
        }
        
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.AIP.Completed), object: article)
        return false
    }
    
    func resumeForOA() -> Bool {
        for item in priorityItems {
            if item.resume(.All) {
                currentItem = item
                return true
            }
        }
        if let article = article {
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Article.Finished), object: nil, userInfo: ["article": article])
        }
        return false
    }
    
    func invalidate() {
        
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Issue.DownloadComplete), object: issue)
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.AIP.Completed), object: article)
        
        for item in self.priorityItems {
            item.invalidate()
        }
        for item in self.normalItems {
            item.invalidate()
        }
    }
    
    // MARK: - Other -
    
    func itemForArticle(_ article: Article) -> DMItem? {
        for item in priorityItems {
            if item.article == article {
                return item
            }
        }
        for item in normalItems {
            if item.article == article {
                return item
            }
        }
        return nil
    }
    
    func itemForArticle(articleInfoId: String) -> DMItem? {
        for item in priorityItems {
            if item.article.articleInfoId == articleInfoId {
                return item
            }
        }
        for item in normalItems {
            if item.article.articleInfoId == articleInfoId {
                return item
            }
        }
        return nil
    }
    
    // MARK: - Update -
    
    func downloadUpdatedForItem(_ item: DMItem, withType type: DLItemType, completed: Int, total: Int) {
        item.downloadUpdatedForType(type, completed: completed, total: total)
        
    }
    
    func downloadCompletedForItem(_ item: DMItem, withType type: DLItemType) {
        item.downloadCompletedForType(type)
    }
    
    func regenerateTaskForItem(_ item: DMItem, withType type: DLItemType) {
        item.regenerateTask(type: type)
    }
}
