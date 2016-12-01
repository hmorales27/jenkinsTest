//
//  Article.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/21/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(Article)
open class Article: NSManagedObject, SectionDataProtocol {

    
    var canDeleteArticle: Bool {
        if allNotes.count > 0 {
            return false
        }
        if starred == true {
            return false
        }
        return true
    }
    
    var information: String {
        var _information = ""
        if let title = articleTitle {
            _information += "Article Name: \(title) (OA: \(openAccess.type) || "
        }
        if let issue = issue {
            if let issueDate = issue.releaseDateDisplay {
                _information += "Issue Name: \(issueDate) (OA: \(issue.openAccess.type)) || "
            }
        }
        if let journaltitle = journal.journalTitle {
            _information += "Journal Name: \(journaltitle) (OA: \(journal.openAccess.type)))"
        }
        return _information
    }
    
    static let EntityName = "Article"
    
    func sectionKey() -> String {
        if isAIP == true {
            let dateFormatter = DateFormatter(dateFormat: "YYYY")
            return dateFormatter.string(from: dateOfRelease!)
        } else {
            if Strings.IsLancet == true {
                return lancetArticleType!
            } else {
                return articleType!
            }
        }
    }
    
    func sectionColor() -> UIColor? {
        if Strings.IsLancet == true {
            if let color = lancetArticleColor {
                return UIColor.colorWithHexCSV(color)
            }
        }
        return nil
    }
    
    func downloadable() -> Bool {
        return false
    }
    
    func downloaded() -> Bool {
        return false
    }
    
    func openArchive() -> Bool {
        return false
    }
    
    // MARK: PROPERTIES
    
    @NSManaged var abstract: String?
    @NSManaged var aipIdentifier: String?
    @NSManaged var articleId: NSNumber?
    @NSManaged var articleInfoId: String!
    @NSManaged var articleSubType: String?
    @NSManaged var articleSubType2: String?
    @NSManaged var articleSubType3: String?
    @NSManaged var articleSubType4: String?
    @NSManaged var articleTitle: String?
    @NSManaged var articleType: String?
    @NSManaged var author: String?
    @NSManaged var citationText: String?
    @NSManaged var copyright: String?
    @NSManaged var dateOfRelease: Date?
    @NSManaged var doctopicRole: String?
    @NSManaged var doi: String?
    @NSManaged var doiLink: String?
    @NSManaged var hasAudio: NSNumber!
    @NSManaged var hasImage: NSNumber!
    @NSManaged var hasOthers: NSNumber!
    @NSManaged var hasVideo: NSNumber!
    @NSManaged var hasAbstractImages: NSNumber!
    @NSManaged var isArticleInPress: NSNumber!
    @NSManaged var issueId: NSNumber?
    @NSManaged var issuePII: String?
    @NSManaged var keywords: String?
    @NSManaged var lancetArticleColor: String?
    @NSManaged var lancetArticleType: String?
    @NSManaged var lancetGroupSequence: String?
    @NSManaged var lastModified: Date?
    @NSManaged var pageRange: String?
    @NSManaged var sequence: NSNumber?
    @NSManaged var starred: NSNumber!
    @NSManaged var starredDate: Date?
    @NSManaged var usageInfoEntitlements: String?
    @NSManaged var usageInfoPrimary: String?
    @NSManaged var v40: NSNumber?
    @NSManaged var version: NSNumber?
    @NSManaged var video: String?
    @NSManaged var isCME: NSNumber!
    
    // MARK: RELATIONSHIPS (SINGLE)
    
    @NSManaged var issue            : Issue?
    @NSManaged var journal          : Journal!
    @NSManaged var downloadInfo     : DownloadInfo!
    @NSManaged var ipAuthentication : IPAuthentication?
    @NSManaged var openAccess       : OA!
    @NSManaged var topArticle       : TopArticle?
    
    // MARK: RELATIONSHIPS (MANY)
    
    @NSManaged var medias           : NSSet?
    @NSManaged var notes            : NSSet?
    @NSManaged var authors          : NSSet?
    @NSManaged var references       : NSSet?
    
    // MARK: - Zip File Names -
    
    var abstractHTMLZipName: String {
        get {
            return articleInfoId + "_abs.zip"
        }
    }
    
    var abstractImagesZipName: String {
        get {
            return articleInfoId + "_abs_images.zip"
        }
    }
    
    var abstractSupplementZipName: String {
        get {
            return articleInfoId + "_abs_suppl.zip"
        }
    }
    
    var fulltextHTMLZipName: String {
        get {
            return articleInfoId + ".zip"
        }
    }
    
