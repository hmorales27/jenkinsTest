//
//  DMManager.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 4/3/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import ZipArchive

@objc class DMManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    static let sharedInstance = DMManager()
    static var session: Foundation.URLSession!
    
    static var BackgroundSession    : Foundation.URLSession?
    static var UseBackgroundSession : Bool = false
    
    let reachability = Reachability.forInternetConnection()
    
    var resumeData: Data?
    var failedTask: URLSessionDownloadTask?
    
    var timer: Timer =  Timer()
    
    var downloadQueue: OperationQueue?
    
    var sections: [DMSection] = []
    var sectionsWithFullText: [DMSection] {
        var _sections: [DMSection] = []
        for section in sections {
            if section.hasFullTextTasks == true {
                _sections.append(section)
            }
        }
        return _sections
    }
    
    var sectionsWithSupplement: [DMSection] {
        var _sections: [DMSection] = []
        
        for section in sections {
            if section.hasSupplementTasks == true {
                _sections.append(section)
            }
        }
        return _sections
    }
    
    var sectionsWithFullTextOrSupplement: [DMSection] {
        var _sections: [DMSection] = []
        for section in sections {
            if section.hasFullTextTasks || section.hasSupplementTasks {
                _sections.append(section)
            }
        }
        return _sections
    }
    
    
    func resumeDownloadIfStalled(_ timer: Timer) {
        resume()
    }
    
    weak var currentSection: DMSection?
    
    var downloading = false
    
    func sectionForIssue(_ issue: Issue) -> DMSection? {
        return sectionForIssue(issuePii: issue.issuePii)
    }
    
    func sectionForIssue(issuePii: String) -> DMSection? {

        for section in sections {
            if section.issue?.issuePii == issuePii {
                return section
            }
        }
        return nil
    }
    
    func sectionForArticle(article: Article) -> DMSection? {
        return sectionForArticle(articleInfoId: article.articleInfoId)
    }
    
    func sectionForArticle(articleInfoId: String) -> DMSection? {
        for section in sections {
            if section.article?.articleInfoId == articleInfoId {
                return section
            }
        }
        return nil
    }
    
    func indexOfSection(_ section: DMSection) -> Int? {
        var count = 0
        for _section in sections {
            if _section.issue == section.issue {
                return count
            }
            count += 1
        }
        return nil
    }
    
    // MARK: - Initializer -
    
    override init() {
        super.init()
        
        var config: URLSessionConfiguration
        if Strings.BackgroundDownload == true {
            config = URLSessionConfiguration.background(withIdentifier: "com.elsevier.jbsm.swift.download")
            config.httpMaximumConnectionsPerHost = 1
            config.sessionSendsLaunchEvents = true
            config.isDiscretionary = false
            downloadQueue = OperationQueue()
            downloadQueue?.maxConcurrentOperationCount = 1
        } else {
            config = URLSessionConfiguration.default
        }
        DMManager.session = Foundation.URLSession(configuration: config, delegate: self, delegateQueue: downloadQueue)
        
        NotificationCenter.default.addObserver(self, selector: #selector(connectionDidChange(_:)), name: NSNotification.Name.reachabilityChanged, object: nil)
        self.reachability?.startNotifier()
    }
    
    func connectionDidChange(_ notification: Foundation.Notification) {
        let status = reachability?.currentReachabilityStatus()
        /*switch status {
        case .ReachableViaWiFi, .ReachableViaWWAN:
            if var task = self.failedTask, let data = resumeData {
                self.failedTask = nil
                self.resumeData = nil
                
                task = DMManager.session.downloadTask(withResumeData: data)
                task.resume()
            } else {
                self.resume()
            }
            
        case .NotReachable:
            break
        }*/
    }
    
    func resume() {
        if self.sections.count > 0 {
            if self.currentSection?.currentItem?.currentTask == nil {
                let section = self.sections[0]
                if section.resume() {
                    self.currentSection = section
                } else {
                    self.sections.remove(at: 0)
                    self.resume()
                }
            }
        } else {
            BackgroundManager.StopBackgroundRequest()
        }
    }
    
    // MARK: - Other -
    
    func downloadAIPAbstracts(journal: Journal) {
        for article in DatabaseManager.SharedInstance.getAips(journal: journal) {
            downloadAIPAbstract(article: article)
        }
    }
    
    func downloadAIPAbstract(article: Article) {
        switch article.downloadInfo.abstractDownloadStatus {
        case .notDownloaded, .downloadFailed:
            var section: DMSection
            var isNewSection: Bool = false
            if let _section = sectionForArticle(article: article) {
                section = _section
            } else {
                section = DMSection(article: article, type: .aip)
                isNewSection = true
            }
            let item = DMItem(article: article)
            item.createAbstractTasksWithSupplement(false)
            section.priorityItems.append(item)
            if isNewSection {
                sections.insert(section, at: 0)
            }
        default:
            break
        }
        resume()
    }
    
    func downloadAbstracts(issue: Issue) {
        
        let articles = DatabaseManager.SharedInstance.getAllArticlesForIssue(issue)
        if articles.count > 0 {
            var section: DMSection
            var newSection: Bool
            
            //  ***STEP THROUGH
            
            if let _section = sectionForIssue(issue) {
                section = _section
                newSection = false
            } else {
                section = DMSection(issue: issue, type: .issue)
                newSection = true
            }
            
            for article in articles {
                var item: DMItem
                if newSection == true {
                    item = DMItem(article: article)
                    item.section = section
                    section.normalItems.append(item)
                } else {
                    if let _item = section.itemForArticle(article) {
                        item = _item
                    } else {
                        item = DMItem(article: article)
                        item.section = section
                        section.normalItems.append(item)
                    }
                }
                item.createAbstractTasksWithSupplement(false)
            }
            if newSection == true {
                sections.insert(section, at: 0)
            }
            resume()
        }
    }
    
    func downloadAbstract(article: Article) {
        
        guard let issue = article.issue else {
            return
        }
        
        var section: DMSection
        var newSection: Bool
        
        //  ***STEP THROUGH
        
        if let _section = sectionForIssue(issue) {
            section = _section
            newSection = false
        } else {
            section = DMSection(issue: issue, type: .issue)
            newSection = true
        }
        
        var item: DMItem
        if newSection == true {
            item = DMItem(article: article)
            item.section = section
            section.normalItems.append(item)
        } else {
            if let _item = section.itemForArticle(article) {
                item = _item
            } else {
                item = DMItem(article: article)
                item.section = section
                section.normalItems.append(item)
            }
        }
        item.createAbstractTasksWithSupplement(false)

        if newSection == true {
            sections.insert(section, at: 0)
        }
        resume()
        
    }

    func downloadIssue(_ issue: Issue, withSupplement supplement: Bool, startingWith priorityArticle: Article?) {

        if let date = issue.dateOfRelease {
            if IPInfo.Instance.isDate(date, validForISSN: issue.journal.issn) {
                IPInfo.Instance.save()
            }
        }
        
        var articles: [Article]
        if let article = priorityArticle {
            articles = issue.orderArticlesStartingWithArticle(article)
        } else {
            articles = issue.allArticles
        }
    
        var section: DMSection
        var newSection: Bool
        
        if let _section = sectionForIssue(issue) {
            section = _section
            newSection = false
        } else {
            section = DMSection(issue: issue, type: .issue)
            newSection = true
        }
        section.addItemsForArticles(articles, withSupplement: supplement, andPriorityArticle: priorityArticle)
        
        if newSection == true {
            sections.insert(section, at: 0)
        }else{
            for index in 0..<sections.count {
                if sections[index] === section {
                    sections.remove(at: index)
                    break
                }
            }
            sections.insert(section, at: 0)
        }
        
        resume()
        
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Issue.DownloadStarted), object: issue)
    }
    
    fileprivate func download(_ articles: [Article], forSection section: DMSection) {
        
    }
    
    func downloadFullTextSupplement(article: Article) {
        
        var section: DMSection
        var newSection: Bool
        
        if let issue = article.issue {
            if let _section = sectionForIssue(issue) {
                section = _section
                newSection = false
            } else {
                section = DMSection(issue: issue, type: .issue)
                newSection = true
            }
            
            var item: DMItem
            if newSection == true {
                item = DMItem(article: article)
                item.section = section
            } else {
                if let _item = section.itemForArticle(article) {
                    item = _item
                } else {
                    item = DMItem(article: article)
                    item.section = section
                }
            }
            
            section.priorityItems.append(item)
            
            item.createFullTextTaks(false, withSupplement: true)
            
            if newSection == true {
                sections.insert(section, at: 0)
            } else {
                if let index = indexOfSection(section) {
                    sections.remove(at: index)
                    sections.insert(section, at: 0)
                } else {
                    sections.append(section)
                }
            }
            resume()
        } else {
            
            if let _section = sectionForArticle(article: article) {
                section = _section
                newSection = false
            } else {
                section = DMSection(article: article, type: .aip)
                newSection = true
            }
            
            var item: DMItem
            switch newSection {
            case true:
                item = DMItem(article: article)
                item.section = section
            case false:
                if let _item = section.itemForArticle(article) {
                    item = _item
                } else {
                    item = DMItem(article: article)
                    item.section = section
                }
            }
            
            item.createFullTextSupplementTasks()
            section.priorityItems.append(item)
            
            if newSection == true {
                sections.insert(section, at: 0)
            } else {
                if let index = indexOfSection(section) {
                    sections.remove(at: index)
                    sections.insert(section, at: 0)
                } else {
                    sections.append(section)
                }
            }
            resume()
        }
    }
    
    func downloadMedia(_ media: Media) {
        
        //  This func will, in many ways, mirror what is being done in download..Supplement (see above)
        
        var section: DMSection
        var newSection: Bool
        
        if let issue = media.article.issue {
            
            if let _section = sectionForIssue(issue) {
                section = _section
                newSection = false
            } else {
                section = DMSection(issue: issue, type: .issue)
                newSection = true
            }
            var item: DMItem
            if newSection == true {
                
                item = DMItem(article: media.article)
                item.section = section
            } else {
                if let _item = section.itemForArticle(media.article) {
                    item = _item
                } else {
                    item = DMItem(article: media.article)
                    item.section = section
                }
            }
            section.priorityItems.append(item)
            
            item.createFullTextTaks(false, withSupplement: true)
            
            if newSection == true {
                sections.insert(section, at: 0)
            } else {
                if let index = indexOfSection(section) {
                    sections.remove(at: index)
                    sections.insert(section, at: 0)
                } else {
                    sections.append(section)
                }
            }
            resume()
        }
    }
    
    
    
    func changePriorityForArticle(_ article: Article) {
        if let issue = article.issue {
            if let section = sectionForIssue(issue) {
                
                if let item = section.itemForArticle(article) {
                    section.priorityItems.insert(item, at: 0)
                    section.normalItems = section.normalItems.filter({ (_item) -> Bool in
                        item !== _item
                    })
                }
            }
        }
    }
    
    func downloadAIP(article: Article, withSupplement supplement: Bool) {
        let section = DMSection(article: article, type: .aip)
        let item = DMItem(article: article)
        item.section = section
        item.createFullTextTasksWithSupplement(supplement)
        section.priorityItems.append(item)
        sections.insert(section, at: 0)
        resume()
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.AIP.Started), object: article)
    }
    
    func downloadOaArticle(_ article: Article, withSupplement supplement: Bool) {
        let section = DMSection(article: article, type: .oa)
        let item = DMItem(article: article)
        item.section = section
        item.createFullTextTasksWithSupplement(supplement)
        section.priorityItems.append(item)
        sections.insert(section, at: 0)
        resume()
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Article.Started), object: self, userInfo:["article": article])
    }
    
    func download(article: Article, withSupplement supplement: Bool) {
        if article.issue == .none {
            //  AIP
            downloadAIP(article, withSupplement: supplement)
        } else {
            //  OA
            downloadOA(article, withSupplement: supplement)
        }
    }
    
    func downloadAIP(_ article: Article, withSupplement supplement: Bool) {
        
        var section: DMSection
        if let issue = article.issue {
            section = DMSection(issue: issue, type: .issue)
        } else {
            section = DMSection(article: article, type: .oa)
        }

        let item = DMItem(article: article)
        item.section = section
        item.createFullTextTasksWithSupplement(supplement)
        section.priorityItems.append(item)
        sections.insert(section, at: 0)
        
        resume()
        
        if article.issue != nil {
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.AIP.Started), object: article)
        } else {
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Article.Updated), object: article)
        }
    }
    
    func downloadOA(_ article: Article, withSupplement supplement: Bool) {
        
        guard let issue = article.issue else {
            return
        }
        
        var section: DMSection
        var newSection: Bool
        
        if let _section = sectionForIssue(issue) {
            section = _section
            newSection = false
        } else {
            section = DMSection(issue: issue, type: .issue)
            newSection = true
        }
        
        section.addItemsForArticles([article], withSupplement: supplement, andPriorityArticle: nil)
        
        if newSection == true {
            sections.insert(section, at: 0)
        }
        
        resume()
        
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Issue.DownloadStarted), object: issue)
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Article.Started), object: nil, userInfo: ["article": article])
    }
    
    func cancelDownloadForIssue(_ issue: Issue) {
        for section in sections {
            if section.issue == issue {
                section.invalidate()
                if section.issue == currentSection?.issue {
                    resume()
                }
                return
            }
        }
    }
    
    func cancelDownloadForAIP(_ aip: Article) {
        for section in sections {
            if section.article == aip {
                section.invalidate()
                if section.article == currentSection?.article {
                    resume()
                }
                return
            }
        }
    }
    
    //  Run this?
    func cancelDownloadForOa(_ oaArticle: Article) {
        for section in sections {
            if section.article == oaArticle {
                section.invalidate()
                if section.article == currentSection?.article {
                    resume()
                }
                return
                
            }
        }
    }
    
    // MARK: - NSURLSession -
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        log.error(error?.localizedDescription)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let info = infoForTask(downloadTask) else { return }
        info.section.downloadUpdatedForItem(info.item, withType: info.type, completed: Int(totalBytesWritten), total: Int(totalBytesExpectedToWrite))
    }
    
    func infoForTask(_ task: URLSessionDownloadTask) -> (article: Article, section: DMSection, item: DMItem, type: DLItemType)? {
        
        guard let headerValues = task.originalRequest?.allHTTPHeaderFields else {
            return nil
        }
        
        guard let itemType = headerValues["type"] else {
            return nil
        }
        
        var section: DMSection
        if let issuePii = headerValues["issue"] {
            if let _section = sectionForIssue(issuePii: issuePii) {
                section = _section
            } else {
                return nil
            }
        } else if let articleInfoId = headerValues["article"] {
            if let _section = sectionForArticle(articleInfoId: articleInfoId) {
                section = _section
            } else {
                return nil
            }
        } else {
            return nil
        }
        
        var item: DMItem
        if let articleInfoId = headerValues["article"] {
            if let _item = section.itemForArticle(articleInfoId: articleInfoId) {
                item = _item
            } else {
                return nil
            }
        } else {
            return nil
        }
        
        let article = item.article
        
        guard let type = DLItemType(rawValue: itemType) else {
            return nil
        }
        
        return (article, section, item, type)
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let info = infoForTask(downloadTask) else { return }
        
        let article = info.article
        let type    = info.type
        let section = info.section
        let item    = info.item
        
        var destinationPath: String?
        
        switch type {
            
        case .AbstractHTML:
            destinationPath = article.journal.abstractsPath
            
        case .AbstractImages:
            destinationPath = article.journal.abstractsPath
            
        case .AbstractSupplement:
            destinationPath = article.abstractDirectory
            
        case .FullTextHTML:
            destinationPath = article.journal.fullTextPath
            if let auth = item.fulltextAuthentication {
                DatabaseManager.SharedInstance.performChangesAndSave({ 
                    article.ipAuthentication = auth
                })
            }
            
        case .FullTextImages:
            destinationPath = article.journal.fullTextPath
            
        case .FullTextSupplement:
            destinationPath = article.fulltextBasePath
            
        default:
            break
        }
        
        guard let path = destinationPath else {
            return
        }
        
        var status: DownloadStatus?
        
        do {
            try SSZipArchive.unzipFile(atPath: location.path, toDestination: path, overwrite: true, password: nil)
            status = .downloaded
        } catch let error as NSError {
            status = .downloadFailed
            log.error(error.localizedDescription)
        }
        
        switch type {
        case .AbstractImages:
            let htmlAssetsPath = article.abstractDirectory + "image"
            let assetsImagePath = article.abstractImagesBasePath + "image"
            
            do {
                try FileManager.default.moveItem(atPath: assetsImagePath, toPath: htmlAssetsPath)
                try FileManager.default.removeItem(atPath: article.abstractImagesBasePath)
            } catch let error as NSError {
                log.error(error.localizedDescription)
            }
        case .FullTextHTML:
            do {
                try FileManager.default.createDirectory(atPath: article.fulltextBasePath, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                log.error(error.localizedDescription)
            }
        case .FullTextImages:
            let htmlAssetsPath = article.fulltextBasePath + "image"
            let assetsImagePath = article.fulltextImagesBasePath + "image"
            
            do {
                try FileManager.default.moveItem(atPath: assetsImagePath, toPath: htmlAssetsPath)
                try FileManager.default.removeItem(atPath: article.fulltextImagesBasePath)
            } catch let error as NSError {
                log.error(error.localizedDescription)
            }
        default:
            break
        }
        
        DatabaseManager.SharedInstance.performChangesAndSave { 
            article.downloadInfo.update(downloadType: type, withStatus: status!)
            section.downloadCompletedForItem(item, withType: type)
            self.resume()
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            
            log.error(error.localizedDescription)

            guard let section = currentSection else { return  }
            
            guard let item = section.currentItem else { return }
            
            guard let type = item.downloadingTaskType else { return }
            
            DatabaseManager.SharedInstance.performChangesAndSave {
                item.article.downloadInfo.update(downloadType: type, withStatus: .downloadFailed)
            }
            
            if error.localizedDescription == "The network connection was lost." {
                DatabaseManager.SharedInstance.performChangesAndSave {
                    item.article.downloadInfo.update(downloadType: type, withStatus: .downloadFailed)
                    section.regenerateTaskForItem(item, withType: type)
                    self.currentSection = nil
                    
                    if self.reachability?.isReachable() == true {
                        self.resume()
                    }
                }
            } else {
                DatabaseManager.SharedInstance.performChangesAndSave {
                    self.currentSection = nil
                    self.resume()
                }
            }
        }
        
    }
}
