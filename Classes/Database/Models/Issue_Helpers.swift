//
//  Issue_Helpers.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 8/4/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Section Data Protocol -

extension Issue: SectionDataProtocol {
    
    func openArchive() -> Bool {
        if openAccess.oaIdentifier.intValue == OAIdentifier.openArchive.rawValue {
            return true
        }
        return false
    }
    
    func sectionKey() -> String {
        let dateFormatter = DateFormatter(dateFormat: "YYYY")
        return dateFormatter.string(from: dateOfRelease!)
    }
    
    func sectionColor() -> UIColor? {
        return nil
    }
    
    func downloadable() -> Bool {
        return true
    }
    
    func downloaded() -> Bool {
        guard allArticles.count > 0 else { return false }
        if allArticles.count > 0 {
            for article in allArticles {
                if article.downloadInfo.fullTextDownloadStatus == .downloaded {
                    return true
                }
            }
        }
        return false
    }
}

// MARK: - Collection Item Protocol -

extension Issue: CollectionItemProtocol {
    
    var itemSequence: String {
        guard let dateOfRelease = self.dateOfRelease else { return "" }
        let dateFormatter = DateFormatter(dateFormat: "YYYY")
        return dateFormatter.string(from: dateOfRelease)
    }
    
    var itemType: String {
        return "Issue"
    }
    
    var itemHasNotes: Bool {
        return false
    }
    var itemIsBookmarked: Bool {
        return false
    }
    var itemIsOA: Bool {
        return isIssueOpenArchive
    }
    var itemIsDownloaded: Bool {
        return downloaded()
    }
    
    var itemOrderNumber: Int {
        guard let dateOfRelease = self.dateOfRelease else { return 0 }
        return Int(dateOfRelease.timeIntervalSince1970)
    }
}

// MARK: - Issue Access -

extension Issue {
    
    var hasAccess: Bool {
        return userHasAccess
    }
    
    var userHasAccess: Bool {
        if OVERRIDE_LOGIN             { return true }
        if journal.userHasAccess      { return true }
        if isIPAuthenticated          { return true }
        if isIssueFree                { return true }
        if isPurchased                { return true }
        if isIssueOpenAccessOrArchive { return true }
        if isIssuePurchased           { return true }
        return false
    }
    
    // MARK: FREE
    
    var isIssueFree: Bool {
        return Bool(isFreeIssue)
    }
    
    var coverImageShouldShowFreeLabel: Bool {
        guard isIssueFree || journal.isJournalFree else { return false }
        if isIssueOpenAccessOrArchive || journal.isJournalOpenAccessOrArchive { return false }
        return true
    }
    
    // MARK: IP AUTH
    
    var isIPAuthenticated: Bool {
        return IPInfo.Instance.isDate(dateOfRelease, validForISSN: journal.issn)
    }
    
    // MARK: PURCHASED
    
    var isPurchased: Bool {
        guard let subscriptionId = productId else { return false }
        return MKStoreManager.shared().isSubscriptionActive(subscriptionId)
    }
    
    // MARK: OPEN ACCESS
    
    var shouldShowOpenAccessLabel: Bool {
        guard !journal.isJournalOpenAccessOrArchive else { return false }
        guard isIssueOpenAccessOrArchive            else { return false }
        return true
    }
    
    var isIssueOpenAccessOrArchive: Bool {
        if isIssueOpenAccess || isIssueOpenArchive { return true }
        return false
    }
    
    var isIssueOpenAccess: Bool {
        switch openAccess.type {
        case .openAccess, .openAccessFundedBy, .openAccessFundedByIssue, .openAccessSinceWithOpenArchive:
            return true
        default:
            return false
        }
    }
    
    var isIssueOpenArchive: Bool {
        switch openAccess.type {
        case .openArchive, .openAccessSinceWithOpenArchive:
            return true
        default:
            return false
        }
    }
    
    var isIssuePurchased: Bool {
        guard let featureId = self.productId else {
            return false
        }
        return MKStoreManager.isFeaturePurchased(featureId)
    }
}

// MARK: - Articles -

extension Issue {
    
    // MARK: GENERAL
    
    var allArticles: [Article] {
        return DatabaseManager.SharedInstance.getAllArticlesForIssue(self)
    }
    
    var hasArticles: Bool {
        guard allArticlesCount > 0 else { return false }
        return true
    }
    
    var allArticlesCount: Int {
        return DatabaseManager.SharedInstance.getArticlesCountForIssue(self)
    }
    
    func allFullTextDownloaded() -> Bool {
        guard hasArticles else { return false }
        for article in allArticles {
            if article.downloadInfo.fullTextDownloadStatus != .downloaded { return false }
        }
        return true
    }
    
    // MARK: ABSTRACT
    
    var abstractSupplementTotalCount: Int {
        return DatabaseManager.SharedInstance.getAbstractSupplementTotalCount(issue: self)
    }
    
    var abstractSupplementDownloadedCount: Int {
        return DatabaseManager.SharedInstance.getAbstractSupplementDownloadedCount(issue: self)
    }
    
