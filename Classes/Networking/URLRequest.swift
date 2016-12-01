/*
 * CKURLRequest
*/

import UIKit

extension URLComponents {
    
    mutating func addQueryItem(_ item: URLQueryItem) {
        if queryItems != nil {
            queryItems!.append(item)
        } else {
            queryItems = [item]
        }
    }
    
    mutating func addQueryItem(name: String, value: String?) {
        let item = URLQueryItem(name: name, value: value)
        if queryItems != nil {
            queryItems!.append(item)
        } else {
            queryItems = [item]
        }
    }
    
}

enum ThemeRequestDeviceType: String {
    case Mobile = "mobile"
    case Tablet = "tablet"
}

enum MediaType: String {
    case XML = "application/xml"
    case JSON = "application/json"
    
}

class JBSMURLRequest {
    
    class V1 {
        
        class func AppMetadata() -> Foundation.URLRequest? {
            guard var component = URLComponents(string: Strings.BaseIndexURL) else {
                return nil
            }
            component.addQueryItem(URLQueryItem(name: "appid", value: Strings.AppShortCode))
            guard let url = component.url else {
                return nil
            }
            return Foundation.URLRequest(url: url)
        }

        class func ArticlesMetadataRequest(issue: Issue) -> Foundation.URLRequest? {
            let urlString = Strings.BaseUrl + "?" + "urlcode=issues" + "&" + "jid=\(issue.journal.journalId)" + "&" + "issues=\(issue.issuePii)" + "&" + "appid=\(Strings.AppShortCode)"
            if let url = URL(string: urlString) {
                return Foundation.URLRequest(url: url)
            }
            return nil
        }
        
        class func ContentInnovationRequest(article: Article) -> Foundation.URLRequest? {
            let urlString = Strings.ContentInnovation.URL + "?issn=\(article.journal.issn)&articlepii=\(article.articleInfoId)"
            if let url = URL(string: urlString) {
                var request = URLRequest(url: url)
                if let artType = NSString(string: "ftext").aes256Encrypt(withKey: Strings.EncryptionKey) {
                    request.addValue(artType, forHTTPHeaderField: "arttype")
                    request.addValue(Strings.CIConsumerID, forHTTPHeaderField: "consumerid")
                    return request as URLRequest
                }
            }
            return nil
        }
        
        class func IssueCoverImageRequest(_ issue:Issue) -> Foundation.URLRequest? {
            guard let coverImage = issue.coverImage else {
                return nil
            }
            guard let baseContentURL = issue.journal.baseContentURL45 else {
                return nil
            }
            let url = URL(string: baseContentURL + "cover/" + coverImage)!
            return Foundation.URLRequest(url: url)
        }
        
        class func IssuesMetadataRequest(journal: Journal) -> Foundation.URLRequest? {
            var urlBuilder = URLComponents(string: Strings.BaseUrl)
            urlBuilder?.addQueryItem(name: "appid", value: Strings.AppShortCode)
            if let journalId = journal.journalId {
                urlBuilder?.addQueryItem(name: "jid", value: String(describing: journalId))
            }
            urlBuilder?.addQueryItem(name: "urlcode", value: "issues")
            if let date = UserDefaults.standard.value(forKey: "\(Strings.API.DateKeys.Issues)-\(journal.issn)") as? String {
                urlBuilder?.addQueryItem(name: "date", value: date)
            }
            guard let url = urlBuilder?.url else {
                return nil
            }
            return Foundation.URLRequest(url: url)
        }
    }
    
    class V2 {
        
        class Metadata {
            
            class func ArticlesRequest(issue: Issue) -> Foundation.URLRequest? {
                var urlBuilder = URLComponents(string: Strings.BaseIndexURL)
                urlBuilder?.addQueryItem(URLQueryItem(name: "appid", value: Strings.AppShortCode))
                if let journalId = issue.journal.journalId {
                    urlBuilder?.addQueryItem(URLQueryItem(name: "jid", value: String(describing: journalId)))
                }
                urlBuilder?.addQueryItem(URLQueryItem(name: "issues", value: issue.issuePii))
                urlBuilder?.addQueryItem(URLQueryItem(name: "urlcode", value: "issues"))
                if let url = urlBuilder?.url {
                    return Foundation.URLRequest(url: url)
                }
                return nil
            }
            
