//
//  Article_Helpers.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 8/5/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

extension Article {
    
    static func getFetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }
    
    var userHasAccess: Bool {
        
        if OVERRIDE_LOGIN { return true  }
        if journal.userHasAccess { return true }
        if let dateOfRelease = self.dateOfRelease {
            if IPInfo.Instance.isDate(dateOfRelease, validForISSN: journal.issn) { return true }
        }
        if let issue = self.issue {
            if issue.userHasAccess { return true }
        }
        if isArticleOpenAccessOrArchive { return true }
        return false
    }
    
    var isArticleOpenAccessOrArchive: Bool {
        if isArticleOpenAccess || isArticleOpenArchive { return true }
        return false
    }
    
    var isArticleOpenAccess: Bool {
        switch openAccess.type {
        case .openAccess, .openAccessFundedBy, .openAccessFundedByIssue, .openAccessSinceWithOpenArchive:
            return true
        default:
            return false
        }
    }
    
    var isArticleOpenArchive: Bool {
        switch openAccess.type {
        case .openArchive, .openAccessSinceWithOpenArchive:
            return true
        default:
            return false
        }
    }
    
    var isArticleOnlyOpenAccess: Bool {
        if journal.isJournalOpenAccess { return false }
        if let issue = self.issue {
            if issue.isIssueOpenAccess { return false }
        }
        return isArticleOpenAccess
    }
}

// MARK: - Supplement -

extension Article {
    
    var countOfUndownloadedSupplementFiles: (abs: Int, full: Int) {
        
        var absCount = 0
        var fullCount = 0
        
        for media in allMedia {
            if media.downloadStatus != .downloaded {
                switch media.fileType {
                case .Audio, .Video, .Document, .Presentation, .Spreadsheet, .PDF, .Other:
                    switch media.articleType {
                    case .abstract:
                        absCount += 1
                    case .fullText:
                        fullCount += 1
                    }
                default: break
                }
            }
        }

        return (absCount, fullCount)
    }
}

// MARK: - Download Info -

extension Article {
    
    var fullTextDownloadStatus: DownloadStatus {
        return downloadInfo.fullTextDownloadStatus
    }
    
    var fullTextDownloaded: Bool {
        switch fullTextDownloadStatus {
        case .downloaded:
            return true
        default:
            return false
        }
    }
    
}