    var abstractSupplementDownloadedSize: Int {
        var downloadSize = 0
        for article in allArticles {
            if article.downloadInfo.abstractSupplDownloadStatus == .downloaded {
                downloadSize += Int(article.downloadInfo.abstractSupplFileSize)
            } else {
                for media in article.allMedia where media.articleType == .abstract {
                    if media.downloadStatus == .downloaded {
                        downloadSize += Int(media.fileSize)
                    }
                }
            }
        }
        return downloadSize
    }
    
    // MARK: ISSUE
    
    var sizeForDownloadedContent: Int {
        return DatabaseManager.SharedInstance.getDownloadedSizeForArticlesInIssue(self)
    }
    
    var sizeForRemainingContent: Int {
        var size = 0
        for article in allArticles { size += article.entireArticleRemainingSize }
        return size
    }
    
    var sizeForDownloadedFullTextContent: Int {
        var size = 0
        for article in allArticles { size += article.fullTextDownloadedSize }
        return size
    }
    
    var sizeForRemainingFullTextContent: Int {
        var size = 0
        for article in allArticles { size += article.fullTextRemainingSize }
        return size
    }
    
    var sizeForDownloadedSupplementContent: Int {
        return DatabaseManager.SharedInstance.getDownloadedSupplementSizeForArticlesInIssue(self)
    }
    
    var sizeForRemainingSupplementContent: Int {
        var size = 0
        for article in allArticles { size += article.abstractAndFullTextSupplementRemainingSize }
        return size
    }
    
    var countOfArticlesWithAbstractSupplement: Int {
        return DatabaseManager.SharedInstance.getCountOfArticlesWithAbstractSupplementalContentForIssue(self)
    }
    
    var countOfArticles: Int {
        return DatabaseManager.SharedInstance.getCountOfArticlesWithFullTextContentForIssue(self)
    }
    
    var countOfArticlesWithFullTextSupplement: Int {
        return DatabaseManager.SharedInstance.getCountOfArticlesWithFullTextSupplementContentForIssue(self)
    }
    
    var fullTextTotalCount: Int {
        return DatabaseManager.SharedInstance.getArticlesCountForIssue(self)
    }
    
    var fullTextArticles: [Article] {
        return DatabaseManager.SharedInstance.getAllArticlesForIssue(self)
    }
    
    var fullTextDownloadedCount: Int {
        return DatabaseManager.SharedInstance.getFullTextArticlesDownloadedCount(issue: self)
    }
    
    var fullTextDownloadedSize: Int {
        var downloadSize = 0
        for article in DatabaseManager.SharedInstance.getDownloadedArticles(issue: self) {
            if article.downloadInfo.fullTextDownloadStatus == .downloaded {
                downloadSize += Int(article.downloadInfo.fullTextFileSize)
            }
        }
        return downloadSize
    }
    
    var fullTextDownloadedArticles: [Article] {
        return DatabaseManager.SharedInstance.getFullTextDownloadedArticles(issue: self)
    }
    
    var fullTextSupplementTotalCount: Int {
        return DatabaseManager.SharedInstance.getFullTextSupplementTotalCount(issue: self)
    }
    
    var fullTextSupplementDownloadedCount: Int {
        return DatabaseManager.SharedInstance.getFullTextSupplementDownloadedCount(issue: self)
    }
    
    var fullTextSupplementDownloadedSize: Int {
        var downloadSize = 0
        for article in DatabaseManager.SharedInstance.getDownloadedArticles(issue: self) {
            if article.downloadInfo.fullTextSupplDownloadStatus == .downloaded {
                downloadSize += Int(article.downloadInfo.fullTextSupplFileSize)
            }
        }
        return downloadSize
    }
    
    // Supplement
    
    var fullTextAndAbstractSupplementTotalcount: Int {
        return fullTextSupplementTotalCount + abstractSupplementTotalCount
    }
    
    var fullTextAndAbstractSupplementDownloadedCount: Int {
        return fullTextSupplementDownloadedCount + abstractSupplementDownloadedCount
    }
    
    var fullTextAndAbstractSupplementDownloadedSize: Int {
        return abstractSupplementDownloadedSize + fullTextSupplementDownloadedSize
    }
    
    // Total
    
    var totalDownloadedSize: Int {
        return size(abstractSupplementSize: true, fullTextSize: true, fullTextSupplementSize: true)
    }
    
    fileprivate func size(abstractSupplementSize: Bool, fullTextSize: Bool, fullTextSupplementSize: Bool) -> Int {
        var downloadSize = 0
        for article in allArticles {
            if abstractSupplementSize == true {
                if article.downloadInfo.abstractSupplDownloadStatus == .downloaded {
                    downloadSize += Int(article.downloadInfo.abstractSupplFileSize)
                } else {
                    for media in article.allMedia where media.articleType == .abstract {
                        downloadSize += Int(media.fileSize)
                    }
                }
            }
            if fullTextSize == true {
                if article.downloadInfo.fullTextDownloadStatus == .downloaded {
                    downloadSize += Int(article.downloadInfo.fullTextFileSize)
                }
            }
            if fullTextSupplementSize == true {
                if article.downloadInfo.fullTextSupplDownloadStatus == .downloaded {
                    downloadSize += Int(article.downloadInfo.fullTextSupplFileSize)
                } else {
                    for media in article.allMedia where media.articleType == .fullText {
                        if media.downloadStatus == .downloaded {
                            downloadSize += Int(media.fileSize)
                        }
                    }
                }
            }
        }
        return downloadSize
    }
    