            class func ArticlesHighlightRequest(issue: Issue) -> URLRequest? {
                var urlBuilder = URLComponents(string: Strings.BaseIndexURL)
                urlBuilder?.addQueryItem(URLQueryItem(name: "appid", value: Strings.AppShortCode))
                urlBuilder?.addQueryItem(URLQueryItem(name: "jid", value: String(issue.journal.journalId.intValue)))
                urlBuilder?.addQueryItem(URLQueryItem(name: "issues", value: issue.issuePii))
                urlBuilder?.addQueryItem(URLQueryItem(name: "urlcode", value: "issues"))
                urlBuilder?.addQueryItem(URLQueryItem(name: "limit", value: "4"))
                if let url = urlBuilder?.url {
                    return URLRequest(url: url)
                }
                return nil
            }
            
            class func FeedbackRequest(name: String, email: String, message: String) -> NSURLRequest? {
                let urlString = Strings.Feedback.URL
                guard let url = NSURL(string: urlString) else {
                    return nil
                }
                let request = NSMutableURLRequest(url: url as URL)
                request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
                request.addValue("text/plain", forHTTPHeaderField: "Accept")
                request.setValue(name, forHTTPHeaderField: "name")
                request.setValue(email, forHTTPHeaderField: "email")
                request.setValue(Strings.AppShortCode, forHTTPHeaderField: "appid")
                request.setValue(Strings.NewEncryptionKey, forHTTPHeaderField: "consumerid")
                let data = message.data(using: String.Encoding.utf8)
                request.httpBody = data
                request.httpMethod = "POST"
                return request
            }
            
            
            
        }
        
        class Content {
            
            class func Liscences() -> Foundation.URLRequest? {
                var urlBuilder = URLComponents(string: Strings.OpenAccess.LiscensesURL)
                var date: String
                if let _date = UserDefaults.standard.value(forKey: Strings.UserDefaults.LiscensesUpdateDate) as? String {
                    date = _date
                } else {
                    let dateFormatter = DateFormatter(dateFormat: "YYYY-MM-dd HH:mm:ss")
                    date = dateFormatter.string(from: Date.init(timeIntervalSince1970: 0))
                }
                urlBuilder?.addQueryItem(URLQueryItem(name: "date", value: date))
                if let url = urlBuilder?.url {
                    return Foundation.URLRequest(url: url)
                }
                return nil
            }
            
        }
        
        class Login {
            
            class func SinglePartnerList(_ issn: String) -> Foundation.URLRequest? {
                guard let url = NSURL(string: Strings.Authentication.LoginPartnerURL + issn) else {
                    return nil
                }
                var request = URLRequest(url: url as URL)
                request.addValue(Strings.ConsumerId, forHTTPHeaderField: "consumerid")
                request.addValue(Strings.AppShortCode, forHTTPHeaderField: "appid")
                return request as URLRequest
            }
            
            class func MultiPartnerList() -> Foundation.URLRequest? {
                guard let url = NSURL(string: Strings.Authentication.LoginPartnerURL) else {
                    return nil
                }
                var request = URLRequest(url: url as URL)
                request.addValue(Strings.ConsumerId, forHTTPHeaderField: "consumerid")
                request.addValue(Strings.AppShortCode, forHTTPHeaderField: "appid")
                request.httpMethod = "POST"      
                request.addValue("application/xml", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                var body = "<issns>"
                for journal in DatabaseManager.SharedInstance.getAllJournals() {
                    let issn: NSMutableString = NSMutableString(format: "%@", journal.issn)
                    issn.insert("-", at: 4)
                    body += "<issn>" + (issn as String) + "</issn>,"
                }
                body += "</issns>"
                request.httpBody = body.data(using: String.Encoding.utf8)
                return request as URLRequest
            }
            
            class func LoginAuthentication(partnerId: String, userName: String, password: String, rememberMe: Bool) -> Foundation.URLRequest? {
                guard let url = NSURL(string: Strings.Authentication.LoginAuthURL + partnerId) else {
                    return nil
                }
                
