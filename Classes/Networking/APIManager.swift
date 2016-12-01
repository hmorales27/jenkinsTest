//
//  APIManager.swift
//  ContentKit
//
//  Created by Sharkey, Justin (ELS-CON) on 10/9/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit
import ZipArchive
import SWXMLHash

open class APIManager {
    
    static let sharedInstance = APIManager()
    
    // MARK: - Announcements -
    
    func downloadAnnouncementMetadata(completion: ((_ success: Bool)->())?) {
        guard let publisher = DatabaseManager.SharedInstance.getAppPublisher() else {
            completion?(false)
            return
        }
        let request = CKURLRequest.AnnouncementRequest("\(publisher.appId!)")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { (responseData, response, responseError) -> Void in
            guard let data = responseData else {
                completion?(false)
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                guard let announcements = json["DATA"] as? [[String: AnyObject]] else {
                    completion?(false)
                    return
                }
                performOnMainThread({
                    for announcement in announcements {
                        DatabaseManager.SharedInstance.addOrUpdateAnnouncement(announcement)
                    }
                    completion?(true)
                })
            } catch let error as NSError {
                completion?(false)
                log.error(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    // MARK: - App HTML -
    
    func downloadAppHTML() {
        downloadAppHTML { (success) -> () in
            
        }
    }
    
    func downloadAppHTML(_ completion:((_ success:Bool)->())?) {
        let request = CKURLRequest.AppHTML()
        log.warning(request.url!.absoluteString)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: { (responseData, response, responseError) -> Void in
            guard let data = responseData else {
                completion?(false)
                return
            }
            performOnMainThread {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
                        completion?(false)
                        return
                    }
                    let publisher = DatabaseManager.SharedInstance.getAppPublisher()
                    if let faq = json["faq"] as? String {
                        publisher?.faq = faq
                    }
                    if let terms = json["terms"] as? String {
                        publisher?.terms = terms
                    }
                    if let support = json["support"] as? String {
                        publisher?.support = support
                    }
                    DatabaseManager.SharedInstance.save()
                    completion?(true)
                } catch let error as NSError {
                    log.error(error.localizedDescription)
                    completion?(false)
                }
            }
        })
        task.resume()
    }
    
    // MARK: - App Images -
    
    func downloadAppImages(completion: ((Bool)->())? = nil) {
        var lm: String
        if let lastModified = UserDefaults.standard.value(forKey: "JBSMAppImagesUpdateDate") as? String {
            lm = lastModified
        } else {
            let dateFormatter = DateFormatter(dateFormat: "YYYY-MM-dd HH:mm:ss")
            lm = dateFormatter.string(from: Date(timeIntervalSince1970: 0))
        }
        
        var url = Strings.Content.AppImages(nil)
        log.verbose(url)
        url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        var request = URLRequest(url: URL(string: url)!)
        request.addValue(Strings.CIConsumerID, forHTTPHeaderField: "consumerid")
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.downloadTask(with: request, completionHandler: { (responseURL, response, responseError) -> Void in
            if let error = responseError {
                log.error(error.localizedDescription)
                completion?(false)
                return
            }
            if let url = responseURL {
                do {
                    try SSZipArchive.unzipFile(atPath: url.path, toDestination: CachesDirectoryPath, overwrite: true, password: nil)
                    UserDefaults.standard.setValue(lm, forKey: "JBSMAppImagesUpdateDate")
                    completion?(true)
                    return
                } catch let error as NSError {
                    log.error(error.localizedDescription)
                }
            }
            completion?(false)
        })
        task.resume()
    }
    
    // MARK: - Brand Images -
    
    func getBrandImagesForJournal(_ journal: Journal, success:((Bool)->Void)?) {
        guard let request = CKURLRequest.JournalBrandingImage(journal) else {
            success?(false)
            return
        }
        log.verbose(request.url!.absoluteString)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.downloadTask(with: request, completionHandler: { (responseURL, response, responseError) -> Void in
            if let error = responseError {
                log.error(error.localizedDescription)
                success?(false)
                return
            }
            if let url = responseURL {
                do {
                    let path = url.path
                    try SSZipArchive.unzipFile(atPath: path, toDestination: journal.brandImagesPath, overwrite: true, password: nil)
                    success?(true)
                } catch let error as NSError {
                    log.error(error.localizedDescription)
                    success?(false)
                }
            }
        })
        task.resume()
    }
    
    // MARK: - Cover Image -
    
    func coverImage(issue: Issue, success:((Bool)->Void)?) {
        _coverImage(issue: issue) { (_success) in
            DatabaseManager.SharedInstance.performChangesAndSave({
                if _success == true {
                    issue.coverImageDownload = DownloadStatus.downloaded.rawValue as NSNumber!
                } else {
                    issue.coverImageDownload = DownloadStatus.downloadFailed.rawValue as NSNumber!
                }
                performOnMainThread({
                    NotificationCenter.default.post(name: Foundation.Notification.Name.CoverImageDownloadUpdated, object: issue)
                    success?(_success)
                })
            })
        }
    }
    
    private func _coverImage(issue: Issue, success:@escaping ((Bool)->Void)) {
        
        guard let request = JBSMURLRequest.V2.CoverImage(issue: issue) else {
            log.warning("Cover Image Doesn't Exist")
            success(false)
            return
        }
        log.verbose(request.url!.absoluteString)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        issue.coverImageDownload = DownloadStatus.downloading.rawValue as NSNumber!
        let task = session.downloadTask(with: request, completionHandler: { (responseURL, response, responseError) -> Void in
            
            if let error = responseError {
                log.error(error.localizedDescription)
                success(false)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                success(false)
                return
            }
            
            guard response.statusCode != 404 else {
                log.error("404: Cover Image Not Found")
                success(false)
                return
            }
            
            if response.statusCode == 200 {
                
                guard let downloadedPath = responseURL?.path else {
                    log.error("Unable To Get Downloaded URL Path")
                    success(false)
                    return
                }
                
                guard let destinationPath = issue.coverImagePath else {
                    log.error("Unable To Create Destination Path")
                    success(false)
                    return
                }
                
                do {
                    if FileSystemManager.sharedInstance.pathExists(destinationPath) {
                        FileSystemManager.sharedInstance.deleteFile(destinationPath)
                    }
                    try FileManager.default.moveItem(atPath: downloadedPath, toPath: destinationPath)
                    success(true)
                } catch let error as NSError {
                    log.error(error.localizedDescription)
                    success(false)
                    return
                }
            }
        })
        task.resume()
    }
    
    // MARK: - CSS -
    
    func getCSSForJournal(_ journal: Journal, success: ((Bool)->Void)?) {
        guard let request = JBSMURLRequest.V2.ThemeRequest(journal: journal, lastModified: nil, deviceType: .Tablet) else { return }
        log.verbose(request.url!.absoluteString)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.downloadTask(with: request, completionHandler: { (responseURL, response, responseError) -> Void in
            if let error = responseError {
                log.error(error.localizedDescription)
                success?(false)
                return
            }
            if let url = responseURL {
                do {
                    try SSZipArchive.unzipFile(atPath: url.path, toDestination: journal.basePath, overwrite: true, password: nil)
                    success?(true)
                } catch let error as NSError {
                    log.error(error.localizedDescription)
                    success?(false)
                }
            }
        })
        task.resume()
    }
    
    // MARK: - IP Auth -
    
    func ipAuthentication(authtoken: String?, ip: String?, completion: @escaping (_ success:Bool)->()) {
        guard let request = JBSMURLRequest.V2.Login.IPAuthentication(authtoken, ip: ip) else { return }
        log.verbose(request.url!.absoluteString)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: { (responseData, response, responseError) -> Void in
            guard let data = responseData,
                let response = response as? HTTPURLResponse else {
                    completion(false)
                    return
            }
            switch response.statusCode {
            case 200:
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        IPInfo.Instance.setupAuthentication(json)
                        completion(true)
                        return
                    }
                } catch let error as NSError {
                    log.error(error.localizedDescription)
                }
            default:
                break
            }
            completion(false)
        })
        task.resume()
    }
    
    func ipAuthorization(_ completion: @escaping (_ success:Bool)->()) {
        guard let authtoken = IPInfo.AuthToken else { return }
        guard let request = JBSMURLRequest.V2.Login.IPAuthorization(authtoken, ip: nil) else { return }
        log.verbose(request.url!.absoluteString)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: { (responseData, response, responseError) -> Void in
            if let error = responseError {
                log.error(error.localizedDescription)
                completion(false)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(false)
                return
            }
            guard let data = responseData else {
                completion(false)
                return
            }
            log.info("IP Autz Response Code: \(response.statusCode)")
            switch response.statusCode {
            case 200:
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        IPInfo.Instance.setupAuthorization(json)
                        completion(true)
                        return
                    }
                } catch let error as NSError {
                    log.error(error.localizedDescription)
                }
            default:
                break
            }
            completion(true)
        })
        task.resume()
    }
    
    func reportUsageForArticle(_ article: Article, formatType: ArticleFormatType, completion: ((Bool)->Void)?) {
        guard let request = CKURLRequest.IPUsageReport(article: article, formatType: formatType) else { return }
        log.verbose(request.url!.absoluteString)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (responseData, response, responseError) -> Void in
            if let error = responseError {
                log.error(error.localizedDescription)
                completion?(false)
                return // false
            }
            if let data = responseData {
                if let responseString = String(data: data, encoding: String.Encoding.utf8) {
                    if responseString == Strings.IPAuth.UsageAuthorized {
                        completion?(true)
                        return
                    }
                }
            }
            completion?(false)
            return
        })
        task.resume()
    }
    
    // MARK: - Liscenses -
    
    func downloadLiscenses(_ completion:((_ success: Bool)->())?) {
        guard let request = JBSMURLRequest.V2.Content.Liscences() else {
            completion?(false)
            return
        }
        log.verbose(request.url!.absoluteString)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: { (responseData, response, responseError) in
            guard let data = responseData else {
                completion?(false)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
                    let basePath = CachesDirectoryPath + "Licenses"
                    if !FileSystemManager.sharedInstance.pathExists(basePath) {
                        let _ = FileSystemManager.sharedInstance.createPath(basePath)
                    }
                    
                    
                    if let licenses = json["LICENSES"] as?  [[String: AnyObject]] {
                        for license in licenses {
                            if let name = license["lic_name"] as? String, let html = license["html_content"] as? String {
                                let htmlPath = basePath + "/\(name).html"
                                if FileSystemManager.sharedInstance.fileExists(htmlPath) {
                                    FileSystemManager.sharedInstance.deleteFile(htmlPath)
                                }
                                do {
                                    try html.write(toFile: htmlPath, atomically: true, encoding: String.Encoding.utf8)
                                } catch let error as NSError {
                                    log.error(error.localizedDescription)
                                }
                            }
                            
                        }
                    }
                    completion?(true)
                    return
                }
            } catch let error as NSError {
                log.error(error.localizedDescription)
            }
            completion?(false)
        })
        task.resume()
    }
    
    // MARK: - Login -
    
    struct LoginInfo {
        var journal: Journal
        var partner: Partner
    }
    
    func multiPartnerList(_ success: ((Bool)->Void)?) {
        guard let request = JBSMURLRequest.V2.Login.MultiPartnerList() else {
            success?(false)
            return
        }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: { (responseData, response, responseError) -> Void in
            guard let data = responseData else {
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                    success?(false)
                    return
                }
                guard let journalsJSON = json["journal"] as? [[String: Any]] else {
                    success?(false)
                    return
                }
                DatabaseManager.SharedInstance.addOrUpdatePartners(json: journalsJSON)
                
            } catch let error {
                print(error.localizedDescription)
                success?(false)
            }
        })
        task.resume()
    }

    func loginAll(partnerId: Int, userName: String, password: String, rememberMe: Bool) {
        
        var list: [LoginInfo] = []
        
        for journal in DatabaseManager.SharedInstance.getAllJournals() {
            if journal.authentication == .none {
                for partner in journal.allPartners {
                    if partner.partnerId?.intValue == partnerId {
                        list.append(LoginInfo(journal: journal, partner: partner))
                    }
                }
            }
        }
        
        for item in list {
            APIManager.sharedInstance.singleLogin(item.partner, journal: item.journal, userName: userName, password: password, rememberMe: true)
        }
    }
    
    fileprivate func singleLogin(_ partner: Partner, journal: Journal, userName: String, password: String, rememberMe: Bool) {
        loginPartnerAuthentication(partner, userName: userName, password: password, rememberMe: true, completion: { (success, authentication) in
            guard success == true else { return }
            guard let authentication = authentication else { return }
            APIManager.sharedInstance.loginAuthorization(authentication, journal: journal, completion: { (authorized) in
                guard authorized == true else { return }
                authentication.partner = partner
            })
        })
    }
    
    func loginPartnerAuthentication(_ partner: Partner, userName: String, password: String, rememberMe: Bool, completion:@escaping (_ success: Bool, _ authentication: Authentication?)->()) {
        guard let partnerId = partner.partnerId else {
            completion(false, nil)
            return
        }
        
        let encryptedUserName = NSString(string: userName).aes256Encrypt(withKey: Strings.EncryptionKey)
        let encryptedPassword = NSString(string: password).aes256Encrypt(withKey: Strings.EncryptionKey)
        
        guard let request = JBSMURLRequest.V2.Login.LoginAuthentication(partnerId: "\(partnerId)", userName: encryptedUserName!, password: encryptedPassword!, rememberMe: rememberMe) else {
            completion(false, nil)
            return
        }
        log.verbose(request.url!.absoluteString)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: { (responseData, response, responseError) -> Void in
            guard let response = response as? HTTPURLResponse, let data = responseData else {
                completion(false, nil)
                return
            }
            switch response.statusCode {
            case 200:
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        DatabaseManager.SharedInstance.performChangesAndSave({
                            let authentication = DatabaseManager.SharedInstance.newAuthentication()
                            authentication.userId     = json["userId"]    as? String
                            authentication.loginId    = json["login"]     as? String
                            authentication.sessionId  = json["session"]   as? String
                            authentication.emailId    = json["email"]     as? String
                            authentication.firstName  = json["firstName"] as? String
                            authentication.lastName   = json["lastName"]  as? String
                            authentication.idp        = json["idp"]       as? String
                            authentication.partner    = partner
                            authentication.password   = encryptedPassword
                            authentication.rememberMe = rememberMe as NSNumber?
                            completion(true, authentication)
                        })
                    } else {
                        completion(false, nil)
                    }
                } catch let error as NSError {
                    log.error(error.localizedDescription)
                    completion(false, nil)
                }
            default:
                let error = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                log.error(error)
                completion(false, nil)
            }
        })
        task.resume()
    }

    
    func loginAuthorization(_ authentication: Authentication, journal: Journal, completion:@escaping (_ authorized: Bool)->()) {
        let issn = journal.issn.insert("-", ind: 4)
        guard let sessionId = authentication.sessionId, let idp = authentication.idp else {
            completion(false)
            return
        }
        guard let request = JBSMURLRequest.V2.Login.LoginAuthorization(sessionId, productId: issn, idp: idp) else {
            return
        }
        log.verbose(request.url!.absoluteString)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: { (responseData, response, responseError) -> Void in
            guard let response = response as? HTTPURLResponse, let data = responseData else {
                return
            }
            
            performOnMainThread({
                switch response.statusCode {
                case 200:
                    if let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        if responseString == "authorized" {
                            journal.authentication = authentication
                            DatabaseManager.SharedInstance.save()
                            completion(true)
                            return
                        }
                    }
                default:
                    break
                }
                DatabaseManager.SharedInstance.moc?.delete(authentication)
                completion(false)
            })
        })
        task.resume()
    }
    
    // MARK: - Media File -
    
    func downloadMediaFile(_ media: Media) {
        
        guard let requestURL = JBSMURLRequest.V2.MediaURL(media: media, download: true) else { return }
        log.warning(requestURL.absoluteString)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        DatabaseManager.SharedInstance.performChangesAndSave({
            media.downloadStatus = .downloading
        })
        
        let task = session.downloadTask(with: requestURL, completionHandler: { (responseURL, response, responseError) in
            
            guard let url = responseURL else {
                DatabaseManager.SharedInstance.performChangesAndSave({
                    media.downloadStatus = .downloadFailed
                })
                log.error("Unable to get Response URL")
                return
            }
            
            do {
                let basePath = media.articleType == .fullText ? media.article.fulltextSupplementDirectory : media.article.abstractSupplementDirectory
                if !FileManager.default.fileExists(atPath: basePath) {
                    try FileManager.default.createDirectory(atPath: basePath, withIntermediateDirectories: true, attributes: nil)
                }
            } catch let error as NSError {
                DatabaseManager.SharedInstance.performChangesAndSave({
                    media.downloadStatus = .downloadFailed
                })
                log.error(error.localizedDescription)
                return
            }
            
            guard let data = try? Data(contentsOf: url) else {
                DatabaseManager.SharedInstance.performChangesAndSave({
                    media.downloadStatus = .downloadFailed
                })
                log.error("Unable to get Contents of URL")
                return
            }
            
            do {
                try data.write(to: media.pathURL, options: .atomic)
                DatabaseManager.SharedInstance.performChangesAndSave({
                    media.downloadStatus = .downloaded
                })
            } catch let error as NSError {
                log.error(error.localizedDescription)
                DatabaseManager.SharedInstance.performChangesAndSave({
                    media.downloadStatus = .downloadFailed
                })
                return
            }
        })
        task.resume()
    }
    
    // MARK: - Open Access
    
    func downloadOpenAccessInformation() {
        downloadOpenAccessInformation { (success) -> () in
            
        }
    }
    
    func downloadOpenAccessInformation(_ completion:(_ success:Bool)->()) {
        let request = CKURLRequest.JournalOpenAccess()
        log.verbose(request.url!.absoluteString)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: { (responseData, response, responseError) -> Void in
            performOnMainThread({
                guard let data = responseData else {
                    return
                }
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] else {
                        return
                    }
                    guard let metadata = json["METADATA"] as? [String: AnyObject] else {
                        return
                    }
                    if let issues = metadata["ISSUES"] as? [[String: AnyObject]] {
                        for issue in issues {
                            DatabaseManager.SharedInstance.addOrUpdateOpenAccess(issue)
                        }
                    }
                    if let articles = metadata["ARTICLES"] as? [[String: AnyObject]] {
                        for article in articles {
                            DatabaseManager.SharedInstance.addOrUpdateOpenAccess(article)
                        }
                    }
                } catch let error as NSError {
                    log.error(error.localizedDescription)
                }
            })
        })
        task.resume()
    }
    
    // MARK: - PDF -
    
    func downloadPDF(article: Article, completion: @escaping (_ success: Bool)->()) {
        
        guard let request = JBSMURLRequest.V2.ArticlePDFRequest(article: article) else { return }
        log.verbose(request.url!.absoluteString as AnyObject?)
        
        DatabaseManager.SharedInstance.performChangesAndSave {
            article.downloadInfo.pdfDownloadStatus = .downloading
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.downloadTask(with: request, completionHandler: { (responseURL, response, responseError) in
            guard let url = responseURL else {
                DatabaseManager.SharedInstance.performChangesAndSave {
                    article.downloadInfo.pdfDownloadStatus = .downloadFailed
                    completion(false)
                }
                return
            }
            do {
                try SSZipArchive.unzipFile(atPath: url.path, toDestination: article.journal.pdfPath, overwrite: true, password: nil)
                DatabaseManager.SharedInstance.performChangesAndSave {
                    article.downloadInfo.pdfDownloadStatus = .downloaded
                    completion(true)
                }
                return
            } catch let error as NSError {
                log.error(error.localizedDescription)
            }
            DatabaseManager.SharedInstance.performChangesAndSave {
                article.downloadInfo.pdfDownloadStatus = .downloadFailed
                completion(false)
            }
        })
        task.resume()
    }
    
    func downloadIssueHighlightArticles(issue: Issue, completion: @escaping (_ success: Bool, _ response: [String: AnyObject]?)->()) {
        guard let request = JBSMURLRequest.V2.Metadata.ArticlesHighlightRequest(issue: issue) else {
            completion(false, nil)
            return
        }
        log.verbose("Issue Articles: \(request)")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { (responseData, response, responseError) -> Void in
            guard let data = responseData else {
                completion(false, nil)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                    completion(true, json)
                    return
                }
            } catch let error as NSError {
                log.error(error.localizedDescription)
            }
            completion(false, nil)
        }
        task.resume()
    }
}
