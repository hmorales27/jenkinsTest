//
//  ArticleWithCase.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/28/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

extension Article {
    
    
    
    func create(metadata: [String: AnyObject]) {
        setupDefaults()
        setupOpenAccess(articleInfoId: metadata["article_info_id"] as? String)
        openAccess.article = self
        openAccess.create(json: metadata)
        setupDownloadInfo(metadata: metadata)
        update(metadata: metadata)
    }
    
    func setupDefaults() {
        
        hasAudio = false
        hasImage = false
        hasOthers = false
        hasVideo = false
        hasAbstractImages = false
        isCME = false
        
        // AIP
        isArticleInPress = false
        
        // Other
        starred = false
        
        // OA
        downloadInfo = DatabaseManager.SharedInstance.getNewDownloadInfo()
        downloadInfo.article = self
        
    }
    
    func setupForMigration() {
        openAccess = DatabaseManager.SharedInstance.newOpenAccess()
        openAccess.article = self
        downloadInfo = DatabaseManager.SharedInstance.getNewDownloadInfo()
        downloadInfo.article = self
        isCME = false
    }
    
    func setupOpenAccess(articleInfoId: String?) {
        if let _articleInfoId = articleInfoId {
            if let _openAccess = DatabaseManager.SharedInstance.getOpenAccessForArticle(articleInfoId: _articleInfoId) {
                self.openAccess = _openAccess
                return
            }
        }
        openAccess = DatabaseManager.SharedInstance.newOpenAccess()
    }
    
    func setupOpenAccess(issuePii: String?) {
        if let _issuePii = issuePii {
            if let _openAccess = DatabaseManager.SharedInstance.getOpenAccessForIssue(issuePii: _issuePii) {
                self.openAccess = _openAccess
                return
            }
        }
        openAccess = DatabaseManager.SharedInstance.newOpenAccess()
    }
    
    func update(metadata: [String: AnyObject]) {
        aipIdentifier = metadata["aipIdentifier"] as? String
        if let articleId = metadata["articleId"] as? Int {
            self.articleId = articleId as NSNumber
        }
        // TODO: Switch to articlePii
        articleInfoId = metadata["articlePii"] as? String
        articleType = metadata["articleType"] as? String
        articleSubType = metadata["articleSubType"] as? String
        articleSubType2 = metadata["articleSubType2"] as? String
        articleSubType3 = metadata["articleSubType3"] as? String
        articleSubType4 = metadata["articleSubType4"] as? String
        articleTitle = metadata["articleTitle"] as? String
        if let author = metadata["authorNames"] as? String {
            self.author = author != "" ? author : nil
        }
        citationText = metadata["citationText"] as? String
        copyright = metadata["copyright"] as? String
        if let dateOfRelease = metadata["dateOfRelease"] as? String {
            self.dateOfRelease = Date.JBSMShortDateFromString(dateOfRelease)
        }
        doctopicRole = metadata["docTopicRole"] as? String
        doi = metadata["doi"] as? String
        doiLink = metadata["doiLink"] as? String
        // TODO: Remove this - Use relationship
        if let issueId = metadata["issueId"] as? Int {
            self.issueId = issueId as NSNumber
        }
        // TODO: Remove thsi - Use Relationship
        issuePII = metadata["issuePii"] as? String
        keywords = metadata["keywords"] as? String
        lancetArticleColor = metadata["lancetArticleColor"] as? String
        lancetArticleType = metadata["lancetArticleType"] as? String
        lancetGroupSequence = metadata["lancetGroupSequence"] as? String
        if let lastModified = metadata["lastModified"] as? String {
            self.lastModified = Date.JBSMLongDateFromString(lastModified)
        }
        pageRange = metadata["pageRange"] as? String
        // TODO: This is wrong
        if let sequence = metadata["sequence"] as? Int {
            self.sequence = sequence as NSNumber?
        }
        // TODO: Remove
        if let v40 = metadata["v40"] as? Int {
            self.v40 = v40 as NSNumber?
        } else if let v40 = metadata["v40"] as? String {
            self.v40 = Int(v40) as NSNumber?
        }
        // TODO: Remove
        if let version = metadata["version"] as? String {
            self.version = Float(version) as NSNumber?
        }
        // TODO: Remove
        video = metadata["Video"] as? String
        
        if let hasVideo = metadata["hasVideo"] as? Int {
            self.hasVideo = hasVideo as NSNumber!
        }
        
        if let hasAudio = metadata["hasAudio"] as? Int {
            self.hasAudio = hasAudio as NSNumber!
        }
        
        if let hasImage = metadata["has_image"] as? Int {
            self.hasImage = hasImage as NSNumber!
        } else if let hasImage = metadata["has_image"] as? String {
            self.hasImage = Int(hasImage) as NSNumber!
        }
        
        if let hasOthers = metadata["hasOthers"] as? Int {
            self.hasOthers = hasOthers as NSNumber!
        }
        
        if let hasAbstractImages = metadata["hasAbsImage"] as? Int {
            self.hasAbstractImages = hasAbstractImages as NSNumber!
        }
        
        if let isArticleInPress = metadata["isAip"] as? Int {
            self.isArticleInPress = isArticleInPress as NSNumber!
        }
        
        if let isCME = metadata["isCme"] as? Int {
            self.isCME = isCME as NSNumber!
        }
    }
    