                var request = URLRequest(url: url as URL)
                request.addValue(Strings.ConsumerId,   forHTTPHeaderField: "consumerid")
                request.addValue(Strings.AppShortCode, forHTTPHeaderField: "appid")
                request.addValue(userName,             forHTTPHeaderField: "name")
                request.addValue(password,             forHTTPHeaderField: "cred")
                request.addValue("application/json",   forHTTPHeaderField: "accept")
                return request as URLRequest
            }
            
            class func LoginAuthentication(userName: String, password: String, rememberMe: Bool) -> Foundation.URLRequest? {
                guard let url = NSURL(string: Strings.Authentication.LoginAuthURL) else {
                    return nil
                }
            
                let request = NSMutableURLRequest(url: url as URL)
                request.addValue(Strings.ConsumerId,   forHTTPHeaderField: "consumerid")
                request.addValue(Strings.AppShortCode, forHTTPHeaderField: "appid")
                request.addValue(userName,             forHTTPHeaderField: "name")
                request.addValue(password,             forHTTPHeaderField: "cred")
                return request as URLRequest
            }
            
            class func LoginAuthorization(_ session: String, productId: String, idp: String) -> Foundation.URLRequest? {
                guard let url = NSURL(string: Strings.Authentication.LoginAutzURL + productId) else {
                    return nil
                }
                let request = NSMutableURLRequest(url: url as URL)
                request.addValue(Strings.ConsumerId,   forHTTPHeaderField: "consumerid")
                request.addValue(Strings.AppShortCode, forHTTPHeaderField: "appid")
                request.addValue(session,              forHTTPHeaderField: "session")
                request.addValue(idp,                  forHTTPHeaderField: "idp")
                return request as URLRequest
            }
            
            class func IPAuthentication(_ authToken: String?, ip: String?) -> Foundation.URLRequest? {
                guard let url = NSURL(string: Strings.Authentication.IPAuthURL) else {
                    return nil
                }
                let request = NSMutableURLRequest(url: url as URL)
                request.addValue(Strings.ConsumerId,   forHTTPHeaderField: "consumerid")
                request.addValue(Strings.AppShortCode, forHTTPHeaderField: "appid")
                if let authToken = authToken {
                    request.addValue(authToken,        forHTTPHeaderField: "authtoken")
                }
                if let ip = ip {
                    request.addValue(ip,               forHTTPHeaderField: "ip")
                }
                request.addValue("application/json",   forHTTPHeaderField: "accept")
                return request as URLRequest
            }
            
            class func IPAuthorization(_ authtoken: String, ip: String?) -> Foundation.URLRequest? {
                guard let url = NSURL(string: Strings.Authentication.IPAutzURL) else {
                    return nil
                }
                let request = NSMutableURLRequest(url: url as URL)
                request.addValue(Strings.ConsumerId,   forHTTPHeaderField: "consumerid")
                request.addValue(Strings.AppShortCode, forHTTPHeaderField: "appid")
                
                
                
                request.addValue(authtoken,            forHTTPHeaderField: "authtoken")
                request.addValue("application/xml",    forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                if let ip = ip {
                    request.addValue(ip,               forHTTPHeaderField: "ip")
                }
                if let xml = DatabaseManager.SharedInstance.getAppPublisher()?.journalListXML {
                    request.httpBody = xml.data(using: String.Encoding.utf8)
                }
                
                request.addValue("application/json",   forHTTPHeaderField: "accept")
                return request as URLRequest

            }
            
            class func ForgotPassword(partnerId: String, email: String) -> Foundation.URLRequest? {
                guard let url = NSURL(string: Strings.Authentication.ForgotPasswordURL + partnerId) else {
                    return nil
                }
                let request = NSMutableURLRequest(url: url as URL)
                request.addValue(Strings.ConsumerId,   forHTTPHeaderField: "consumerid")
                request.addValue(Strings.AppShortCode, forHTTPHeaderField: "appid")
                
                let emailNSString = NSString(string: email)
                let encryptedEmail = emailNSString.aes256Encrypt(withKey: Strings.EncryptionKey)
                request.addValue(encryptedEmail!, forHTTPHeaderField: "name")
                
