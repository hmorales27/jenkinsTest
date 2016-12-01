//
//  ContentKit+Old.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/31/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

extension ContentKit {
    
    /*private func updateJournalIssues(_ journal:Journal, completion:@escaping (_ success:Bool)->()) {
        let currentDate = Date()
        api.downloadJournalIssuesMetadata(journal) { (success, response) -> () in
            DispatchQueue.main.async(execute: { () -> Void in
                guard success == true, let json = response else {
                    completion(false)
                    return
                }
                guard let issuesJSON = json["ISSUES"] as? [[String: AnyObject]] else {
                    completion(false)
                    return
                }
                for issueJSON in issuesJSON {
                    self.database.addOrUpdateIssue(issueJSON, journal: journal)
                }
                if let aimScopeHTML = json["aim_scope_html"] as? String {
                    journal.aimScopeHTML = aimScopeHTML
                }
                if let editorialHTML = json["editorial_html"] as? String {
                    journal.editorialHTML = editorialHTML
                }
                self.database.save()
                
                let dateformatter = DateFormatter(dateFormat: "YYYY-MM-dd HH:mm:ss")
                let date = dateformatter.string(from: currentDate)
                UserDefaults.standard.setValue(date, forKey: "\(Strings.API.DateKeys.Issues)-\(journal.issn)")
                
                MKStoreManager.shared().sendingProductRequests()
                
                completion(true)
            })
        }
    }*/
    
    
    func updateNewIssues(journal: Journal, completion:@escaping (_ newIssue: Issue?)->()) {
        /*let currentDate = Date()
         api.fetchNewIssues(journal: journal) { (success, response) in
         performOnMainThread({
         guard success == true, let json = response else {
         completion(nil)
         return
         }
         guard let issuesJSON = json["ISSUES"] as? [[String: AnyObject]] else {
         completion(nil)
         return
         }
         var issues: [Issue] = []
         for issueJSON in issuesJSON {
         if let issue = self.database.addOrUpdateIssue(issueJSON, journal: journal) {
         issues.append(issue)
         }
         }
         journal.aimScopeHTML = json["aim_scope_html"] as? String
         journal.editorialHTML = json["editorial_html"] as? String
         self.database.save()
         
         let dateformatter = DateFormatter(dateFormat: "YYYY-MM-dd HH:mm:ss")
         let date = dateformatter.string(from: currentDate)
         UserDefaults.standard.setValue(date, forKey: Strings.API.DateKeys.Issues)
         
         var issue: Issue?
         if issues.count > 0 {
         issues.sort(by: { $0.dateOfRelease!.compare($1.dateOfRelease!) == ComparisonResult.orderedDescending })
         issue = issues[0]
         }
         
         MKStoreManager.shared().sendingProductRequests()
         
         completion(issue)
         })
         }*/
    }
}