    var fulltextImagesZipName: String {
        get {
            return articleInfoId + "_images.zip"
        }
    }
    
    var fulltextSupplementZipName: String {
        get {
            return articleInfoId + "_suppl.zip"
        }
    }
    
    var pdfZipName: String {
        return articleInfoId + "_pdf.zip"
    }
    
    // MARK: - Local File Path -
    
    // MARK: - Other -
    
    var isAIP: Bool {
        if issue == .none {
            return true
        }
        return false
    }
    
    // MARK: - Email -
    
    var emailTitle: String {
        return "Recommended Article From \(journal.journalTitle!)"
    }
    
    var emailBody: String {
        var text = "Article Citation"
        text += "<br>"
        
        if let _articleTitle = articleTitle {
            text += "<br>"
            text += "<b>" + "Article Title" + "</b>"
            text += "<br>"
            text += _articleTitle
            text += "<br>"
        }
        
        if let _authors = author {
            if _authors != "" {
                text += "<br>"
                text += "<b>" + "Authors" + "</b>"
                text += "<br>"
                text += _authors
                text += "<br>"
            }
        }
        
        text += "<br>"
        text += "<b>" + "Source" + "</b>"
        text += "<br>"
        text += journal.journalTitle!
        let dateFormatter = DateFormatter(dateFormat: "MMM dd, YYYY")
        let date = dateFormatter.string(from: dateOfRelease!)
        text += " - " + "\(date)"
        text += "<br>"
        
        if let volume = self.issue?.volume {
            text += volume + "|"
        }
        
        if let issueNumber = issue?.issueNumber {
            text += "\(issueNumber)" + "|"
        }
        if let range = pageRange {
            text += "Pages " + range
        }
        
        text += "<br>"
        
        if let doi = self.doi {
            text += "DOI: " + doi
        }
        
        if let doiLink = self.doiLink {
            text += "<br>"
            text += "DOI: " + "<a href='\(doiLink)'>" + doiLink + "</a>"
        }
        
        if let issue = self.issue {
            var issueLabelText = ""
            
            if let dateText = issue.releaseDateDisplay {
                issueLabelText += dateText
            }
            if let volumeText = issue.volume {
                issueLabelText += " | Volume \(volumeText)"
            }
            if let numberText = issue.issueNumber {
                issueLabelText += " | Issue \(numberText)"
            }
            text += "<p>"
            text += "<b>\(issueLabelText)</b>"
            text += "</p>"
        }
        
        if let copyright = self.copyright {
            text += "<p align = 'left'>" + copyright + "</p>"
        }

        return text
    }
    
    // Abstract
    
    var abstractDirectory: String {
        return abstractDirectoryName + "/"
    }
    
    var abstractDirectoryName: String {
        return journal.abstractsPath + articleInfoId + "_abs"
    }
    
    var abstractImagesBasePath: String {
        return journal.abstractsPath + articleInfoId + "_abs_images/"
    }
    
    var abstractHTMLPath: String {
        return abstractDirectory + "main_abs.html"
    }
    
    var abstractImagePath: String {
        return abstractDirectory + "image/"
    }
    
    var abstractSupplementDirectory: String {
        return abstractDirectory + abstractSupplementDirectoryName + "/"
    }
    
    var abstractSupplementDirectoryName: String {
        return articleInfoId + "_abs_suppl"
    }
    
    // FullText
    
    var fulltextBasePath: String {
        return journal.fullTextPath + articleInfoId + "/"
    }
    
    var fulltextImagesBasePath: String {
        return journal.fullTextPath + articleInfoId + "_images/"
    }
    
    var fulltextHTMLPath: String {
        return fulltextBasePath + "main.html"
    }
    
    var fulltextImagePath: String {
        return fulltextBasePath + "image/"
    }
    
    var fulltextSupplementDirectory: String {
        return fulltextBasePath + fulltextSupplementDirectoryName + "/"
    }
    
    var fulltextSupplementDirectoryName: String {
        return articleInfoId + "_suppl"
    }
    
    // PDF
    
    var pdfBasePath: String {
        return journal.pdfPath + articleInfoId + "_pdf/"
    }
    
    var pdfPath: String {
        return pdfBasePath + "main.pdf"
    }
    
    // Relationships
    
    var allMedia: [Media] {
        get {
            if let m = medias?.allObjects as? [Media] {
                return m
            }
            return []
        }
    }
    
    var allNotes: [Note] {
        get {
            if let _notes = notes?.allObjects as? [Note] {
                return _notes
            }
            return []
        }
    }
    
