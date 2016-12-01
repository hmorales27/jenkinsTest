//
//  ArticleDownloadManager.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 11/10/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit
import SSZipArchive

public let ckFullTextArticleDownloadedNotification     = "ckFullTextArticleDownloadedNotification"
public let ckAbstractArticleDownloadedNotification     = "ckAbstractArticleDownloadedNotification"
public let ckSupplementalArticleDownloadedNotification = "ckSupplementalArticleDownloadedNotification"

enum APIArticleDownloaderType {
    case FullText
    case Supplemental
    case Abstract
}

class APIArticleDownloaderItem {
    weak var task: NSURLSessionDownloadTask?
    let article: Article
    let type: APIArticleDownloaderType
    
    init(downloadTask:NSURLSessionDownloadTask, article:Article, type:APIArticleDownloaderType) {
        self.task = downloadTask
        self.article = article
        self.type = type
    }
}

class JBSMURLRequest {
    
    class func ArticleFullTextRequest(article:Article) -> NSURLRequest? {
        guard let journal = article.journal, let articleInfoId = article.articleInfoId else {
            return nil
        }
        let urlString = journal.baseContentURL45! + articleInfoId + ".zip"
        guard let url = NSURL(string: urlString) else {
            return nil
        }
        let request = NSURLRequest(URL: url)
        return request
    }

    class func ArticleSupplementRequest(article:Article) -> NSURLRequest? {
        guard let journal = article.journal, let articleInfoId = article.articleInfoId else {
            return nil
        }
        let urlString = journal.baseContentURL45! + articleInfoId + "_suppl.zip"
        guard let url = NSURL(string: urlString) else {
            return nil
        }
        let request = NSURLRequest(URL: url)
        return request
    }

    class func ArticleAbstractRequest(article:Article) -> NSURLRequest? {
        guard let journal = article.journal, let articleInfoId = article.articleInfoId else {
            return nil
        }
        let urlString = journal.baseContentURL45! + articleInfoId + "_abs.zip"
        guard let url = NSURL(string: urlString) else {
            return nil
        }
        let request = NSURLRequest(URL: url)
        return request
    }
}

class IssueItem {
    var articles:[APIArticleDownloaderItem] = []
    let issue: Issue
    
    init(issue:Issue) {
        self.issue = issue
    }
    
    func addArticleItem(item:APIArticleDownloaderItem) {
        articles.append(item)
    }
}

class ArticleDownloadManager {

    static let SharedInstance = ArticleDownloadManager()
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    // MARK: - Initializers -
    
    init() {
        
    }
    
    // MARK: - Adding Articles -
    
    func addArticle(article:Article, forDownloadType type:APIArticleDownloaderType) {
        switch type {
        case .FullText:
            downloadFullTextForArticle(article)
        case .Supplemental:
            downloadSupplementalForArticle(article)
        case .Abstract:
            downloadAbstractForArticle(article)
        }
    }
    
    func addArticle(article:Article, forDownloadType type:APIArticleDownloaderType, priority:Float) {
        switch type {
        case .FullText:
            downloadFullTextForArticle(article, priority: priority)
        case .Supplemental:
            downloadSupplementalForArticle(article, priority: priority)
        case .Abstract:
            downloadAbstractForArticle(article, priority: priority)
        }
    }
    
    // MARK: - Full Text -
    
    func downloadFullTextForArticle(article:Article) {
        downloadFullTextForArticle(article, priority: NSURLSessionTaskPriorityDefault)
    }
    
    func downloadFullTextForArticle(article:Article, priority:Float) {
        guard let request = JBSMURLRequest.ArticleFullTextRequest(article) else {
            return
        }
        let task = session.downloadTaskWithRequest(request) { (responseURL, response, responseError) -> Void in
            if let error = responseError {
                print(error.localizedDescription)
                return
            }
            if let url = responseURL {
                do {
                    try SSZipArchive.unzipFileAtPath(url.path!, toDestination: article.fulltextBasePath, overwrite: true, password: nil)
                } catch let error as NSError {
                    log.error(error.localizedDescription)
                }
            }
        }
        task.priority = priority
        task.resume()
    }
    
    // MARK: - Abstract -
    
    func downloadAbstractForArticle(article:Article) {
        downloadAbstractForArticle(article, priority: NSURLSessionTaskPriorityDefault)
    }
    
    func downloadAbstractForArticle(article:Article, priority:Float) {
        guard let request = JBSMURLRequest.ArticleAbstractRequest(article) else {
            return
        }
        let task = session.downloadTaskWithRequest(request) { (responseURL, response, responseError) -> Void in
            if let error = responseError {
                print(error.localizedDescription)
                return
            }
            if let url = responseURL {
                do {
                    try SSZipArchive.unzipFileAtPath(url.path!, toDestination: article.abstractBasePath, overwrite: true, password: nil)
                } catch let error as NSError {
                    log.error(error.localizedDescription)
                }
            }
        }
        task.priority = priority
        task.resume()
    }
    
    // MARK: - Supplement -
    
    func downloadSupplementalForArticle(article: Article) {
        downloadSupplementalForArticle(article, priority: NSURLSessionTaskPriorityDefault)
    }
    
    func downloadSupplementalForArticle(article: Article, priority:Float) {
        guard let request = JBSMURLRequest.ArticleSupplementRequest(article) else {
            return
        }
        let task = session.downloadTaskWithRequest(request) { (responseURL, response, responseError) -> Void in
            if let error = responseError {
                print(error.localizedDescription)
                return
            }
            if let url = responseURL {
                do {
                    try SSZipArchive.unzipFileAtPath(url.path!, toDestination: article.fulltextBasePath, overwrite: true, password: nil)
                } catch let error as NSError {
                    log.error(error.localizedDescription)
                }
            }
        }
        task.priority = priority
        task.resume()
    }
}
