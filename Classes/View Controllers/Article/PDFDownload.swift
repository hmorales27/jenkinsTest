//
//  PDFDownload.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 8/24/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Foundation
import ZipArchive

class PDFDownload: NSObject, URLSessionDownloadDelegate {
    
    var session: Foundation.URLSession!
    
    var completion:((Bool)->())?
    var update:((Float)->())?
    
    var article: Article!
    
    override init() {
        super.init()
        session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
    
    func downloadPDF(_ article: Article, completion:@escaping (_ success: Bool)->(), update:@escaping (_ percent: Float)->()) {
        self.article = article
        self.completion = completion
        self.update = update
        
        guard let request = JBSMURLRequest.V2.ArticlePDFRequest(article: article) else { return }
        
        DatabaseManager.SharedInstance.performChangesAndSave {
            self.article?.downloadInfo.pdfDownloadStatus = .downloading
        }
        
        let task = session.downloadTask(with: request)
        task.resume()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        do {
            try SSZipArchive.unzipFile(atPath: location.path, toDestination: self.article!.journal.pdfPath, overwrite: true, password: nil)
            DatabaseManager.SharedInstance.performChangesAndSave {
                self.article.downloadInfo.pdfDownloadStatus = .downloaded
                self.completion?(true)
            }
            return
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        DatabaseManager.SharedInstance.performChangesAndSave {
            self.article.downloadInfo.pdfDownloadStatus = .downloadFailed
            self.completion?(false)
        }
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let _percent:Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print(_percent)
        self.update?(_percent)
    }
    
}
