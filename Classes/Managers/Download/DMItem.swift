//
//  DMItem.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 4/3/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

enum DMItemType: String {
    case FullText = "FullText"
    case FullTextWithSupplement = "FullTextWithSupplement"
    case Abstract = "Abstract"
    case AbstractWithSupplement = "AbstractWithSupplement"
    case All = "All"
}

enum DLItemType: String {
    case FullText = "FullText"
    case FullTextHTML = "FullTextHTML"
    case FullTextImages = "FullTextImages"
    case FullTextSupplement = "FullTextSupplement"
    case Abstract = "Abstract"
    case AbstractHTML = "AbstractHTML"
    case AbstractImages = "AbstractImages"
    case AbstractSupplement = "AbstractSupplement"
    case PDF = "PDF"
}

class DMTableViewItem {
    
    weak var article: Article?
    var type: DLItemType
    var item: DMItem
    
    init(article: Article, type: DLItemType, item: DMItem) {
        self.article = article
        self.type = type
        self.item = item
    }
    
}

class DMItem {
    
    let article: Article
    
    weak var section: DMSection?
    
    var downloadingTaskType: DLItemType?
    
    var downloading = false
    var completed: Bool {
        if abstractDownload == false && fullTextDownload == false {
            return true
        }
        return false
    }
    
    var abstractDownload                : Bool = false
    var fullTextDownload                : Bool = false
    
    var fullTextExists                  : Bool = false
    var fullTextDownloaded              : Bool = false
    var fullTextTotal : Int {
        return fullTextHTMLTaskTotal + fullTextImagesTaskTotal
    }
    var fullTextCompleted : Int {
        return fullTextHTMLTaskCompleted + fullTextImagesTaskCompleted
    }
    var fullTextProgress: Float {
        if fullTextCompleted == 0 {
            return 0
        }
        return Float(fullTextCompleted)/Float(fullTextTotal)
    }

    var fullTextSupplementExists        : Bool = false
    var fullTextSupplementDownloaded    : Bool = false
    var fullTextSupplementTotal: Int {
        return fullTextSupplementTaskTotal
    }
    var fullTextSupplementCompleted : Int {
        return fullTextSupplementTaskCompleted
    }
    var fullTextSupplementProgress: Float {
        if fullTextSupplementCompleted == 0 {
            return 0
        }
        return Float(fullTextSupplementCompleted)/Float(fullTextSupplementTotal)
    }
    
    var abstractSupplementExists        : Bool = false
    var abstractsupplementDownloaded    : Bool = false
    var abstractSupplementTotal: Int {
        return abstractSupplementTaskTotal
    }
    var abstractSupplementCompleted: Int {
        return abstractSupplementTaskCompleted
    }
    var abstractSupplementProgress: Float {
        if abstractSupplementCompleted == 0 {
            return 0
        }
        return Float(abstractSupplementCompleted)/Float(abstractSupplementTotal)
    }
    
    weak var abstractHTMLTask           : URLSessionDownloadTask?
    var abstractHTMLTaskCompleted       : Int = 0
    var abstractHTMLTaskTotal           : Int = 0
    
    weak var abstractImagesTask         : URLSessionDownloadTask?
    var abstractImagesTaskCompleted     : Int = 0
    var abstractImagesTaskTotal         : Int = 0
    
    weak var abstractMultimediaTask     : URLSessionDownloadTask?
    var abstractSupplementTaskCompleted : Int = 0
    var abstractSupplementTaskTotal     : Int = 0
    
    var fulltextAuthentication          : IPAuthentication?
    
    weak var fullTextHTMLTask           : URLSessionDownloadTask?
    var fullTextHTMLTaskCompleted       : Int = 0
    var fullTextHTMLTaskTotal           : Int = 0
    
    weak var fullTextImagesTask         : URLSessionDownloadTask?
    var fullTextImagesTaskCompleted     : Int = 0
    var fullTextImagesTaskTotal         : Int = 0
    
    weak var fullTextMultimediaTask     : URLSessionDownloadTask?
    var fullTextSupplementTaskCompleted : Int = 0
    var fullTextSupplementTaskTotal     : Int = 0
    