    func setupDownloadInfo(metadata: [String: AnyObject]) {
        
        if let htmlFileName = metadata["htmlFileName"] as? String {
            downloadInfo.fullTextFileName = htmlFileName
            downloadInfo.fullTextDownloadStatus = .notDownloaded
        }
        if let fulltextFileSize = metadata["fulltextFileSize"] as? Int {
            downloadInfo.fullTextFileSize = Int64(fulltextFileSize)
        }
        if let hasImages = metadata["hasImage"] as? Bool {
            downloadInfo.fullTextImagesDownloadStatus = hasImages ? .notDownloaded : .notAvailable
        }
        
        // Supplement
        
        if let hasSupplement = metadata["hasSupplement"] as? Bool {
            downloadInfo.fullTextSupplDownloadStatus = hasSupplement ? .notDownloaded : .notAvailable
        }
        if let supplementFileSize = metadata["supplementFileSize"] as? Int {
            downloadInfo.fullTextSupplFileSize = Int64(supplementFileSize)
        }
        
        // Abstract
        
        if let hasAbstract = metadata["hasAbstract"] as? Bool {
            downloadInfo.abstractDownloadStatus = hasAbstract ? .notDownloaded : .notAvailable
        }
        if let abstractFileSize = metadata["abstractFileSize"] as? Int {
            downloadInfo.abstractFileSize = Int64(abstractFileSize)
        }
        if let hasAbsImage = metadata["hasAbsImage"] as? Bool {
            downloadInfo.abstractImagesDownloadStatus = hasAbsImage ? .notDownloaded : .notAvailable
        }
        
        // Abstract Supplement
        
        if let hasAbsSupplement = metadata["hasAbsSupplement"] as? Bool {
            downloadInfo.abstractSupplDownloadStatus = hasAbsSupplement ? .notDownloaded : .notAvailable
        }
        if let absSupplementFileSize = metadata["absSupplementFileSize"] as? Int {
            downloadInfo.abstractSupplFileSize = Int64(absSupplementFileSize)
        }
        
        // PDF
        
        if let pdfFileName = metadata["pdfFileName"] as? String {
            downloadInfo.pdfFileName = pdfFileName
            downloadInfo.pdfDownloadStatus = .notDownloaded
        }
        if let pdfFileSize = metadata["pdfFileSize"] as? Int {
            downloadInfo.pdfFileSize = Int64(pdfFileSize)
        }
    }
}