    var _isOpenAccess: Bool {
        get {
            return (openAccess.oaIdentifier != 0 || issue?.openAccess.oaIdentifier != 0 || journal.isJournalOpenAccess) ? true : false
        }
    }
    
    var showOpenAccessLabel: Bool {
        get {
            if journal.isJournalOpenAccessOrArchive {
                return false
            }
            if issue?.isIssueOpenAccessOrArchive == true {
                return false
            }
            
            return true
        }
    }
    
    var cleanArticleTitle: String {
        guard let articleTitle = self.articleTitle else {
            return ""
        }
        return articleTitle.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    var videos: [Media] {
        var response: [Media] = []
        for media in allMedia {
            if media.fileType == MediaFileType.Video {
                response.append(media)
            }
        }
        return response
    }
    
    var audios: [Media] {
        var response: [Media] = []
        for media in allMedia {
            if media.fileType == MediaFileType.Audio {
                response.append(media)
            }
        }
        return response
    }
    
}

extension Article {
    
    func emailBodyWithNotes(_ notes: [Note]) -> String {
        
        var text = "Article Citation"
        text += "<br>"
        
        if let _articleTitle = articleTitle {
            text += "<br>"
            text += "<b>" + "Article Title" + "</b>"
            text += "<br>"
            text += _articleTitle
            text += "<br>"
        }
        
        if let _authors = author {
            if _authors != "" {
                text += "<br>"
                text += "<b>" + "Authors" + "</b>"
                text += "<br>"
                text += _authors
                text += "<br>"
            }
        }
        
        text += "<br>"
        text += "<b>" + "Source" + "</b>"
        text += "<br>"
        text += journal.journalTitle!
        let dateFormatter = DateFormatter(dateFormat: "MMM dd, YYYY")
        let date = dateFormatter.string(from: dateOfRelease!)
        text += " - " + "\(date)"
        text += "<br>"
        
        if let volume = self.issue?.volume {
            text += volume + "|"
        }
        
        if let issueNumber = issue?.issueNumber {
            text += "\(issueNumber)" + "|"
        }
        if let range = pageRange {
            text += "Pages " + range
        }
        
        text += "<br>"
        
        if let doi = self.doi {
            text += "DOI: " + doi
        }
        
        if let doiLink = self.doiLink {
            text += "<br>"
            text += "DOI: " + "<a href='\(doiLink)'>" + doiLink + "</a>"
        }
        
        if let issue = self.issue {
            var issueLabelText = ""
            
            if let dateText = issue.releaseDateDisplay {
                issueLabelText += dateText
            }
            if let volumeText = issue.volume {
                issueLabelText += " | Volume \(volumeText)"
            }
            if let numberText = issue.issueNumber {
                issueLabelText += " | Issue \(numberText)"
            }
            text += "<p>"
            text += "<b>\(issueLabelText)</b>"
            text += "</p>"
        }

        for note in notes {
            let noteNumber = notes.startIndex.distance(to: notes.index(of: note)!) + 1
            
            text += "<p> <b>Note \(noteNumber)</b> <p>  <hr></p> </p>"
            text += "<p> Text of Note:</p>"
            text += "<p>\(note.noteText)</p>"
            text += "<p> Highlighted Text from Article:</p>"
            text += "<p>\(note.selectedText)</p>"
        }
        if let copyright = self.copyright {
            text += "<p align = 'left'>" + copyright + "</p>"
        }
        //  Log 'text'
        return text
    }

    // MARK: - Methods -

    func mediaForFile(_ fileName: String) -> Media? {
        for media in allMedia {
            if media.fileName == fileName || media.fileName == fileName.replacingOccurrences(of: "_lrg", with: "") {
                return media
            }
        }
        return nil
    }
    
    func toggleStarred() {
        if starred == true {
            starred = false
            starredDate = nil
            
            performOnMainThread({
                
                NotificationCenter.default.post(name: Foundation.Notification.Name.HideReadingListDialogue, object: nil)
            })
            
            AnalyticsHelper.MainInstance.contentAddRemoveToReadingList(false, productInfo: productInfoForHTML, contentInfo: mapForContentValuesForAnalytics)
        } else {
            starred = true
            starredDate = Date()
            if UserConfig.MainInstance.ShowGoToBookmarks == true {
                
                performOnMainThread({ 
                    NotificationCenter.default.post(name: Foundation.Notification.Name.ShowReadingListDialogue, object: nil)
                })
            }
            AnalyticsHelper.MainInstance.contentAddRemoveToReadingList(true, productInfo: productInfoForHTML, contentInfo: mapForContentValuesForAnalytics)
        }
    }
    