    var fullTextTableViewItem: DMTableViewItem? {
        if fullTextExists == true && fullTextDownloaded == false {
            return DMTableViewItem(article: article, type: .FullText, item: self)
        }
        return nil
    }
    
    var fullTextSupplementTableViewItem: DMTableViewItem? {
        if fullTextSupplementExists == true && fullTextSupplementDownloaded == false {
            return DMTableViewItem(article: article, type: .FullTextSupplement, item: self)
        }
        return nil
    }
    
    var abstractSupplementTableViewItem: DMTableViewItem? {
        if abstractSupplementExists == true && abstractsupplementDownloaded == false {
            return DMTableViewItem(article: article, type: .AbstractSupplement, item: self)
        }
        return nil
    }
    
    var hasFullTextTasks: Bool {
        get {
            if fullTextHTMLTask != .none {
                return true
            }
            if fullTextImagesTask != . none {
                return true
            }
            if fullTextMultimediaTask != .none {
                return true
            }
            return false
        }
    }
    
    var hasAbstractTasks: Bool {
        get {
            if abstractHTMLTask != .none {
                return true
            }
            if abstractImagesTask != .none {
                return true
            }
            return false
        }
    }
    
    var hasSupplementTasks: Bool {
        
        get {
            if fullTextMultimediaTask != .none {
                return true
            }
            
            return false
        }
    }
    
    
    weak var currentTask: URLSessionDownloadTask?
    
    var nextTask: URLSessionDownloadTask? {
        get {
            if let task = fullTextHTMLTask {
                if task.state == .completed {
                    log.warning("Deleting Completed Task")
                    fullTextHTMLTask = nil
                } else {
                    downloadingTaskType = DLItemType.FullTextHTML
                    return task
                }
            }
            if let task = fullTextImagesTask {
                if task.state == .completed {
                    log.warning("Deleting Completed Task")
                    fullTextImagesTask = nil
                } else {
                    downloadingTaskType = DLItemType.FullTextImages
                    return task
                }
            }
            if let task = fullTextMultimediaTask {
                if task.state == .completed {
                    log.warning("Deleting Completed Task")
                    fullTextMultimediaTask = nil
                } else {
                    downloadingTaskType = DLItemType.FullTextSupplement
                    return task
                }
            }
            if let task = abstractHTMLTask {
                if task.state == . completed {
                    log.warning("Deleting Completed Task")
                    abstractHTMLTask = nil
                } else {
                    downloadingTaskType = DLItemType.AbstractHTML
                    return task
                }
            }
            if let task = abstractImagesTask {
                if task.state == .completed {
                    log.warning("Deleting Completed Task")
                    abstractImagesTask = nil
                } else {
                    downloadingTaskType = DLItemType.AbstractImages
                    return task
                }
            }
            if let task = abstractMultimediaTask {
                if task.state == .completed {
                    log.warning("Deleting Completed Task")
                    abstractMultimediaTask = nil
                } else {
                    downloadingTaskType = DLItemType.AbstractSupplement
                    return task
                }
            }
            return nil
        }
    }
    
    var nextAbstractTask: URLSessionDownloadTask? {
        get {
            if let task = abstractHTMLTask {
                if task.state == .completed {
                    log.warning("Deleting Completed Task")
                    abstractHTMLTask = nil
                } else {
                    downloadingTaskType = DLItemType.AbstractHTML
                    return task
                }
            }
            if let task = abstractImagesTask {
                if task.state == .completed {
                    log.warning("Deleting Completed Task")
                    abstractHTMLTask = nil
                } else {
                    downloadingTaskType = DLItemType.AbstractImages
                    return task
                }
            }
            return nil
        }
    }
    
    var nextAbstractWithSupplementTask: URLSessionDownloadTask? {
        get {
            if let task = abstractHTMLTask {
                if task.state == .completed {
                    log.warning("Deleting Completed Task")
                    abstractHTMLTask = nil
                } else {
                    downloadingTaskType = DLItemType.AbstractHTML
                    return task
                }
            }
            if let task = abstractImagesTask {
                if task.state == .completed {
                    log.warning("Deleting Completed Task")
                    abstractHTMLTask = nil
                } else {
                    downloadingTaskType = DLItemType.AbstractImages
                    return task
                }
            }
            if let task = abstractMultimediaTask {
                if task.state == .completed {
                    log.warning("Deleting Completed Task")
                    abstractMultimediaTask = nil
                } else {
                    downloadingTaskType = DLItemType.AbstractSupplement
                    return task
                }
            }
            return nil
        }
    }
    
