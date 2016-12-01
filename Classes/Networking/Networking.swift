
//
//  Networking.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/25/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import Alamofire

class Networking {
    
    static let BaseURL = "https://content-dev.elsevier-jbs.com/metadata"
    static let session = URLSession(configuration: URLSessionConfiguration.default)
    private static let metadataQueue = DispatchQueue(label: "\(Strings.AppShortCode)-MetadataQueue")
    
    // MARK: - App -
    
    static func AppMetadataService(appShortCode: String, completion:@escaping(Bool)->()) {
        guard let request = AppMetadataServiceRequest(appShortCode: appShortCode) else {
            completion(false)
            return
        }
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: metadataQueue, options: .allowFragments, completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    guard let metadata = json as? [String: AnyObject] else {
                        completion(false)
                        return
                    }
                    guard let appMetadata = metadata["app"] as? [String: AnyObject] else {
                        completion(false)
                        return
                    }
                    DatabaseManager.SharedInstance.performChangesAndSave {
                        let app = DatabaseManager.SharedInstance.addOrUpdateApp(metadata: appMetadata)
                        if let journalsMetadata = appMetadata["journals"] as? [[String: AnyObject]] {
                            for journalMetadata in journalsMetadata {
                                let journal = DatabaseManager.SharedInstance.addOrUpdateJournal(metadata: journalMetadata)
                                journal?.publisher = app
                                if let issueMetadata = journalMetadata["issue"] as? [String: AnyObject] {
                                    let issue = DatabaseManager.SharedInstance.addOrUpdateIssue(metadata: issueMetadata)
                                    issue?.journal = journal
                                }
                            }
                        }
                        completion(true)
                    }
                    return
                case .failure:
                    completion(false)
                }
            }
        )
    }
    
    static private func AppMetadataServiceRequest(appShortCode: String) -> URLRequest? {
        let urlString = "\(BaseURL)/app/\(appShortCode)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue(Strings.ContentServiceConsumerId, forHTTPHeaderField: "consumerid")
        return request
    }
    
    // MARK: - Journal -
    
    static func JournalService(issn: String, completion:@escaping(Bool)->()) {
        guard let request = JournalServiceRequest(issn: issn) else {
            completion(false)
            return
        }
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: metadataQueue, options: .allowFragments, completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    guard let journalMetadata = json as? [String: AnyObject] else {
                        completion(false)
                        return
                    }
                    DatabaseManager.SharedInstance.performChangesAndSave {
                        let journal = DatabaseManager.SharedInstance.addOrUpdateJournal(metadata: journalMetadata)
                        if let issueMetadata = journalMetadata["issue"] as? [String: AnyObject] {
                            let issue = DatabaseManager.SharedInstance.addOrUpdateIssue(metadata: issueMetadata)
                            issue?.journal = journal
                        }
                        completion(true)
                    }
                    return
                case .failure:
                    completion(false)
                }
            }
        )
    }
    
    static private func JournalServiceRequest(issn: String) -> URLRequest? {
        let urlString = "\(BaseURL)/journal/\(issn)/\(Strings.AppShortCode)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue(Strings.ContentServiceConsumerId, forHTTPHeaderField: "consumerid")
        return request
    }
    
    // MARK: - Journal Issues -
    
    static func IssueListService(issn: String, completion:@escaping(Bool)->()) {
        guard let request = IssueListServiceRequest(issn: issn) else {
            completion(false)
            return
        }
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: metadataQueue, options: .allowFragments, completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    let responseMetadata = json as? [String: AnyObject]
                    guard let issuesMetadata = responseMetadata?["issues"] as? [[String: AnyObject]] else {
                        completion(false)
                        return
                    }
                    DatabaseManager.SharedInstance.performChangesAndSave {
                        let journal = DatabaseManager.SharedInstance.getJournal(issn: issn)
                        for issueMetadata in issuesMetadata {
                            let issue = DatabaseManager.SharedInstance.addOrUpdateIssue(metadata: issueMetadata)
                            issue?.journal = journal
                        }
                        DatabaseManager.SharedInstance.save()
                        completion(true)
                    }
                    return
                case .failure:
                    completion(false)
                }
            }
        )
    }
    
    static private func IssueListServiceRequest(issn: String) -> URLRequest? {
        let urlString = "\(BaseURL)/issue/list/\(issn)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue(Strings.ContentServiceConsumerId, forHTTPHeaderField: "consumerid")
        return request
    }
    
    // https://content-dev.elsevier-jbs.com/metadata/issue/list/{issn}
    
    // MARK: - Issue -

    static func IssueService(issn: String, issuePii: String, completion:@escaping (Bool)->()) {
        guard let request = IssueServiceRequest(issn: issn, issuePii: issuePii) else {
            completion(false)
            return
        }
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: metadataQueue, options: .allowFragments, completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    let responseMetadata = json as? [String: AnyObject]
                    guard let issueMetadata = responseMetadata?["issue"] as? [String: AnyObject] else {
                        completion(false)
                        return
                    }
                    DatabaseManager.SharedInstance.performChangesAndSave {
                        let issue = DatabaseManager.SharedInstance.addOrUpdateIssue(metadata: issueMetadata)
                        if let journal = DatabaseManager.SharedInstance.getJournal(issn: issn) {
                            issue?.journal = journal
                        }
                        completion(true)
                    }
                    return
                case .failure:
                    completion(false)
                }
            }
        )
    }
    static func CrossmarkServiceRequest(issn:String, articlePii: String) -> URLRequest? {
        let urlString = "https://content-dev.elsevier-jbs.com/content/crossmark/\(issn)/\(articlePii)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue(Strings.ContentServiceConsumerId, forHTTPHeaderField: "consumerid")
        return request
    }
    static private func IssueServiceRequest(issn: String, issuePii: String) -> URLRequest? {
        let urlString = "\(BaseURL)/issue/\(issn)/\(issuePii)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue(Strings.ContentServiceConsumerId, forHTTPHeaderField: "consumerid")
        return request
    }
    
    // MARK: - Issue Articles -
    
    static func IssueArticlesService(issn: String, issuePii: String, completion:@escaping (Bool)->()) {
        guard let request = IssueArticlesServiceRequest(issn: issn, issuePii: issuePii) else {
            completion(false)
            return
        }
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: metadataQueue, options: .allowFragments, completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    let responseMetadata = json as? [String: AnyObject]
                    guard let articlesMetadata = responseMetadata?["articles"] as? [[String: AnyObject]] else {
                        completion(false)
                        return
                    }
                    
                    
                    DatabaseManager.SharedInstance.performChangesAndSave {
                        let issue = DatabaseManager.SharedInstance.getIssue(issuePii)
                        let journal = DatabaseManager.SharedInstance.getJournal(issn: issn)
                        for articleMetadata in articlesMetadata {
                            let article = DatabaseManager.SharedInstance.addOrUpdateArticle(metadata: articleMetadata)
                            article?.issue = issue
                            article?.journal = journal
                        }
                        DatabaseManager.SharedInstance.save()
                        completion(true)
                    }
                    return
                case .failure:
                    completion(false)
                }
            }
        )
    }
    
    static private func IssueArticlesServiceRequest(issn: String, issuePii: String) -> URLRequest? {
        let urlString = "\(BaseURL)/article/list/\(issn)/\(issuePii)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue(Strings.ContentServiceConsumerId, forHTTPHeaderField: "consumerid")
        return request
    }
    
    // MARK: - Article -
    
    static func ArticleService(issn: String, issuePii: String, articlePii: String, completion:@escaping(Bool)->()) {
        guard let request = ArticleServiceRequest(issn: issn, issuePii: issuePii, articlePii: articlePii) else {
            completion(false)
            return
        }
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: metadataQueue, options: .allowFragments, completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    let responseMetadata = json as? [String: AnyObject]
                    guard let issueMetadata = responseMetadata?["issue"] as? [String: AnyObject] else {
                        completion(false)
                        return
                    }
                    guard let articleMetadata = responseMetadata?["article"] as? [String: AnyObject] else {
                        completion(false)
                        return
                    }
                    DatabaseManager.SharedInstance.performChangesAndSave {
                        let article = DatabaseManager.SharedInstance.addOrUpdateArticle(metadata: articleMetadata)
                        if let issue = DatabaseManager.SharedInstance.addOrUpdateIssue(metadata: issueMetadata) {
                            article?.issue = issue
                        }
                        DatabaseManager.SharedInstance.save()
                        completion(true)
                    }
                    return
                case .failure:
                    completion(false)
                }
            }
        )
    }
    
    static func ArticleServiceRequest(issn: String, issuePii: String, articlePii: String) -> URLRequest? {
        let urlString = "\(BaseURL)/article/\(issn)/\(issuePii)/\(articlePii)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue(Strings.ContentServiceConsumerId, forHTTPHeaderField: "consumerid")
        return request
    }
    
    // MARK: - Top Articles -
    
    static func MostReadService(issn: String, completion:@escaping(Bool)->()) {
        guard let request = MostReadServiceRequest(issn: issn) else {
            completion(false)
            return
        }
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: metadataQueue, options: .allowFragments, completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    let responseMetadata = json as? [String: AnyObject]
                    guard let issuesMetadata = responseMetadata?["issues"] as? [[String: AnyObject]] else {
                        completion(false)
                        return
                    }
                    guard let articlesMetadata = responseMetadata?["articles"] as? [[String: AnyObject]] else {
                        completion(false)
                        return
                    }
                    DatabaseManager.SharedInstance.performChangesAndSave {
                        
                        let journal = DatabaseManager.SharedInstance.getJournal(issn: issn)
                        
                        for issueMetadata in issuesMetadata {
                            let issue = DatabaseManager.SharedInstance.addOrUpdateIssue(metadata: issueMetadata)
                            issue?.journal = journal
                        }
                        
                        for articleMetadata in articlesMetadata {
                            
                            let article = DatabaseManager.SharedInstance.addOrUpdateArticle(metadata: articleMetadata)
                            article?.topArticle = DatabaseManager.SharedInstance.newTopArticle()
                            article?.journal = journal
                            if let issuePii = articleMetadata["issuePii"] as? String {
                                article?.issue = DatabaseManager.SharedInstance.getIssue(issuePii)
                            }
                        }
                        DatabaseManager.SharedInstance.save()
                        completion(true)
                    }
                    return
                case .failure:
                    completion(false)
                }
            }
        )

    }
    
    static private func MostReadServiceRequest(issn: String) -> URLRequest? {
        let urlString = "\(BaseURL)/article/list/mostread/\(issn)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue(Strings.ContentServiceConsumerId, forHTTPHeaderField: "consumerid")
        return request
    }
    
    // MARK: - AIP List -
    
    static func AIPListService(issn: String, completion:@escaping(Bool)->()) {
        guard let request = AipListServiceRequest(issn: issn) else {
            completion(false)
            return
        }
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: metadataQueue, options: .allowFragments, completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    let responseJson = json as? [String: AnyObject]
                    guard let aipsJson = responseJson?["aips"] as? [[String: AnyObject]] else {
                        completion(false)
                        return
                    }
                    DatabaseManager.SharedInstance.performChangesAndSave {
                        let journal = DatabaseManager.SharedInstance.getJournal(issn: issn)
                        for aipJSON in aipsJson {
                            let article = DatabaseManager.SharedInstance.addOrUpdateArticle(metadata: aipJSON)
                            article?.journal = journal
                        }
                        completion(true)
                    }
                    return
                case .failure:
                    completion(false)
                }
            }
        )
    }
    
    static private func AipListServiceRequest(issn: String) -> URLRequest? {
        let urlString = "\(BaseURL)/article/list/\(issn)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue(Strings.ContentServiceConsumerId, forHTTPHeaderField: "consumerid")
        return request
    }
    
    // MARK: - AIP Article -
    
    static func AipArticleService(issn: String, articlePii: String, completion:@escaping(Bool)->()) {
        guard let request = AipArticleServiceRequest(issn: issn, articlePii: articlePii) else {
            completion(false)
            return
        }
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: metadataQueue, options: .allowFragments, completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    let responseJson = json as? [String: AnyObject]
                    guard let articleJson = responseJson?["article"] as? [String: AnyObject] else {
                        completion(false)
                        return
                    }
                    DatabaseManager.SharedInstance.performChangesAndSave {
                        let article = DatabaseManager.SharedInstance.addOrUpdateArticle(metadata: articleJson)
                        if let journal = DatabaseManager.SharedInstance.getJournal(issn: issn) {
                            article?.journal = journal
                        }
                        completion(true)
                    }
                    return
                case .failure:
                    completion(false)
                }
            }
        )
    }
    
    static private func AipArticleServiceRequest(issn: String, articlePii: String) -> URLRequest? {
        let urlString = "\(BaseURL)/article/\(issn)/\(articlePii)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue(Strings.ContentServiceConsumerId, forHTTPHeaderField: "consumerid")
        return request
    }
    
}
