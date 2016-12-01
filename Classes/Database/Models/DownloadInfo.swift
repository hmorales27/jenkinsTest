//
//  DownloadInfo.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/21/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(DownloadInfo)
open class DownloadInfo: NSManagedObject {
    
    static let AbstractSupplDownload = "downloadInfo.abstractSupplDownload"
    
    @NSManaged fileprivate var abstractHTMLDownload     : Int16
    @NSManaged fileprivate var abstractImagesDownload   : Int16
    @NSManaged var abstractFileName                     : String?
    @NSManaged var abstractFileSize                     : Int64
    @NSManaged var abstractFileSizeUnzipped             : Int64
    
    
    @NSManaged fileprivate var abstractSupplDownload    : Int16
    @NSManaged var abstractSupplFileSize                : Int64
    @NSManaged var abstractSupplFileSizeUnzipped        : Int64
    
    @NSManaged fileprivate var fullTextHTMLDownload     : Int16
    @NSManaged fileprivate var fullTextImagesDownload   : Int16
    @NSManaged var fullTextFileName                     : String?
    @NSManaged var fullTextFileSize                     : Int64
    @NSManaged var fullTextFileSizeUnzipped             : Int64
    
    @NSManaged fileprivate var fullTextSupplDownload    : Int16
    @NSManaged var fullTextSupplFileSize                : Int64
    @NSManaged var fullTextSupplFileSizeUnzipped        : Int64
    
    @NSManaged fileprivate var pdfDownload              : Int16
    @NSManaged var pdfFileName                          : String?
    @NSManaged var pdfFileSize                          : Int64
    @NSManaged var pdfFileSizeUnzipped                  : Int64
    
    @NSManaged var article                              : Article!

    func create() {
        setDefaults()
    }
    
    func setDefaults() {
    }
    
    var fullTextDownloadStatus: DownloadStatus {
        
        // TODO: This Will Need To Be Tweaked
        
        get {
            
            if article.hasImage.boolValue == true {
                
                if fullTextHTMLDownloadStatus == .downloaded && fullTextImagesDownloadStatus == .downloaded {
                    return .downloaded
                }
                
                if fullTextHTMLDownloadStatus == .downloaded && fullTextImagesDownloadStatus == .notAvailable {
                    return .downloaded
                }

                if fullTextHTMLDownloadStatus == .downloading || fullTextImagesDownloadStatus == .downloading {
                    return .downloading
                }


                
                if fullTextHTMLDownloadStatus == .downloadFailed || fullTextImagesDownloadStatus == .downloadFailed {
                    var text = "Download Failed "
                    if let journalTitle = article.journal.journalTitle, let issn = article.journal.issn {
                        text += "Journal: \(journalTitle) (\(issn))"
                    }
                    if let articletitle = article.articleTitle, let articleInfoId = article.articleInfoId {
                        text += ", Article: \(articletitle) (\(articleInfoId))"
                    }
                    log.error(text)
                    return .downloadFailed
                }
                
                if fullTextHTMLDownloadStatus == .notAvailable && fullTextImagesDownloadStatus == .notAvailable {
                    return .notAvailable
                }
                
                return .notDownloaded
            } else {
                return article.downloadInfo.fullTextHTMLDownloadStatus
            }
        }
        set(status) {
            fullTextHTMLDownloadStatus = status
            if article.hasImage.boolValue == true {
                fullTextImagesDownloadStatus = status
            } else {
                fullTextImagesDownloadStatus = .notAvailable
            }
        }
    }
    
    var fullTextHTMLDownloadStatus: DownloadStatus {
        get {
            return DownloadStatus(rawValue: Int(fullTextHTMLDownload))!
        }
        set(status) {
            fullTextHTMLDownload = Int16(status.rawValue)
        }
    }
    
    var fullTextImagesDownloadStatus: DownloadStatus {
        get {
            return DownloadStatus(rawValue: Int(fullTextImagesDownload))!
        }
        set(status) {
            fullTextImagesDownload = Int16(status.rawValue)
        }
    }
    
    var fullTextSupplDownloadStatus: DownloadStatus {
        get {
            return DownloadStatus(rawValue: Int(fullTextSupplDownload))!
        }
        set(status) {
            fullTextSupplDownload = Int16(status.rawValue)
        }
    }
    
    var abstractDownloadStatus: DownloadStatus {
        
        // TODO: This Will Need To Be Tweaked
        
        get {
            
            if article.hasAbstractImages.boolValue == true {
                if abstractHTMLDownloadStatus == .downloaded && abstractImagesDownloadStatus == .downloaded {
                    return .downloaded
                }
                
                if abstractHTMLDownloadStatus == .downloaded && abstractImagesDownloadStatus == .notAvailable {
                    return .downloaded
                }
                
                if abstractHTMLDownloadStatus == .downloading || abstractImagesDownloadStatus == .downloading {
                    return .downloading
                }
                
                if abstractHTMLDownloadStatus == .downloadFailed || abstractImagesDownloadStatus == .downloadFailed {
                    return .downloadFailed
                }
                
                if abstractHTMLDownloadStatus == .notAvailable && abstractImagesDownloadStatus == .notAvailable {
                    return .notAvailable
                }
                
                return .notDownloaded
            } else {
                return abstractHTMLDownloadStatus
            }
        }
        set(status) {
            abstractHTMLDownloadStatus = status
            abstractImagesDownloadStatus = status
        }
    }
    
    var abstractHTMLDownloadStatus: DownloadStatus {
        get {
            return DownloadStatus(rawValue: Int(abstractHTMLDownload))!
        }
        set(status) {
            abstractHTMLDownload = Int16(status.rawValue)
        }
    }
    
    var abstractImagesDownloadStatus: DownloadStatus {
        get {
            return DownloadStatus(rawValue: Int(abstractImagesDownload))!
        }
        set(status) {
            abstractImagesDownload = Int16(status.rawValue)
        }
    }
    
    var abstractSupplDownloadStatus: DownloadStatus {
        get {
            return DownloadStatus(rawValue: Int(abstractSupplDownload))!
        }
        set(status) {
            abstractSupplDownload = Int16(status.rawValue)
        }
    }
    
    var pdfDownloadStatus: DownloadStatus {
        get {
            return DownloadStatus(rawValue: Int(pdfDownload))!
        }
        set(status) {
            pdfDownload = Int16(status.rawValue)
        }
    }
    
    func update(downloadType type: DLItemType, withStatus status: DownloadStatus) {
        switch type {
        case .FullText:
            fullTextDownloadStatus = status
        case .FullTextHTML:
            fullTextHTMLDownloadStatus = status
        case .FullTextImages:
            fullTextImagesDownloadStatus = status
        case .FullTextSupplement:
            fullTextSupplDownloadStatus = status
        case .Abstract:
            abstractDownloadStatus = status
        case .AbstractHTML:
            abstractHTMLDownloadStatus = status
        case .AbstractImages:
            abstractImagesDownloadStatus = status
        case .AbstractSupplement:
            abstractSupplDownloadStatus = status
        case .PDF:
            pdfDownloadStatus = status
        }
    }
    
    
}