                return request as URLRequest
            }
            
        }
        
        // Metadata
        
        @available(*, deprecated: 0.2)
        class func ArticlesRequest(issue: Issue) -> Foundation.URLRequest? {
            var urlBuilder = URLComponents(string: Strings.BaseIndexURL)
            urlBuilder?.addQueryItem(URLQueryItem(name: "appid", value: Strings.AppShortCode))
            urlBuilder?.addQueryItem(URLQueryItem(name: "jid", value: String(describing: issue.journal.journalId)))
            urlBuilder?.addQueryItem(URLQueryItem(name: "issues", value: issue.issuePii))
            urlBuilder?.addQueryItem(URLQueryItem(name: "urlcode", value: "issues"))
            if let url = urlBuilder?.url {
                return Foundation.URLRequest(url: url)
            }
            return nil
        }
        
        // Theme
        
        class func ThemeRequest(journal: Journal, lastModified: Date? = nil, deviceType: ThemeRequestDeviceType = .Tablet) -> Foundation.URLRequest? {
            guard let issn = journal.issn else {
                return nil
            }
            var urlString = Strings.Content.Theme + "?issn=\(issn)"
            if let lastModified = lastModified {
                urlString += "&lastmodified=\(lastModified)"
            }
            if let url = URL(string: urlString) {
                var request = URLRequest(url: url)
                if let deviceTypeString = NSString(string: "tablet").aes256Encrypt(withKey: Strings.EncryptionKey) {
                    request.addValue(deviceTypeString, forHTTPHeaderField: "devicetype")
                }
                request.addValue(Strings.CIConsumerID, forHTTPHeaderField: "consumerid")
                return request
            }
            
            return nil
        }
        
        // Cover Image
        
        class func CoverImage(issue: Issue) -> Foundation.URLRequest? {
            var components: [URLQueryItem] = []
            var urlBuilder = URLComponents(string: Strings.Content.CoverImage)
            components.append(URLQueryItem(name: "issn", value: issue.journal.issn))
            if let coverImage = issue.coverImage {
                components.append(URLQueryItem(name: "filename", value: coverImage))
            }
            urlBuilder?.queryItems = components
            if let url = urlBuilder?.url {
                var request = URLRequest(url: url)
                request.addValue(Strings.CIConsumerID, forHTTPHeaderField: "consumerid")
                return request
            }
            return nil
        }
        
        // Abstract
        
        class func AbstractHTMLRequest(article: Article) -> Foundation.URLRequest? {
            if let request = V2.RedirectRequest(issn: article.journal.issn, filename: article.abstractHTMLZipName) {
                request.addValue(article.articleInfoId, forHTTPHeaderField: "article")
                if let issue = article.issue {
                    request.addValue(issue.issuePii, forHTTPHeaderField: "issue")
                }
                request.addValue(article.journal.issn, forHTTPHeaderField: "journal")
                request.addValue(DLItemType.AbstractHTML.rawValue, forHTTPHeaderField: "type")
                return request as URLRequest
            }
            return nil
        }
        
        class func AbstractImagesRequest(article: Article) -> Foundation.URLRequest? {
            if let request = V2.RedirectRequest(issn: article.journal.issn, filename: article.abstractImagesZipName) {
                request.addValue(article.articleInfoId, forHTTPHeaderField: "article")
                if let issue = article.issue {
                    request.addValue(issue.issuePii, forHTTPHeaderField: "issue")
                }
                request.addValue(article.journal.issn, forHTTPHeaderField: "journal")
                request.addValue(DLItemType.AbstractImages.rawValue, forHTTPHeaderField: "type")
                return request as URLRequest
            }
            return nil
        }
        
        class func AbstractSupplementRequest(article: Article) -> Foundation.URLRequest? {
            if let request = V2.RedirectRequest(issn: article.journal.issn, filename: article.abstractSupplementZipName) {
                request.addValue(article.articleInfoId, forHTTPHeaderField: "article")
                if let issue = article.issue {
                    request.addValue(issue.issuePii, forHTTPHeaderField: "issue")
                }
                request.addValue(article.journal.issn, forHTTPHeaderField: "journal")
                request.addValue(DLItemType.AbstractSupplement.rawValue, forHTTPHeaderField: "type")
                return request as URLRequest
            }
            return nil
        }
        
