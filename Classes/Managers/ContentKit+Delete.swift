//
//  ContentKit+Delete.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/31/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

extension ContentKit {
    
    // MARK: JOURNAL
    
    func deleteJournal(_ journal: Journal, onlyMultimedia multimedia: Bool, completion:(_ success: Bool)->()) {
        let articles = DatabaseManager.SharedInstance.getAllArticlesforJournal(journal)
        for article in articles {
            deleteArticle(article, onlyMultimedia: multimedia)
        }
        completion(true)
    }
    
    func deleteJournalAIPs(_ journal: Journal, onlyMultimedia multimedia: Bool, completion:(_ success: Bool)->()) {
        let articles = DatabaseManager.SharedInstance.getAips(journal: journal)
        for article in articles {
            deleteArticle(article, onlyMultimedia: multimedia)
        }
        completion(true)
    }
    
    func deleteJournalIssues(_ journal: Journal, onlyMultimedia multimedia: Bool, completion:(_ success: Bool)->()) {
        let articles = DatabaseManager.SharedInstance.getNonAIPArticlesForJournal(journal)
        for article in articles {
            deleteArticle(article, onlyMultimedia: multimedia)
        }
        completion(true)
    }
    
    // MARK: ISSUE
    
    func downloadIssue(_ issue: Issue, supplement: Bool, staringWithArticle article: Article) {
        DMManager.sharedInstance.downloadIssue(issue, withSupplement: supplement, startingWith: article)
    }
    
    func deleteIssue(_ issue: Issue, onlyMultimedia multimedia: Bool, completion:(_ success: Bool)->()) {
        for article in issue.allArticles {
            deleteArticle(article, onlyMultimedia: multimedia)
        }
        
        completion(true)
    }
    
    // MARK: ARTICLE
    
    @discardableResult func deleteArticle(_ article: Article, onlyMultimedia multimedia: Bool) -> Article {
        
        guard article.canDeleteArticle else { return article }
        
        if multimedia == true {
            deleteAbstractSupplement(article: article)
            deleteFullTextSupplement(article: article)
        } else {
            deleteAbstractSupplement(article: article)
            deleteFullText(article: article)
        }
        
        DatabaseManager.SharedInstance.save()
        return article
    }
    
    // MARK: ABSTRACT SUPPLEMENT
    
    private func deleteAbstractSupplement(article: Article) {
        if article.downloadInfo.abstractSupplDownloadStatus != .notAvailable {
            if FileSystemManager.sharedInstance.deleteAbstractMultimedia(article) {
                article.downloadInfo.abstractSupplDownloadStatus = .notDownloaded
                
                for media in article.allMedia where media.articleType == .abstract {
                    if media.downloadStatus != .notAvailable {
                        media.downloadStatus = .notDownloaded
                    }
                }
            }
        }
    }
    
    // MARK: ARTICLE FULLTEXT
    
    private func deleteFullText(article: Article) {
        guard article.starred == false else { return }
        guard article.allNotes.count == 0 else { return }
        deleteFullTextSupplement(article: article)
        if article.downloadInfo.fullTextDownloadStatus != .notAvailable {
            if FileSystemManager.sharedInstance.deleteArticle(article) {
                article.downloadInfo.fullTextDownloadStatus = .notDownloaded
            }
        }
        article.ipAuthentication = nil
    }
    
    // MARK: ARTICLE SUPPLEMENT
    
    private func deleteFullTextSupplement(article: Article) {
        if article.downloadInfo.fullTextSupplDownloadStatus != .notAvailable {
            if FileSystemManager.sharedInstance.deleteArticleMultimedia(article) {
                article.downloadInfo.fullTextSupplDownloadStatus = .notDownloaded
                
                for media in article.allMedia where media.articleType == .fullText {
                    if media.downloadStatus != .notAvailable {
                        media.downloadStatus = .notDownloaded
                    }
                }
            }
        }
    }
}
