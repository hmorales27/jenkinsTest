//
//  Issue_UpdateWithCase.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/26/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

extension Issue {
    
    func setupForMigration() {
        openAccess = DatabaseManager.SharedInstance.newOpenAccess()
        openAccess.issue = self
        allArticlesDownloaded = false
        purchased = false
        isFreeIssue = false
    }
    
    func setup(json: [String: AnyObject], journal: Journal?) {
        self.journal = journal
        setupDefaults()
        openAccess = DatabaseManager.SharedInstance.newOpenAccess()
        openAccess.issue = self
        openAccess.create(json: json)
        update(metadata: json)
    }
    
    func setupDefaults() {
        coverImageDownload = DownloadStatus.notDownloaded.rawValue as NSNumber!
        purchased = false
        allArticlesDownloaded = false
        purchased = false
        isFreeIssue = false
    }
    
    func update(metadata: [String: AnyObject]) {
        if let coverImage = metadata["coverImage"] as? String {
            self.coverImage = coverImage != "" ? coverImage : nil
        }
        if let date = metadata["dateOfRelease"] as? String {
            let dateFormatter = DateFormatter(dateFormat: "YYYY-MM-dd")
            dateOfRelease = dateFormatter.date(from: date)
        }
        editors = metadata["editors"] as? String
        if let issueId = metadata["issueId"] as? Int {
            self.issueId = issueId as NSNumber
        }
        issueLabelDisplay = metadata["issueLabelDisplay"] as? String
        issueName = metadata["issueName"] as? String
        issueNumber = metadata["issueNumber"] as? String
        issuePii = metadata["issuePii"] as? String
        issueTitle = metadata["issueTitle"] as? String
        issueTypeDisplay = metadata["issueTypeDisplay"] as? String
        if let date = metadata["lastModified"] as? String {
            let dateFormatter = DateFormatter(dateFormat: "YYYY-MM-dd HH:mm:ss")
            lastModified = dateFormatter.date(from: date)
        }
        pageRange = metadata["pageRange"] as? String
        productId = metadata["productId"] as? String
        price = metadata["price"] as? String
        releaseDateAbbrDisplay = metadata["releaseDateAbbrDisplay"] as? String
        releaseDateDisplay = metadata["releaseDateDisplay"] as? String
        sequence = metadata["sequence"] as? String
        specialEditors = metadata["specialEditors"] as? String
        volume = metadata["volume"] as? String
        
        if let isFreeIssue = metadata["isFreeIssue"] as? String {
            self.isFreeIssue = Int(isFreeIssue) as NSNumber!
        }
    }
}