    var nextFullTextTask: URLSessionDownloadTask? {
        get {
            if let task = fullTextHTMLTask {
                if task.state == .completed {
                    log.warning("Deleting Completed Task")
                    fullTextHTMLTask = nil
                } else {
                    downloadingTaskType = DLItemType.FullTextHTML
                    return task
                }
            }
            if let task = fullTextImagesTask {
                if task.state == .completed {
                    log.warning("Deleting Completed Task")
                    fullTextImagesTask = nil
                } else {
                    downloadingTaskType = DLItemType.FullTextImages
                    return task
                }
            }
            return nil
        }
    }
    
    var nextFullTextWithSupplementTask: URLSessionDownloadTask? {
        get {
            if let task = fullTextHTMLTask {
                if task.state == .completed {
                    log.warning("Deleting Completed Task")
                    fullTextHTMLTask = nil
                } else {
                    downloadingTaskType = DLItemType.FullTextHTML
                    return task
                }
            }
            if let task = fullTextImagesTask {
                if task.state == .completed {
                    log.warning("Deleting Completed Task")
                    fullTextImagesTask = nil
                } else {
                    downloadingTaskType = DLItemType.FullTextImages
                    return task
                }
            }
            if let task = fullTextMultimediaTask {
                if task.state == .completed {
                    log.warning("Deleting Completed Task")
                    fullTextMultimediaTask = nil
                } else {
                    downloadingTaskType = DLItemType.FullTextSupplement
                    return task
                }
            }
            if let task = abstractMultimediaTask {
                if task.state == .completed {
                    log.warning("Deleting Completed Task")
                    abstractMultimediaTask = nil
                } else {
                    downloadingTaskType = DLItemType.AbstractSupplement
                    return task
                }
            }
            return nil
        }
    }
    
    // MARK: - Initializer -
    
    init(article: Article) {
        self.article = article
    }
    
    // MARK: - Resume -
    
    @discardableResult func resume(_ type: DMItemType) -> Bool {
        switch type {
        case .Abstract:
            if let task = nextAbstractTask {
                task.resume()
                if Strings.downloadLogsOn {
                    log.info("Download Task Started -- Article: \(article.articleInfoId), Task: \(type.rawValue)")
                }
                currentTask = task
                downloading = true
                return true
            }
            abstractDownload = false
            return false
        case .AbstractWithSupplement:
            if let task = nextAbstractWithSupplementTask {
                task.resume()
                if Strings.downloadLogsOn == true {
                    log.info("Download Task Started -- Article: \(article.articleInfoId), Task: \(type.rawValue)")
                }
                currentTask = task
                downloading = true
                return true
            }
            abstractDownload = false
            return false
        case .FullText:
            if let task = nextFullTextTask {
                task.resume()
                if Strings.downloadLogsOn == true {
                    log.info("Download Task Started -- Article: \(article.articleInfoId), Task: \(type.rawValue)")
                }
                currentTask = task
                downloading = true
                return true
            }
            fullTextDownload = false
            return false
        case .FullTextWithSupplement:
            if let task = nextFullTextWithSupplementTask {
                task.resume()
                if Strings.downloadLogsOn == true {
                    log.info("Download Task Started -- Article: \(article.articleInfoId), Task: \(type.rawValue)")
                }
                currentTask = task
                downloading = true
                return true
            }
            fullTextDownload = false
            return false
        case .All:
            if let task = nextTask {
                task.resume()
                if Strings.downloadLogsOn == true {

                    log.info("Download Task Started -- Article: \(article.articleInfoId), Task: \(type.rawValue)")
                }
                currentTask = task
                downloading = true
                return true
            }
            abstractDownload = false
            fullTextDownload = false
            return false
        }
    }
    