        // FullText
        
        class func FullTextHTMLRequest(article: Article) -> Foundation.URLRequest? {
            if let request = V2.RedirectRequest(issn: article.journal.issn, filename: article.fulltextHTMLZipName) {
                request.addValue(article.articleInfoId, forHTTPHeaderField: "article")
                if let issue = article.issue {
                    request.addValue(issue.issuePii, forHTTPHeaderField: "issue")
                }
                request.addValue(article.journal.issn, forHTTPHeaderField: "journal")
                request.addValue(DLItemType.FullTextHTML.rawValue, forHTTPHeaderField: "type")
                return request as URLRequest
            }
            return nil
        }
        
        class func FullTextImagesRequest(article: Article) -> Foundation.URLRequest? {
            if let request = V2.RedirectRequest(issn: article.journal.issn, filename: article.fulltextImagesZipName) {
                request.addValue(article.articleInfoId, forHTTPHeaderField: "article")
                if let issue = article.issue {
                    request.addValue(issue.issuePii, forHTTPHeaderField: "issue")
                }
                request.addValue(article.journal.issn, forHTTPHeaderField: "journal")
                request.addValue(DLItemType.FullTextImages.rawValue, forHTTPHeaderField: "type")
                return request as URLRequest
            }
            return nil
        }
        
        class func FullTextSupplementRequest(article: Article) -> Foundation.URLRequest? {
            if let request = V2.RedirectRequest(issn: article.journal.issn, filename: article.fulltextSupplementZipName) {
                request.addValue(article.articleInfoId, forHTTPHeaderField: "article")
                if let issue = article.issue {
                    request.addValue(issue.issuePii, forHTTPHeaderField: "issue")
                }
                request.addValue(article.journal.issn, forHTTPHeaderField: "journal")
                request.addValue(DLItemType.FullTextSupplement.rawValue, forHTTPHeaderField: "type")
                return request as URLRequest
            }
            return nil
        }
        
        // PDF
        
        class func ArticlePDFRequest(article: Article) -> Foundation.URLRequest? {
            return V2.RedirectRequest(issn: article.journal.issn, filename: article.pdfZipName) as URLRequest?
        }
        
        // Request
        
        class func RedirectRequest(issn: String, filename: String) -> NSMutableURLRequest? {
            var urlBuilder = URLComponents(string: Strings.Content.Redirect)
            urlBuilder?.addQueryItem(name: "issn", value: issn)
            urlBuilder?.addQueryItem(name: "filename", value: filename)
            if let url = urlBuilder?.url {
                let request = NSMutableURLRequest(url: url)
                request.addValue(Strings.CIConsumerID, forHTTPHeaderField: "consumerid")
                return request
            }
            return nil
        }
        
        // Media
        
        class func MediaURL(media: Media, download: Bool) -> URL? {
            
            var baseURLString: String
            if download {
                baseURLString = Strings.Content.FileDownload
            } else {
                baseURLString = Strings.Content.FileStream
            }
            
            var folderName: String
            switch media.articleType {
            case .abstract:
                folderName = media.article.abstractSupplementDirectoryName
            case .fullText:
                folderName = media.article.fulltextSupplementDirectoryName
            }
            
            var urlBuilder = URLComponents(string: baseURLString)
            urlBuilder?.addQueryItem(name: "issn", value: media.article.journal.issn)
            urlBuilder?.addQueryItem(name: "foldername", value: folderName)
            urlBuilder?.addQueryItem(name: "subfilename", value: media.fileName)
            urlBuilder?.addQueryItem(name: "consumerid", value: Strings.CIConsumerID)
            
            return urlBuilder?.url
        }
    }
}

class CKURLRequest {
    
    class V2 {
        
    }
    