    var productInfoForHTML: String {
        return AnalyticsHelper.MainInstance.createProductInforForEventAction(
            articleInfoId,
            fileFormat: "mime-html",
            contentType: Constants.Content.ValueTypeFull,
            bibliographicInfo: AnalyticsHelper.MainInstance.createBibliographicInfo(issue?.volume, issue: issue?.issueNumber),
            articleStatus: "",
            articleTitle: articleTitle!.lowercased(),
            accessType: journal.accessType!.lowercased()
        )

    }
    
    var mapForContentValuesForAnalytics: [AnyHashable: Any] {
        let contentType: String = ""
        var bibliographicinfo: [String] = []
        if let issue = self.issue {
            bibliographicinfo.append("\(issue.volume)")
            bibliographicinfo.append("\(issue.issueId)")
        }
        return AnalyticsHelper.MainInstance.createMapForContentUsage(
            journal.accessType!.lowercased(),
            contentID: articleInfoId,
            bibliographic: AnalyticsHelper.MainInstance.createBibliographicInfo(issue?.volume, issue: issue?.issueNumber),
            contentFormat: "mime-html",
            contentInnovationName: "",
            contentStatus: "",
            contentTitle: articleTitle!.lowercased(),
            contentType: Constants.Content.ValueTypeFull,
            contentViewState: contentType
        )
    }
    
    func update(downloadType type: DLItemType, withStatus status: DownloadStatus) {
        
        switch type {
        case .FullText:
            downloadInfo.fullTextDownloadStatus = status
        case .FullTextHTML:
            downloadInfo.fullTextHTMLDownloadStatus = status
        case .FullTextImages:
            downloadInfo.fullTextImagesDownloadStatus = status
        case .FullTextSupplement:
            downloadInfo.fullTextSupplDownloadStatus = status
            if status == .downloaded {
                for media in allMedia {
                    switch media.articleType {
                    case .abstract:
                        break
                    case .fullText:
                        media.downloadStatus = .downloaded
                        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Media.Successful), object: media)
                    }
                }
            }
        case .Abstract:
            downloadInfo.abstractDownloadStatus = status
        case .AbstractHTML:
            downloadInfo.abstractHTMLDownloadStatus = status
        case .AbstractImages:
            downloadInfo.abstractImagesDownloadStatus = status
        case .AbstractSupplement:
            downloadInfo.abstractSupplDownloadStatus = status
        case .PDF:
            downloadInfo.pdfDownloadStatus = status
        }
    }
    

    

}

// MARK: - Download Information
extension Article {
    // MARK: 
    
    // MARK: ABSTRACT SUPPLEMENT
    
    var abstractSupplementExists: Bool {
        return downloadInfo.abstractSupplDownloadStatus != .notAvailable ? true : false
    }
    
    var abstractSupplementDownloaded: Bool {
        return downloadInfo.abstractSupplDownloadStatus == .downloaded ? true : false
    }
    
    var abstractSupplementFileSize: Int {
        return Int(downloadInfo.abstractSupplFileSize)
    }
    
    var abstractSupplementDownloadedSize: Int {
        var downloadeSize = 0
        if abstractSupplementDownloaded == true {
            downloadeSize += abstractSupplementFileSize
        } else {
            for media in allMedia where media.articleType == .abstract {
                if media.downloadStatus == .downloaded {
                    downloadeSize += Int(media.fileSize)
                }
            }
        }
        return downloadeSize
    }
    
    var abstractSupplementRemainingSize: Int {
        if abstractSupplementExists && !abstractSupplementDownloaded {
            return abstractSupplementFileSize
        }
        return 0
    }
    
    // MARK: FULLTEXT
    
    var fullTextFileSize: Int {
        return Int(downloadInfo.fullTextFileSize)
    }
    
    var fullTextDownloadedSize: Int {
        if fullTextDownloaded == true {
            return 0
        }
        return fullTextFileSize
    }
    
    var fullTextRemainingSize: Int {
        return !fullTextDownloaded ? fullTextFileSize : 0
    }
    
    // MARK: FULLTEXT SUPPLEMENT
    
    var fullTextSupplementExists: Bool {
        return downloadInfo.fullTextSupplDownloadStatus != .notAvailable ? true : false
    }
    
    var fullTextSupplementDownloaded: Bool {
        return downloadInfo.fullTextSupplDownloadStatus == .downloaded ? true : false
    }
    
    var fullTextSupplementFileSize: Int {
        return Int(downloadInfo.fullTextSupplFileSize)
    }
    
