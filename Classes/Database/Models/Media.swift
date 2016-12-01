//
//  Media.swift
//  ContentKit
//
//  Created by Sharkey, Justin (ELS-CON) on 10/10/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

enum ArticleType: Int {
    case abstract = 0
    case fullText = 1
}

@objc(Media)
open class Media: NSManagedObject {
    
    @NSManaged var thumbImageName: String?
    @NSManaged var shareable: NSNumber!
    @NSManaged var fileName: String!
    @NSManaged var text: String!
    @NSManaged var caption: String!
    @NSManaged var sequence: NSNumber!
    @NSManaged var fileSize: NSNumber!
    @NSManaged var mediaFileDuration: String?
    
    var expandAuthorList = false
    
    // Article Type
    
    @NSManaged fileprivate var isFullTextAsset: NSNumber!
    var articleType: ArticleType {
        if isFullTextAsset == 0 {
            return .abstract
        } else {
            return .fullText
        }
    }
    
    // Download Status
    
    @NSManaged fileprivate var download: NSNumber!
    var downloadStatus: DownloadStatus {
        get {
            if let _downloadStatus = DownloadStatus(rawValue: Int(download)) {
                if _downloadStatus == .downloaded {
                    return .downloaded
                } else  if _downloadStatus == .downloading {
                    return .downloading
                }
            }

            switch articleType {
            case .abstract:
                if article.downloadInfo.abstractSupplDownloadStatus == .downloaded {
                    return .downloaded
                } else if article.downloadInfo.abstractSupplDownloadStatus == .downloading {
                    return .downloading
                }
            case .fullText:
                if article.downloadInfo.fullTextSupplDownloadStatus == .downloaded {
                    return .downloaded
                } else if article.downloadInfo.fullTextSupplDownloadStatus == .downloading {
                    return .downloading
                }
            }
            return DownloadStatus(rawValue: Int(download))!
        }
        set(status) {
            download = status.rawValue as NSNumber!
            performOnMainThread { 
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Media.Updated), object: self)
            }
            
            switch status {
            case .downloaded:
                performOnMainThread({ 
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Media.Successful), object: self)
                })
            case .downloadFailed:
                performOnMainThread({ 
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Media.Failure), object: self)
                })
            case .downloading:
                performOnMainThread({ 
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Media.Started), object: self)
                })
            default:
                break
            }
        }
    }
    
    // File Type
    
    @NSManaged var type: String?
    var fileType: MediaFileType {
        get {
            guard let type = self.type else {
                return .NoFileType
            }
            guard let fileType = MediaFileType(rawValue: type) else {
                return .NoFileType
            }
            return fileType
        }
    }
    
    var userHasAccess: Bool {
        if article.userHasAccess { return true }
        if article.downloadInfo.fullTextDownloadStatus == .downloaded {
            return true
        }
        if let issue = article.issue {
            if issue.userHasAccess { return true }
        }
        if article.journal.userHasAccess { return true }
        switch articleType {
        case .abstract:
            return true
        case .fullText:
            return false
        }
    }
    
    // Relationship
    
    @NSManaged var article: Article!

    // Path
    
    var oldAbsSupplementPath: String {
        return article.fulltextSupplementDirectory + fileName
    }
    
    var pathString: String {
        var _pathString: String
        
        switch fileType {
        case .Image:
            if article.downloadInfo.fullTextDownloadStatus == .downloaded {
                _pathString = article.fulltextImagePath
            } else {
                _pathString = article.abstractImagePath
            }
        case .Table:
            if article.downloadInfo.fullTextDownloadStatus == .downloaded {
                _pathString = article.fulltextBasePath
            } else {
                _pathString = article.abstractDirectory
            }
        default:
            switch articleType {
            case.abstract:
                _pathString = article.abstractSupplementDirectory
            case .fullText:
                _pathString = article.fulltextSupplementDirectory
            }
        }
        
        return _pathString + fileName
    }
    
    var pathURL: URL {
        return URL(string: "file://" + pathString)!
    }
    
    var imagePath: URL? {
        guard fileType == .Image else { return nil }
        
        // Large
        
        var imagePath: String
        switch articleType {
        case .abstract:
            imagePath = article.abstractImagePath
        case .fullText:
            imagePath = article.fulltextImagePath
        }
        
        let normalImagePath = imagePath + fileName
        let largeImagePath = imagePath + fileName.replacingOccurrences(of: ".jpg", with: "_lrg.jpg")
        
        var completePath = ""
        if FileSystemManager.sharedInstance.pathExists(largeImagePath) {
            completePath = largeImagePath
        } else if FileSystemManager.sharedInstance.pathExists(normalImagePath) {
            completePath = normalImagePath
        } else {
            log.error("Can't Find Image")
            return nil
        }
        
        return URL(fileURLWithPath: completePath)
    }
    
    var image: UIImage? {
        guard let figurePath = imagePath else { return nil }
        guard let data = try? Data(contentsOf: figurePath) else { return nil }
        guard let image = UIImage(data: data) else { return nil }
        return image
    }
}

extension Media {
    
    func create(_ metadata:[String: AnyObject]) {
        setupDefaults()
        self.update(metadata)
    }
    
    func setupDefaults() {
        isFullTextAsset = 0
        downloadStatus = .notDownloaded
    }
    
    func update(_ metadata:[String: AnyObject]) {
        self.type = metadata["mediaType"] as? String
        self.thumbImageName = metadata["mediaThumbImageName"] as? String
        if let isShareable = metadata["isShareable"] as? Bool {
            self.shareable = isShareable as NSNumber
        }
        self.fileName = metadata["mediaFileName"] as? String
        self.text = metadata["mediaText"] as? String
        self.caption = metadata["mediaCaption"] as? String
        if let sequence = metadata["sequence"] as? Int {
            self.sequence = sequence as NSNumber
        }
        if let mediaFileSize = metadata["mediaFileSize"] as? Int {
            self.fileSize = mediaFileSize as NSNumber
        }
        self.mediaFileDuration = metadata["mediaFileDuration"] as? String
        if let isFullTextAsset = metadata["isFullTextAsset"] as? Bool {
            self.isFullTextAsset = isFullTextAsset as NSNumber
        }
    }
    
    
}