    class func JournalIssuesRequest(_ journal:Journal) -> Foundation.URLRequest {
        let url = URL(basePath: Strings.BaseIndexURL, parameters: ["appid": Strings.AppShortCode, "jid": journal.journalId.stringValue, "urlcode": "issues"])
        return Foundation.URLRequest(url: url)
    }
    
    class func JournalAIPsRequest(_ journal:Journal) -> Foundation.URLRequest {
        let url = URL(basePath: Strings.BaseIndexURL, parameters: ["appid": Strings.AppShortCode, "jid":journal.journalId.stringValue, "urlcode": "aip"])
        return Foundation.URLRequest(url: url)
    }
    
    class func JournalBrandingImage(_ journal: Journal) -> Foundation.URLRequest? {
        guard let baseContentURL = journal.baseContentURL45 else {
            return nil
        }
        let url = URL(string: baseContentURL + "branding_image/ipad.zip")!
        return Foundation.URLRequest(url: url)
    }
    
    class func JournalOpenAccess() -> Foundation.URLRequest {
        let url = URL(basePath: Strings.OpenAccess.URL, parameters: ["appid": Strings.AppShortCode, "date": "01-01-04%2001:14:02"])
        return Foundation.URLRequest(url: url)
    }
    
    class func AppHTML() -> Foundation.URLRequest {
        let url = URL(basePath: Strings.OpenAccess.HTMLURL, parameters: ["appid": Strings.AppShortCode, "device": "ios", "date": "2015-12-08%2019:30:00"])
        return Foundation.URLRequest(url: url)
    }
    
    class func AnnouncementRequest(_ appId: String) -> Foundation.URLRequest {
        let url = URL(basePath: Strings.BaseAnnouncementURL, parameters: ["app_id": appId])
        return Foundation.URLRequest(url: url)
    }
    
    static var IPAddressRequest: Foundation.URLRequest {
        let url = URL(string: Strings.IPAddressURL)!
        return Foundation.URLRequest(url: url)
    }

    class func IPUsageReport(article: Article, formatType: ArticleFormatType) -> NSURLRequest? {
        
        var ipAuth: IPAuthentication
        if let _ipAuth = article.ipAuthentication {
            ipAuth = _ipAuth
        } else {
            IPInfo.Instance.save()
            guard let _ipAuth = IPInfo.Instance.currentIPAuthentication else {
                return nil
            }
            ipAuth = _ipAuth
        }
        let dateFormatter = DateFormatter(dateFormat: Strings.DateFormats.dayMonthYear)
        let urlComponents = NSURLComponents(string: Strings.Authentication.IPUsageURL + article.articleInfoId)!
        var queryItems: [NSURLQueryItem] = []
        queryItems.append(NSURLQueryItem(name: "issn", value: article.journal.issn))
        if let primaryUsageInfo = ipAuth.primaryUsageInfo {
            queryItems.append(URLQueryItem(name: "primaryusageinfo", value: primaryUsageInfo) as NSURLQueryItem)
        }
        queryItems.append(NSURLQueryItem(name: "fmt", value: formatType.rawValue))
        queryItems.append(NSURLQueryItem(name: "pubdate", value: dateFormatter.string(from: article.dateOfRelease!)))
        queryItems.append(NSURLQueryItem(name: "ip", value: ipAuth.ipAddress!))
        if let authtoken = ipAuth.authToken {
            queryItems.append(NSURLQueryItem(name: "authtoken", value: authtoken))
        }
        urlComponents.queryItems = queryItems as [URLQueryItem]?
        
        guard let url = urlComponents.url?.absoluteURL else{
            log.error("[Request failed] : Unable to retreive absolute string")
            return nil
        }
        return createRequest(url: url as NSURL, ipAuthentication: ipAuth)
    }
    
    class func createRequest(url:NSURL, ipAuthentication:IPAuthentication) -> NSURLRequest? {
        let request = NSMutableURLRequest(url: url as URL)
        request.addValue(Strings.ConsumerId, forHTTPHeaderField: "consumerid")
        request.addValue(Strings.AppShortCode, forHTTPHeaderField: "appid")
        if let session = ipAuthentication.session {
            request.addValue(session, forHTTPHeaderField: "session")
        }
        request.httpMethod = "GET"
        return request
    }
}
