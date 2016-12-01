//
//  PushNotificationDownloadManager.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 4/12/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import ZipArchive

class PushNotificationDownloadManager: NSObject, URLSessionDownloadDelegate {
    
    static let SharedInstance = PushNotificationDownloadManager()
    
    static let DownloadIdentifier = "com.elsevier.jbsm." + Strings.AppShortCode
    
    var session: Foundation.URLSession!
    
    var journal: Journal?
    var issue: Issue?
    var articles: [Article] = []
    
    var sections: [DMSection] = []
    var currentSection: DMSection?
    
    var bgTask: UIBackgroundTaskIdentifier?
    
    func endBackgroundUpdateTask() {
        UIApplication.shared.endBackgroundTask(bgTask!)
        bgTask = UIBackgroundTaskInvalid
    }
    
    override init() {
        super.init()
        self.session = Foundation.URLSession(configuration: URLSessionConfiguration.background(withIdentifier: PushNotificationDownloadManager.DownloadIdentifier), delegate: self, delegateQueue: nil)
    }
    
    func requestingNewIssueIfAvailable(_ journalId: String, completionHandler: ((UIBackgroundFetchResult)->Void)?) {
        self.bgTask = UIApplication.shared.beginBackgroundTask (expirationHandler: {
            self.endBackgroundUpdateTask()
        })
        let journal = DatabaseManager.SharedInstance.getJournal(issn: journalId)
        self.journal = journal
        completionHandler?(UIBackgroundFetchResult.newData)
        checkForNewIssue { (newIssue) in
            if newIssue {
                completionHandler?(UIBackgroundFetchResult.newData)
            } else {
                completionHandler?(UIBackgroundFetchResult.noData)
            }
        }
    }
    
    func checkForNewIssue(_ completion:(_ newIssue: Bool)->Void) {
        guard let journal = self.journal else {
            return
        }
        ContentKit.SharedInstance.updateNewIssues(journal: journal) { (newIssue) in
            if let issue = newIssue {
                ContentKit.SharedInstance.updateArticles(issue: issue, completion: { success in
                    if success == true {
                        self.articles = DatabaseManager.SharedInstance.getAllArticlesForIssue(issue)
                        DMManager.sharedInstance.downloadAbstracts(issue: issue)
                        if issue.userHasAccess {
                            DMManager.sharedInstance.downloadIssue(issue, withSupplement: false, startingWith: nil)
                        }
                    }
                })
            } else {
                //completion(newIssue: false)
            }
        }
    }
    
    func downloadAbstractsforIssue(_ issue: Issue) {
        let section = DMSection(issue: issue, type: DMSectionType.issue)
        for article in articles {
            let item = DMItem(article: article)
            section.normalItems.append(item)
            item.createAbstractTasksWithSupplement(false, session: session)
        }
        sections.append(section)
        resume()
    }
    
    func downloadFullTextForIssue(_ issue: Issue) {
        let section = DMSection(issue: issue, type: DMSectionType.issue)
        for article in articles {
            
            let item: DMItem = DMItem(article: article)
            if item.fulltextAuthentication == .none {
                //item.fulltextAuthentication = _authentication
            }
            item.createFullTextTasks(session)
            section.normalItems.append(item)
        }
        sections.append(section)
        resume()
    }
    
    func resume() {
        DispatchQueue.main.async {
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
                let localNotification = UILocalNotification()
                localNotification.alertAction = "Download Completed"
                localNotification.fireDate = Date(timeIntervalSinceNow: 5)
                UIApplication.shared.scheduleLocalNotification(localNotification)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let section = currentSection           else { return }
        guard let item    = section.currentItem      else { return }
        guard let type    = item.downloadingTaskType else { return }
              let article = item.article
        
        var destinationPath: String
        
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
            return
        }
        
        var status: DownloadStatus?
        
        do {
            try SSZipArchive.unzipFile(atPath: location.path, toDestination: destinationPath, overwrite: true, password: nil)
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
                if FileSystemManager.sharedInstance.pathExists(htmlAssetsPath) {
                    try FileManager.default.removeItem(atPath: htmlAssetsPath)
                }
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
                if FileSystemManager.sharedInstance.pathExists(htmlAssetsPath) {
                    try FileManager.default.removeItem(atPath: htmlAssetsPath)
                }
                try FileManager.default.moveItem(atPath: assetsImagePath, toPath: htmlAssetsPath)
                try FileManager.default.removeItem(atPath: article.fulltextImagesBasePath)
            } catch let error as NSError {
                log.error(error.localizedDescription)
            }
        default:
            break
        }
        
        DatabaseManager.SharedInstance.performChangesAndSave {
            guard let _status = status else { return }
            article.downloadInfo.update(downloadType: type, withStatus: _status)
            section.downloadCompletedForItem(item, withType: type)
            self.resume()
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        log.error(error?.localizedDescription)
    }
    
}
