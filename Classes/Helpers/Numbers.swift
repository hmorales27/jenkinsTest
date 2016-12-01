//
//  Numbers.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 8/15/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

class Numbers : AnyObject {
    
    class func fullSizeForIssue(_ issue: Issue) -> Int {
        
        var totalSize = 0
        let articles = DatabaseManager.SharedInstance.getAllArticlesForIssue(issue)
        for article in articles {
            if article.downloadInfo.abstractSupplDownloadStatus == .downloaded {
                totalSize += Int(article.downloadInfo.abstractSupplFileSize)
            } else {
                for media in article.allMedia where media.articleType == .abstract {
                    if media.downloadStatus == .downloaded {
                        totalSize += Int(media.fileSize)
                    }
                }
            }
            if article.downloadInfo.fullTextDownloadStatus == .downloaded {
                totalSize += Int(article.downloadInfo.fullTextFileSize)
            }
            if article.downloadInfo.fullTextSupplDownloadStatus == .downloaded {
                totalSize += Int(article.downloadInfo.fullTextSupplFileSize)
            } else {
                for media in article.allMedia where media.articleType == .fullText {
                    if media.downloadStatus == .downloaded {
                        totalSize += Int(media.fileSize)
                    }
                }
            }
        }
        return totalSize
    }
}