    func invalidate() {
        invalidateAll()
        currentTask?.cancel()
        currentTask = nil
        
        abstractMultimediaTask?.cancel()
        abstractMultimediaTask = nil
        
        fullTextHTMLTask?.cancel()
        fullTextHTMLTask = nil
        
        fullTextImagesTask?.cancel()
        fullTextImagesTask = nil
        
        fullTextMultimediaTask?.cancel()
        fullTextMultimediaTask = nil
    }
    
    func invalidateAll() {
        if article.downloadInfo.fullTextDownloadStatus == .downloading {
            DatabaseManager.SharedInstance.performChangesAndSave({
                self.article.downloadInfo.fullTextDownloadStatus = .notDownloaded
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.FullText.Failure), object: self.article, userInfo: nil)
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.FullText.Updated), object: self.article, userInfo: nil)
            })
            
        }
        if article.downloadInfo.fullTextHTMLDownloadStatus == .downloading {
            article.downloadInfo.fullTextHTMLDownloadStatus = .notDownloaded
        }
        if article.downloadInfo.fullTextImagesDownloadStatus == .downloading {
            article.downloadInfo.fullTextImagesDownloadStatus = .notDownloaded
        }
        if article.downloadInfo.fullTextSupplDownloadStatus == .downloading {
            article.downloadInfo.fullTextSupplDownloadStatus = .notDownloaded
        }
        if article.downloadInfo.fullTextDownloadStatus == .downloading {
            article.downloadInfo.fullTextDownloadStatus = .notDownloaded
        }
        if article.downloadInfo.abstractSupplDownloadStatus == .downloading {
            article.downloadInfo.abstractSupplDownloadStatus = .notDownloaded
        }
        if article.downloadInfo.fullTextDownloadStatus == .downloading {
            article.downloadInfo.fullTextDownloadStatus = .notDownloaded
            NotificationCenter.default.post(name: Foundation.Notification.Name.FullTextDownloadUpdated, object: article, userInfo: nil)
        }
    }
    func invalidateType(_ type: DLItemType) {
        invalidateAll()
        switch type {
        case .AbstractSupplement:
            abstractMultimediaTask?.cancel()
            abstractMultimediaTask = nil
            abstractSupplementExists = false
        case .FullText:
            fullTextHTMLTask?.cancel()
            fullTextHTMLTask = nil
            fullTextImagesTask?.cancel()
            fullTextImagesTask = nil
            fullTextExists = false
        case .FullTextSupplement:
            fullTextMultimediaTask?.cancel()
            fullTextMultimediaTask = nil
            fullTextSupplementExists = false
        default:
            break
        }
        if let section = self.section {
            if DMManager.sharedInstance.currentSection === section {
                section.resume()
            }
        }
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.DMSection.Updated), object: self.section)
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Issue.UpdateCount), object: nil)
        
        //  Check if item.article has OA status.

        if article.openAccess.oaIdentifier != 0 {
            
            //  Begin process that will change status on OA spinner according to existing logic there.
            

            /*if article.downloadInfo.fullTextDownloadStatus == .downloading {
                article.downloadInfo.fullTextDownloadStatus = .notDownloaded
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Article.Finished), object: nil, userInfo: ["article": article])
            }
        } else if article.isAIP {
            
            if article.downloadInfo.fullTextDownloadStatus == .downloading {
                article.downloadInfo.fullTextDownloadStatus = .notDownloaded
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.AIP.Completed), object: nil, userInfo: ["article": article])*/

            if article.downloadInfo.fullTextDownloadStatus == .downloading {
                DatabaseManager.SharedInstance.performChangesAndSave({ 
                    self.article.downloadInfo.fullTextDownloadStatus = .notDownloaded
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Article.Finished), object: self.article, userInfo: ["article": self.article])
                })
                
            }
        } else if article.isAIP {
            
            if article.downloadInfo.fullTextDownloadStatus == .downloading {
                DatabaseManager.SharedInstance.performChangesAndSave({ 
                    self.article.downloadInfo.fullTextDownloadStatus = .notDownloaded
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.AIP.Completed), object: self.article, userInfo: ["article": self.article])
                })
            }
        }
    }
    
    // MARK: - Create Abstract -
    
    func createAbstractTasksWithSupplement(_ supplement: Bool) {
        abstractDownload = true
        createAbstractTasks(nil)
        if supplement {
            createAbstractSupplementTasks()
        }
    }
    
    func createAbstractTasksWithSupplement(_ supplement: Bool, session: URLSession) {
        abstractDownload = true
        createAbstractTasks(session)
        if supplement {
            createAbstractSupplementTasks()
        }
    }
    
    fileprivate func createAbstractTasks(_ session: URLSession?) {
        var tasksAdded = false
        if abstractHTMLTask == .none {
            if article.downloadInfo.abstractHTMLDownloadStatus != .downloaded && article.downloadInfo.abstractHTMLDownloadStatus != .notAvailable {
                if let request = JBSMURLRequest.V2.AbstractHTMLRequest(article: article) {
                    DatabaseManager.SharedInstance.performChangesAndSave({
                        self.article.downloadInfo.abstractHTMLDownloadStatus = .downloading
                    })
                    if let _session = session {
                        abstractHTMLTask = _session.downloadTask(with: request)
                    } else {
                        abstractHTMLTask = DMManager.session.downloadTask(with: request)
                    }
                    tasksAdded = true
                }
            }
        }
        if article.hasAbstractImages == true {
            if abstractImagesTask == .none {
                if article.downloadInfo.abstractImagesDownloadStatus != .downloaded && article.downloadInfo.abstractImagesDownloadStatus != .notAvailable {
                    if let request = JBSMURLRequest.V2.AbstractImagesRequest(article: article) {
                        DatabaseManager.SharedInstance.performChangesAndSave({
                            self.article.downloadInfo.abstractImagesDownloadStatus = .downloading
                        })
                        if let _session = session {
                            abstractImagesTask = _session.downloadTask(with: request)
                        } else {
                            abstractImagesTask = DMManager.session.downloadTask(with: request)
                        }
                        tasksAdded = true
                    }
                }
            }
        }
        if tasksAdded {
            performOnMainThread({ 
                NotificationCenter.default.post(name: Foundation.Notification.Name.AbstractDownloadUpdated, object: self.article)
            })
        }
    }
    
    fileprivate func createAbstractSupplementTasks() {
        if abstractMultimediaTask == .none {
            if article.downloadInfo.abstractSupplDownloadStatus != .downloaded && article.downloadInfo.abstractSupplDownloadStatus != .notAvailable {
                if let request = JBSMURLRequest.V2.AbstractSupplementRequest(article: article) {
                    DatabaseManager.SharedInstance.performChangesAndSave({
                        self.article.downloadInfo.abstractSupplDownloadStatus = .downloading
                    })
                    abstractMultimediaTask = DMManager.session.downloadTask(with: request)
                    performOnMainThread({ 
                        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.AbstractSupplement.started), object: self.article)
                    })
                    abstractSupplementExists = true
                }
            }
        }
    }
    
    // MARK: - Create FullText -
    
    func createFullTextTaks(_ fullText: Bool, withSupplement supplement: Bool) {
        fullTextDownload = true
        if fullText == true {
            createFullTextTasks()
        }
        if supplement == true {
            createFullTextSupplementTasks()
            createAbstractSupplementTasks()
        }
    }
    
    func createFullTextTasksWithSupplement(_ supplement: Bool) {
        fullTextDownload = true
        createFullTextTasks()
        if supplement == true {
            createFullTextSupplementTasks()
            createAbstractSupplementTasks()
        }
    }
    
    @discardableResult func createFullTextTasks(_ session: URLSession? = nil) -> Bool {
        var tasksAdded = false
        if fullTextHTMLTask == .none {
            if article.downloadInfo.fullTextHTMLDownloadStatus != .downloaded && article.downloadInfo.fullTextHTMLDownloadStatus != .notAvailable {
                DatabaseManager.SharedInstance.performChangesAndSave({
                    self.article.downloadInfo.fullTextHTMLDownloadStatus = .downloading
                })
                var added = false
                if let _session = session {
                    if let request = JBSMURLRequest.V2.FullTextHTMLRequest(article: article) {
                        fullTextHTMLTask = _session.downloadTask(with: request)
                        added = true
                    }
                } else {
                    if let request = JBSMURLRequest.V2.FullTextHTMLRequest(article: article) {
                        fullTextHTMLTask = DMManager.session.downloadTask(with: request)
                        added = true
                    }
                }
                tasksAdded = added
            }
        }
        if fullTextImagesTask == .none {
            switch article.downloadInfo.fullTextImagesDownloadStatus {
            case .notDownloaded, .downloadFailed:
                DatabaseManager.SharedInstance.performChangesAndSave({
                    self.article.downloadInfo.fullTextImagesDownloadStatus = .downloading
                })
                var added = false
                if let _session = session {
                    if let request = JBSMURLRequest.V2.FullTextImagesRequest(article: article) {
                        fullTextImagesTask = _session.downloadTask(with: request)
                        added = true
                    }
                } else {
                    if let request = JBSMURLRequest.V2.FullTextImagesRequest(article: article) {
                        fullTextImagesTask = DMManager.session.downloadTask(with: request)
                        added = true
                    }
                }
                tasksAdded = added
            default:
                break
            }
        }
        if tasksAdded == true {
            performOnMainThread {
                NotificationCenter.default.post( name: Foundation.NSNotification.Name.FullTextDownloadUpdated, object: self.article)
            }
        }
        fullTextExists = tasksAdded
        return tasksAdded
    }
    
    @discardableResult func createFullTextSupplementTasks() -> Bool {
        
        var added = false
        
        if fullTextMultimediaTask == .none {
            
            if article.downloadInfo.fullTextSupplDownloadStatus != .downloaded && article.downloadInfo.fullTextSupplDownloadStatus != .notAvailable {
                if let request = JBSMURLRequest.V2.FullTextSupplementRequest(article: article) {
                    DatabaseManager.SharedInstance.performChangesAndSave({
                        self.article.downloadInfo.fullTextSupplDownloadStatus = .downloading
                    })
                    fullTextMultimediaTask = DMManager.session.downloadTask(with: request)
                    performOnMainThread {
                        NotificationCenter.default.post(
                            name: Foundation.Notification.Name.FullTextSupplementDownloadUpdated, object: self.article)
                    }
                    fullTextSupplementExists = true
                    added = true
                }
            }
            
            if article.downloadInfo.abstractSupplDownloadStatus != .downloaded && article.downloadInfo.abstractSupplDownloadStatus != .notAvailable {
                if let request = JBSMURLRequest.V2.AbstractSupplementRequest(article: article) {
                    DatabaseManager.SharedInstance.performChangesAndSave({
                        self.article.downloadInfo.abstractSupplDownloadStatus = .downloading
                    })
                    abstractMultimediaTask = DMManager.session.downloadTask(with: request)
                    performOnMainThread {
                        NotificationCenter.default.post(
                            name: Foundation.Notification.Name(rawValue: Notification.Download.AbstractSupplement.started), object: self.article)
                    }
                    abstractSupplementExists = true
                    added = true
                }
            }
        }
        
        return added
    }
    
    func createTaskForType(type: DLItemType, withRequest request: Foundation.URLRequest) {
        DatabaseManager.SharedInstance.performChangesAndSave { 
            self.article.downloadInfo.update(downloadType: type, withStatus: .downloading)
            self.setTask(DMManager.session.downloadTask(with: request), forType: type)
        }
    }
    
    fileprivate func setTask(_ task: URLSessionDownloadTask?, forType type: DLItemType) {
        switch type {
        case .AbstractHTML:
            abstractHTMLTask = task
        case .AbstractImages:
            abstractImagesTask = task
        case .AbstractSupplement:
            abstractMultimediaTask = task
        case .FullTextHTML:
            fullTextHTMLTask = task
        case .FullTextImages:
            fullTextImagesTask = task
        case .FullTextSupplement:
            fullTextMultimediaTask = task
        default:
            break
        }
    }
    
    // MARK: - Methods -
    
    func downloadUpdatedForType(_ type: DLItemType, completed: Int, total: Int) {
        switch type {
        case .AbstractHTML:
            abstractHTMLTaskCompleted = completed
            abstractHTMLTaskTotal = total
        case .AbstractImages:
            abstractImagesTaskCompleted = completed
            abstractImagesTaskTotal = total
        case .AbstractSupplement:
            abstractSupplementTaskCompleted = completed
            abstractSupplementTaskTotal = total
        case .FullTextHTML:
            fullTextHTMLTaskCompleted = completed
            fullTextHTMLTaskTotal = total
        case .FullTextImages:
            fullTextImagesTaskCompleted = completed
            fullTextImagesTaskTotal = total
        case .FullTextSupplement:
            fullTextSupplementTaskCompleted = completed
            fullTextSupplementTaskTotal = total
        default:
            break
        }
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.DMItem.Updated), object: self)
    }
    
    func downloadCompletedForType(_ type: DLItemType) {
        
        switch type {
        case .AbstractHTML:
            abstractHTMLTask = nil
        case .AbstractImages:
            abstractImagesTask = nil
        case .AbstractSupplement:
            abstractMultimediaTask = nil
        case .FullTextHTML:
            fullTextHTMLTask = nil
        case .FullTextImages:
            fullTextImagesTask = nil
        case .FullTextSupplement:
            fullTextMultimediaTask = nil
        default:
            break
        }
        
        if fullTextExists == true {
            if fullTextHTMLTask == nil && fullTextImagesTask == nil {
                fullTextDownloaded = true
            }
        }
        
        if fullTextSupplementExists == true {
            if fullTextMultimediaTask == nil {
                fullTextSupplementDownloaded = true
            }
        }
        
        if abstractSupplementExists == true {
            if abstractMultimediaTask == nil {
                abstractsupplementDownloaded = true
            }
        }
        
        switch type {
        case .AbstractHTML, .AbstractImages:
            if article.downloadInfo.abstractDownloadStatus == .downloaded {
                NotificationCenter.default.post(name: Foundation.Notification.Name.AbstractDownloadUpdated, object: article)
            }
        case .AbstractSupplement:
            if article.downloadInfo.abstractSupplDownloadStatus == .downloaded {
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.AbstractSupplement.Successful), object: article)
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Issue.UpdateCount), object: article.issue)
            }
        case .FullTextHTML, .FullTextImages:
            if article.downloadInfo.fullTextDownloadStatus == .downloaded {
                NotificationCenter.default.post(name: Foundation.Notification.Name.FullTextDownloadUpdated, object: article)
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Issue.UpdateCount), object: article.issue)
            }
        case .FullTextSupplement:
            if article.downloadInfo.fullTextSupplDownloadStatus == .downloaded {
                NotificationCenter.default.post(name: Foundation.Notification.Name.FullTextSupplementDownloadUpdated, object: article)
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Issue.UpdateCount), object: article.issue)
            }
        default:
            break
        }
        currentTask = nil
        downloadingTaskType = nil
        downloading = false
    }
    
    func regenerateTask(type: DLItemType) {
        switch type {
        case .AbstractHTML:
            abstractHTMLTask = nil
            abstractHTMLTaskCompleted = 0
            abstractHTMLTaskTotal = 0
            createAbstractTasks(nil)
        case .AbstractImages:
            abstractImagesTask = nil
            abstractImagesTaskCompleted = 0
            abstractImagesTaskTotal = 0
            createAbstractTasks(nil)
        case .AbstractSupplement:
            abstractMultimediaTask = nil
            abstractSupplementTaskCompleted = 0
            abstractSupplementTaskTotal = 0
            createAbstractTasksWithSupplement(true)
        case .FullTextHTML:
            fullTextHTMLTask = nil
            fullTextHTMLTaskCompleted = 0
            fullTextHTMLTaskTotal = 0
            createFullTextTasksWithSupplement(false)
        case .FullTextImages:
            fullTextImagesTask = nil
            fullTextImagesTaskCompleted = 0
            fullTextImagesTaskTotal = 0
            createFullTextTasksWithSupplement(false)
        case .FullTextSupplement:
            fullTextMultimediaTask = nil
            fullTextSupplementTaskCompleted = 0
            fullTextSupplementTaskTotal = 0
            createFullTextTasksWithSupplement(true)
        default:
            break
        }
    }
    
    // MARK: - V2 -
}