    // File Size
    
    var fullTextDownloadedFileSize: (fullText: Int, fullTextMultimedia: Int) {
        var fullText           : Int64 = 0
        var fullTextMultimedia : Int64 = 0
        for article in allArticles {
            let info = article.downloadInfo
            if info?.fullTextDownloadStatus == .downloaded {
                fullText += (info?.fullTextFileSize)!
                fullTextMultimedia += (info?.fullTextFileSize)!
            }
            if info?.abstractSupplDownloadStatus == .downloaded {
                fullTextMultimedia += (info?.abstractSupplFileSize)!
            }
            if info?.fullTextSupplDownloadStatus == .downloaded {
                fullTextMultimedia += (info?.fullTextSupplFileSize)!
            }
        }
        return (Int(fullText), Int(fullTextMultimedia))
    }
    
    var fullTextUndownloadCount: Int {
        var undownloadCount = 0
        for article in allArticles {
            if article.downloadInfo.fullTextDownloadStatus != .downloaded && article.downloadInfo.fullTextDownloadStatus != .notAvailable {
                undownloadCount += 1
            }
        }
        return undownloadCount
    }
    
    var fullTextUndownloadedSize: Int {
        var size = 0
        for article in allArticles {
            if article.downloadInfo.fullTextDownloadStatus != .downloaded {
                let fullTextFileSize = article.downloadInfo.fullTextFileSize
                size += Int(fullTextFileSize)
            }
        }
        return size
    }
    
    var supplementToalCount: Int {
        var supplementCount = 0
        for article in allArticles {
            if article.downloadInfo.fullTextSupplDownloadStatus != .notAvailable { supplementCount += 1 }
        }
        return supplementCount
    }
    
    var supplementDownloadCount: Int {
        var downloadCount = 0
        for article in allArticles {
            if article.downloadInfo.fullTextSupplDownloadStatus == .downloaded { downloadCount += 1 }
        }
        return downloadCount
    }
    
    var supplementUndownloadCount: Int {
        var undownloadCount = 0
        for article in allArticles {
            if article.downloadInfo.fullTextSupplDownloadStatus != .downloaded && article.downloadInfo.fullTextSupplDownloadStatus != .notAvailable {
                undownloadCount += 1
            }
        }
        return undownloadCount
    }
    
    var fullTextAndSupplementUndownloadedSize: Int {
        var size: Int64 = 0
        for article in allArticles {
            if article.downloadInfo.fullTextDownloadStatus != .downloaded {
                size += article.downloadInfo.fullTextFileSize
            }
            if article.downloadInfo.fullTextSupplDownloadStatus != .downloaded {
                size += article.downloadInfo.fullTextSupplFileSize
            }
            if article.downloadInfo.abstractSupplDownloadStatus != .downloaded {
                size += article.downloadInfo.abstractSupplFileSize
            }
        }
        return Int(size)
    }
}

// MARK: - Path -

extension Issue {
    
    var coverImagePath: String? {
        guard let coverImageName = coverImage else { return nil }
        return journal.coverImagesPath + coverImageName
    }
    
    var coverImageDownloadStatus: DownloadStatus {
        get {
            guard let status = DownloadStatus(rawValue: coverImageDownload.intValue) else {
                log.error("Unable to create Download Status")
                return .notAvailable
            }
            return status
        }
        set(status) { coverImageDownload = status.rawValue as NSNumber! }
    }
}

// MARK: - Misc -

extension Issue {
    
    var displayTitle: String {
        var title = ""
        if let dateText   = releaseDateDisplay { title += dateText }
        if let volumeText = volume             { title += " | Volume \(volumeText)" }
        if let numberText = issueNumber        { title += " | Issue \(numberText)" }
        return title
    }
    
    func orderArticlesStartingWithArticle(_ article: Article) -> [Article] {
        
        let articles = allArticles
        
        var index             : Int  = 0
        var next              : Bool = true
        var newArray          : [Article] = []
        
        var nextIndex         : Int
        var previousIndex     : Int
        
        var nextCompleted     : Bool = false
        var previousCompleted : Bool = false
        
        if let _index = articles.index(of: article) {
            index = _index
        }
        newArray.append(articles[index])
        
        nextIndex = index + 1
        previousIndex = index - 1
        
        while nextCompleted == false || previousCompleted == false {
            if next == true {
                if nextIndex < articles.count {
                    newArray.append(articles[nextIndex])
                    nextIndex += 1
                } else {
                    nextCompleted = true
                }
                next = false
            } else {
                if previousIndex >= 0 {
                    newArray.append(articles[previousIndex])
                    previousIndex -= 1
                } else {
                    previousCompleted = true
                }
                next = true
            }
        }
        
        return newArray
    }
}

// MARK: - Create or Update -

extension Issue {
}
