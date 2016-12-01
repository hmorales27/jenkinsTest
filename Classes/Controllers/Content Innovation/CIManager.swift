//
//  CIManager.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 1/22/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol CIManagerDelegate: class {
    func contentInnovationShouldHideButton()
    func contentInnovationShouldShowButton(_ textToShow: String, buttonToShow: String)
}

class CIManager: CIControllerDelegate {
    
    var article: Article?
    var journal: Journal?
    
    var fullText: Bool?
    
    var delegate: CIManagerDelegate?
    
    var networkCallCompleted = true
    
    var ciExists: Bool = false
    var response: CIResponse?
    
    let internet = Reachability(hostName: "www.google.com")
    
    var task: URLSessionDataTask?
    
    var ciRequestHasBeenMade: Bool?
    
    // MARK: Initializers
    
    init() {
        setupReachability()
    }
    
    // MARK: Networking
    
    func getContentInnovation(article: Article, journal: Journal, fullText: Bool) {
        clearContentInnovation()
        
        self.article = article
        self.journal = journal
        self.fullText = fullText
        
        if (internet?.isReachable())! {
            guard let issn = journal.issn, let articlePii = article.articleInfoId else {
                return
            }
            let urlString = Strings.ContentInnovation.URL + "?issn=\(issn)&articlepii=\(articlePii)"
            
            guard let url = URL(string: urlString) else {
                return
            }
            var request = URLRequest(url: url)
            if fullText {
                let text = NSString(string: "ftext").aes256Encrypt(withKey: "kEyLI1Fy648tzWXGuRcxrg==")
                request.addValue(text! as String, forHTTPHeaderField: "arttype")
            }
            request.addValue(Strings.CIConsumerID, forHTTPHeaderField: "consumerid")
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: request, completionHandler: { (responseData, response, responseError) -> Void in
                guard let data = responseData else {
                    self.networkCallCompleted = true
                    return
                }
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] else {
                        return
                    }
                    self.response = CIResponse(metadata: json)
                    if self.response?.articlePii == self.article?.articleInfoId && self.response?.widgetModel.count > 0 {
                        self.ciExists = true
                        self.delegate?.contentInnovationShouldShowButton(self.response!.widgetFeatureMessage, buttonToShow: self.response!.articleCIIconName)
                    }
                } catch {
                    
                }
            })
            task.resume()
        }
    }
    
    // MARK: Cleanup
    
    func clearContentInnovation() {
        delegate?.contentInnovationShouldHideButton()
        article = nil
        journal = nil
        fullText = nil
        ciExists = false
        ciRequestHasBeenMade = nil
        task?.cancel()
        task = nil
    }
    
    
    // MARK: Reachability
    
    func setupReachability() {
        internet?.reachableBlock = { response in
            performOnMainThread({ 
                self.internetAvailable()
            })
        }
        internet?.unreachableBlock = { response in
            performOnMainThread({ 
                self.internetUnavailable()
            })
        }
        internet?.startNotifier()
    }
    
    func internetAvailable() {
        
    }
    
    func internetUnavailable() {
        
    }
    
    // CI Delegate
    
    func numberOfContentInnovations() -> Int {
        if let count = self.response?.widgetModel.count {
            return count
        }
        return 0
    }
    
    func configureContentInnovationCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let item = contentInnovationWidgetForIndexPath(indexPath)
        cell.textLabel?.text = item?.widgetName
    }
    
    func contentInnovationWidgetForIndexPath(_ indexPath: IndexPath) -> CIWidget? {
        return self.response?.widgetModel[(indexPath as NSIndexPath).row]
    }
    
    func shouldClearContentInnovation() {
        self.clearContentInnovation()
        self.delegate?.contentInnovationShouldHideButton()
    }
    
    func contentInnovationTitle() -> String {
        if let title = self.response?.contentInnovationTitle { return title }
        return "Content Innovation"
    }
    
    func contentInnovationAccessibilityLabel() -> String {
        if let accessibilityTitle = self.response?.accessibilityTitle { return accessibilityTitle }
        return "Content Innovation"
    }
    
    func contentInnovationWidgetForInt(_ int: Int) -> CIWidget? {
        return self.response?.widgetModel[int]
    }
}