    var fullTextSupplementDownloadedSize: Int {
        var downloadeSize = 0
        if fullTextSupplementDownloaded == true {
            downloadeSize += fullTextSupplementFileSize
        } else {
            for media in allMedia where media.articleType == .fullText {
                if media.downloadStatus == .downloaded {
                    downloadeSize += Int(media.fileSize)
                }
            }
        }
        return downloadeSize
    }
    
    var fullTextSupplementRemainingSize: Int {
        if fullTextSupplementExists && !fullTextSupplementDownloaded {
            return fullTextSupplementFileSize
        }
        return 0
    }
    
    // MARK: ALL SUPPLEMENT
    
    var abstractAndFullTextSupplementExists: Bool {
        if abstractSupplementExists == true || fullTextSupplementExists == true {
            return true
        }
        return false
    }
    
    var abstractAndFullTextSupplementDownloaded: Bool {
        guard abstractAndFullTextSupplementExists == true else { return false }
        if abstractSupplementExists && !abstractSupplementDownloaded {
            return false
        }
        if fullTextSupplementExists && !fullTextSupplementDownloaded {
            return false
        }
        return true
    }
    
    var abstractAndFullTextSupplementFileSize: Int {
        return abstractSupplementFileSize + fullTextSupplementFileSize
    }
    
    var abstractAndFullTextSupplementDownloadedSize: Int {
        return abstractSupplementDownloadedSize + fullTextSupplementDownloadedSize
    }
    
    var abstractAndFullTextSupplementRemainingSize: Int {
        return abstractSupplementRemainingSize + fullTextSupplementRemainingSize
    }
    
    
    // MARK: ENTIRE ARTICLE
    
    var entireArticleDownloaded: Bool {
        if abstractSupplementExists && !abstractSupplementDownloaded { return false }
        if !fullTextDownloaded { return false }
        if fullTextSupplementExists && !fullTextSupplementDownloaded { return false }
        return true
    }
    
    var entireArticleFileSize: Int {
        return abstractSupplementFileSize + fullTextFileSize + fullTextSupplementFileSize
    }
    
    var entireArticleDownloadedSize: Int {
        return abstractSupplementDownloadedSize + fullTextDownloadedSize + fullTextSupplementDownloadedSize
    }
    
    var entireArticleRemainingSize: Int {
        return abstractSupplementRemainingSize + fullTextRemainingSize + fullTextSupplementRemainingSize
    }
    
    var articleDownloadedSize: (absSuppl: Int, ft: Int, ftSuppl: Int) {
        return (abstractSupplementDownloadedSize, fullTextDownloadedSize, fullTextSupplementDownloadedSize)
    }
    
    var articleRemainingSize: (absSuppl: Int, ft: Int, ftSuppl: Int) {
        return (abstractSupplementRemainingSize, fullTextRemainingSize, fullTextSupplementRemainingSize)
    }
    
    var oldPDFFileName: String {
        guard let title = articleTitle else { return "" }
        return  String(title.characters.map {
            if $0 == " " {
                return "_"
            } else if $0 == "." {
                return "_"
            } else if $0 == "-" {
                return "_"
            } else if $0 == ":" {
                return "_"
            } else if $0 == "/" {
                return "_"
            } else {
                return $0
            }
        })
    }
    
    var oldPDFFilePath: String {
        return pdfBasePath + oldPDFFileName + ".pdf"
    }
}

// MARK: - Collection Item Protocol -

extension Article: CollectionItemProtocol {
    
    var itemSequence: String {
        if isAIP == true {
            let dateFormatter = DateFormatter(dateFormat: "YYYY")
            var date = Date()
            if let dor = dateOfRelease {
                date = dor
            }
            return dateFormatter.string(from: date)
        } else {
            if Strings.IsLancet == true {
                guard let type = lancetArticleType else {
                    return ""
                }
                return type
            } else {
                guard let type = articleType else {
                    return ""
                }
                return type
            }
        }
    }
    
    var itemType: String {
        return "Article"
    }
    
    var itemHasNotes: Bool {
        get {            
            if allNotes.count > 0 {
                return true
            } else {
                return false
            }
        }
    }
    var itemIsBookmarked: Bool {
        return starred.boolValue
    }
    
    var itemOrderNumber: Int {
        guard let sequence = self.sequence else {
            return 0
        }
        return Int(sequence)
    }
    
    var itemIsOA: Bool {
        return false
    }
    var itemIsDownloaded: Bool {
        if fullTextDownloaded {
            return true
        }
        return false
    }
}

