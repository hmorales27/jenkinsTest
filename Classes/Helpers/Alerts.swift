//
// Alerts
//

import UIKit

enum AlertType {
    case article
    case issue
}

private let FullText_And_Multimedia = "Full-Text and Multimedia* - "
private let FullText_Only = "Full-Text only - "
private let CANCEL = "Cancel"

private func FullText_And_Multimedia(_ size: Int) -> String {
    return FullText_And_Multimedia + size.convertToFileSize()
}
private func FullText_Only(_ size: Int) -> String {
    return FullText_Only + size.convertToFileSize()
}

private let OK_ACTION = UIAlertAction(title: "OK", style: .default, handler: nil)
func OK_ACTION(_ completion:@escaping ()->()) -> UIAlertAction {
    return UIAlertAction(title: "OK", style: .default, handler: { (action) in
        completion()
    })
}

extension UIAlertController {
    
    func present(from parentVC: UIViewController) {
        self.present(from: parentVC, onMainThread: true)
    }
    
    func present(from parentVC: UIViewController, onMainThread mainThread: Bool) {
        if mainThread {
            performOnMainThread({ 
                parentVC.present(self, animated: true, completion: {
                    
                    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self)
                })
            })
        } else {
            parentVC.present(self, animated: true, completion: nil)
        }
    }
}

class Alerts {
    
    enum SingleMediaDownloadSelection {
        case singleMedia
        case allSupplement
    }
    
    class func DownloadMedia(_ media: Media, fullText: Bool, completion: @escaping (_ selection: SingleMediaDownloadSelection)->()) -> UIAlertController {
        let counts = media.article.countOfUndownloadedSupplementFiles
        var showAllSupplementAlert = false
        if fullText {
            let toalCount = counts.abs + counts.full
            if toalCount > 1 {
                showAllSupplementAlert = true
            }
        } else {
            if counts.abs > 1 {
                showAllSupplementAlert = true
            }
        }
        
        let alertVC = UIAlertController(
            title: "Download",
            message: "*Video, Audio and Other Files for this Article",
            preferredStyle: .alert
        )
        alertVC.addAction(UIAlertAction(title: "This \(media.fileType.rawValue) \(Int(media.fileSize).convertToFileSize())", style: .default) { (alert) in
            completion(.singleMedia)
            APIManager.sharedInstance.downloadMediaFile(media)
        })
        
        
        if showAllSupplementAlert {
            
            let article = media.article
            var size: Int = 0
            
            if article?.downloadInfo.abstractSupplDownloadStatus != .downloaded {
                size += Int((article?.downloadInfo.abstractSupplFileSize)!)
            }
            if article?.downloadInfo.fullTextSupplDownloadStatus != .downloaded {
                size += Int((article?.downloadInfo.fullTextSupplFileSize)!)
            }
            
            alertVC.addAction(UIAlertAction(title: "All Multimedia* \(size.convertToFileSize())", style: .default) { (action) in
                completion(.allSupplement)
                if media.article.issue == .none {
                    DMManager.sharedInstance.downloadAIP(media.article, withSupplement: true)
                } else {
                    DMManager.sharedInstance.downloadFullTextSupplement(article: media.article)
                }
                
            })
        }
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alertVC
    }

    class func DownloadMedia(_ media: Media, fullText: Bool) -> UIAlertController {
        return Alerts.DownloadMedia(media, fullText: fullText, completion: { (selection) in
            
        })
        
    }

    // MARK: MAIL
    
    class func MailSentSuccessfully() -> UIAlertController {
        let alertVC = UIAlertController(
            title          : .none,
            message        : "Mail Sent Successfully",
            preferredStyle : .alert
        )
        alertVC.addAction(OK_ACTION)
        return alertVC
    }
    
    class func MailSavedToDrafts() -> UIAlertController {
        let alertVC = UIAlertController(
            title          : .none,
            message        : "Mail Saved to Drafts Successfully",
            preferredStyle : .alert
        )
        alertVC.addAction(OK_ACTION)
        return alertVC
    }
    
    class func MailCancelled() -> UIAlertController {
        let alertVC = UIAlertController(
            title          : .none,
            message        : "Mail Cancelled",
            preferredStyle : .alert
        )
        alertVC.addAction(OK_ACTION)
        return alertVC
    }
    
    // MARK: RESTORE PURCHASE
    
    class func LoginRestoreTransactionCompleted() -> UIAlertController {
        let alertVC = UIAlertController(
            title          : .none,
            message        : "Restore Transaction Completed.",
            preferredStyle : .alert
        )
        alertVC.addAction(OK_ACTION)
        return alertVC
    }
    
    class func LoginRestoreTransactionFailed() -> UIAlertController {
        let alertVC = UIAlertController(
            title          : .none,
            message        : "Restore Transaction Failed",
            preferredStyle : .alert
        )
        alertVC.addAction(OK_ACTION)
        return alertVC
    }
    
    // MARK: SUBSCRIPTION
    
    class func LoginSubscriptionSuccessful() -> UIAlertController {
        let alertVC = UIAlertController(
            title          : .none,
            message        : "Your subscription has succesfully completed.",
            preferredStyle : .alert
        )
        alertVC.addAction(OK_ACTION)
        return alertVC
    }
    
    class func LoginSubscriptionFailed() -> UIAlertController {
        let alertVC = UIAlertController(
            title          : .none,
            message        : "Unable to purchase subscription",
            preferredStyle : .alert
        )
        alertVC.addAction(OK_ACTION)
        return alertVC
    }
    
    class func loginPurchaseSuccessful() -> UIAlertController {
        let alertVC = UIAlertController(
            title          : .none,
            message        : "Successfully Purchased Issue",
            preferredStyle : .alert
        )
        alertVC.addAction(OK_ACTION)
        return alertVC
    }
    
    class func loginPurchaseFailure() -> UIAlertController {
        let alertVC = UIAlertController(
            title          : .none,
            message        : "Unable to Purchase Issue.",
            preferredStyle : .alert
        )
        alertVC.addAction(OK_ACTION)
        return alertVC
    }
    
    class func LoginSubscriptionAlreadyPurchased() -> UIAlertController {
        let alertVC = UIAlertController(
            title          : .none,
            message        : "Subscription has already been purchased.",
            preferredStyle : .alert
        )
        alertVC.addAction(OK_ACTION)
        return alertVC
    }
    
    // MARK: CANCELLED
    
    class func LoginTransactionCancelled() -> UIAlertController {
        let alertVC = UIAlertController(
            title          : .none,
            message        : "Transaction Cancelled",
            preferredStyle : .alert
        )
        alertVC.addAction(OK_ACTION)
        return alertVC
    }
    
    class func InternalServerError() -> UIAlertController {
        let alertVC = UIAlertController(
            title          : "Internal Server Error",
            message        : "Server is unable to process the request.",
            preferredStyle : .alert
        )
        alertVC.addAction(OK_ACTION)
        return alertVC
    }
    
    class func AbstractDownloading() -> UIAlertController {
        let alertVC = UIAlertController(
            title          : "Message",
            message        : "The Abstract of this article is currently downloading.",
            preferredStyle : .alert)
        alertVC.addAction(OK_ACTION)
        return alertVC
    }
    
    // MARK: - Network -
    
    class func NoNetwork() -> UIAlertController {
        let alertVC = UIAlertController(
            title          : "No Network!",
            message        : "A network connection is required. Please verify your network settings and try again.",
            preferredStyle : .alert
        )
        alertVC.addAction(OK_ACTION)
        return alertVC
    }
    
    class func NoNetwork(_ completion:@escaping ()->()) -> UIAlertController {
        let alertVC = UIAlertController(
            title          : "No Network!",
            message        : "A network connection is required. Please verify your network settings and try again.",
            preferredStyle : .alert)
        alertVC.addAction(OK_ACTION({
            completion()
        }))
        return alertVC
    }
    
    // MARK: - Download Article -
    
    class func Download(articles: [Article], completion:()->()) -> UIAlertController {
        let alertVC = UIAlertController(
            title          : "Download Articles",
            message        : "* Video, Audio and Other Files",
            preferredStyle : .alert
        )
        
        var fullText: Int = 0, fullTextAndSupplement: Int = 0
        
        for article in articles {
            fullText += article.fullTextRemainingSize
            fullTextAndSupplement += article.entireArticleRemainingSize
        }
        
        if fullTextAndSupplement > 0 {
            alertVC.addAction(UIAlertAction(title: "Full-Text and Multimedia* - \(fullTextAndSupplement.convertToFileSize())", style: .default, handler: { (action) in
                for article in articles {
                    DMManager.sharedInstance.downloadAIP(article: article, withSupplement: true)
                }
            }))
        }
        
        if fullText > 0 {
            alertVC.addAction(UIAlertAction(title: "Full-Text only - \(fullText.convertToFileSize())", style: .default, handler: { (action) in
                for article in articles {
                    DMManager.sharedInstance.downloadAIP(article: article, withSupplement: false)
                }
            }))
        }
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        return alertVC
    }
    
    class func Download(article: Article, completion: @escaping (_ push: Bool)->()) -> UIAlertController {

        let alertVC = UIAlertController(title: "Download Article", message: "* Video, Audio and Other Files", preferredStyle: .alert)
        
        if article.abstractAndFullTextSupplementExists && !article.abstractAndFullTextSupplementDownloaded {
            alertVC.addAction(UIAlertAction(title: FullText_And_Multimedia(article.entireArticleRemainingSize), style: .default, handler: { (action) in
                DMManager.sharedInstance.download(article: article, withSupplement: true)
                completion(true)
                
            }))
        }
        if !article.fullTextDownloaded {
            alertVC.addAction(UIAlertAction(title: FullText_Only(article.fullTextDownloadedSize), style: .default, handler: { (action) in
                DMManager.sharedInstance.download(article: article, withSupplement: false)
                completion(true)
            }))
        }
        alertVC.addAction(UIAlertAction(title: CANCEL, style: .cancel, handler: nil))
        
        return alertVC
    }

    
    class func DownloadOa(_ article: Article, completion: @escaping (_ push: Bool)->()) -> UIAlertController {
        
        let message = article.abstractAndFullTextSupplementExists ? "* Video, Audio and Other Files" : "Do you want to download the full-text for this article?"

        let alertVC = UIAlertController(title: "Download Article", message: message, preferredStyle: .alert)

        if article.abstractAndFullTextSupplementExists && !article.abstractAndFullTextSupplementDownloaded {
            alertVC.addAction(UIAlertAction(title: FullText_And_Multimedia(article.entireArticleRemainingSize), style: .default, handler: { (action) in
                DMManager.sharedInstance.download(article: article, withSupplement: true)
                completion(true)
            }))
        }
        
        if !article.fullTextDownloaded {
            alertVC.addAction(UIAlertAction(title: FullText_Only(article.fullTextDownloadedSize), style: .default, handler: { (action) in
                DMManager.sharedInstance.download(article: article, withSupplement: false)
                completion(true)
            }))
        }
        alertVC.addAction(UIAlertAction(title: CANCEL, style: .cancel, handler: nil))
        
        return alertVC
    }
    
    
    // MARK: - Download Issue -
    
    class func Download(issue: Issue, startingWithArticle article: Article?, completion: @escaping (_ multimedia: Bool)->()) -> UIAlertController {
        
        let alertVC = UIAlertController(title: "Download this Issue", message: "* Video, Audio and Other Files", preferredStyle: .alert)
        
        let fullTextSize = issue.sizeForRemainingFullTextContent
        let fullTextAndSupplementSize = issue.sizeForRemainingContent
        
        if fullTextAndSupplementSize > 0 {
            alertVC.addAction(UIAlertAction(title: "Full-Text and Multimedia* - \(fullTextAndSupplementSize.convertToFileSize())", style: .default, handler: { (action) in
                DMManager.sharedInstance.downloadIssue(issue, withSupplement: true, startingWith: article)
                completion(true)
            }))
        }
        
        if fullTextSize > 0 {
            alertVC.addAction(UIAlertAction(title: "Full-Text only - \(fullTextSize.convertToFileSize())", style: .default, handler: { (action) in
                DMManager.sharedInstance.downloadIssue(issue, withSupplement: false, startingWith: article)
                completion(false)
            }))
        }
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alertVC
    }
    
    class func Download(issue: Issue, startingWith article: Article? = nil) -> UIAlertController {
        let alertVC = UIAlertController(title: "Download this Issue", message: "* Video, Audio and Other Files", preferredStyle: .alert)
        
        let fullTextSize = issue.sizeForRemainingFullTextContent
        let fullTextAndSupplementSize = issue.sizeForRemainingContent
        
        if fullTextAndSupplementSize > 0 {
            alertVC.addAction(UIAlertAction(title: "Full-Text and Multimedia* - \(fullTextAndSupplementSize.convertToFileSize())", style: .default, handler: { (action) in
                DMManager.sharedInstance.downloadIssue(issue, withSupplement: true, startingWith: article)
            }))
        }
        
        if fullTextSize > 0 {
            alertVC.addAction(UIAlertAction(title: "Full-Text only - \(fullTextSize.convertToFileSize())", style: .default, handler: { (action) in
                DMManager.sharedInstance.downloadIssue(issue, withSupplement: false, startingWith: article)
            }))
        }
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        return alertVC
    }
    
    class func Download(issue: Issue, startingWith article: Article? = nil, completion:@escaping (_ push:Bool)->()) -> UIAlertController {
        let alertVC = UIAlertController(title: "Download this Issue", message: "* Video, Audio and Other Files", preferredStyle: .alert)
        
        let fullTextSize = issue.sizeForRemainingFullTextContent
        let fullTextAndSupplementSize = issue.sizeForRemainingContent
        
        if fullTextAndSupplementSize > fullTextSize {
            let action = UIAlertAction(title: "Full-Text and Multimedia* - \(fullTextAndSupplementSize.convertToFileSize())", style: .default, handler: { (action) in
                DMManager.sharedInstance.downloadIssue(issue, withSupplement: true, startingWith: article)
                completion(true)
            })
            alertVC.addAction(action)
        }
        if fullTextSize > 0 {
            alertVC.addAction(UIAlertAction(title: "Full-Text only - \(fullTextSize.convertToFileSize())", style: .default, handler: { (action) in
                DMManager.sharedInstance.downloadIssue(issue, withSupplement: false, startingWith: article)
                completion(true)
            }))
        }
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            completion(false)
        }))
        
        return alertVC
    }
    
    // MARK: - Access -
    
    class func Login(issue: Issue, completion: @escaping (_ type: LoginType)->()) -> UIAlertController {
        
        var contentData: [AnyHashable: Any] = [:]
        contentData[AnalyticsConstant.TagPageType] = Constants.Page.Type.ec_ss
        AnalyticsHelper.MainInstance.trackState(Constants.Page.Name.IssueAccessOptions, stateContentData: contentData)
        
        var restore = false
        let alertVC = UIAlertController(title: "Issue Access Options", message: "Please choose an option below to view this issue", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "I am an existing member/subscriber", style: .default, handler: { (action) -> Void in
            performOnMainThread({
                completion(.login)
            })
        }))
        if let issuePrice = issue.price {
            restore = true
            alertVC.addAction(UIAlertAction(title: "I want to purchase this issue for \(issuePrice)", style: .default, handler: { (action) in
                performOnMainThread({ 
                    completion(.issue)
                })
            }))
        }
        if let yearPrice = issue.journal.subscriptionPrice {
            restore = true
            alertVC.addAction(UIAlertAction(title: "Buy a 1-year subscription for \(yearPrice)", style: .default, handler: { (action) in
                performOnMainThread({ 
                    completion(.journal)
                })
            }))
        }
        if restore == true {
            alertVC.addAction(UIAlertAction(title: "Restore my purchase", style: .default, handler: { (action) -> Void in
                performOnMainThread({ 
                    completion(.restore)
                })
            }))
        }
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alertVC
    }
    
    class func AuthenticateAIPs(_ journal: Journal, completion:@escaping (_ type: LoginType)->()) -> UIAlertController {
        var contentData: [AnyHashable: Any] = [:]
        contentData[AnalyticsConstant.TagPageType] = Constants.Page.Type.ec_ss
        AnalyticsHelper.MainInstance.trackState(Constants.Page.Name.IssueAccessOptions, stateContentData: contentData)
        
        var restore = false
        let alertVC = UIAlertController(title: "Access Options", message: "Please choose an option below to view these articles", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "I am an existing member/subscriber", style: .default, handler: { (action) -> Void in
            performOnMainThread({
                completion(.login)
            })
        }))
        if let yearPrice = journal.subscriptionPrice {
            restore = true
            alertVC.addAction(UIAlertAction(title: "Subscribe 1 year for \(yearPrice)", style: .default, handler: { (action) in
                performOnMainThread({
                    completion(.journal)
                })
            }))
        }
        if restore == true {
            alertVC.addAction(UIAlertAction(title: "Restore my purchase", style: .default, handler: { (action) -> Void in
                performOnMainThread({
                    completion(.restore)
                })
            }))
        }
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alertVC
    }
    
    class func Login(media: Media, completion: @escaping (_ type: LoginType)->()) -> UIAlertController {
        
        var contentData: [String: Any] = [:]
        contentData[AnalyticsConstant.TagPageType] = Constants.Page.Type.ec_ss
        AnalyticsHelper.MainInstance.trackState(Constants.Page.Name.IssueAccessOptions, stateContentData: contentData)
        
        var restore = false
        let alertVC = UIAlertController(title: "Access Options", message: "Please choose an option below to view these articles", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "I am an existing member/subscriber", style: .default, handler: { (action) -> Void in
            performOnMainThread({
                completion(.login)
            })
        }))
        if let issue = media.article.issue {
            if let issuePrice = issue.price {
                restore = true
                alertVC.addAction(UIAlertAction(title: "I want to purchase this issue for \(issuePrice)", style: .default, handler: { (action) in
                    performOnMainThread({
                        completion(.issue)
                    })
                }))
            }
        }
        if let yearPrice = media.article.journal.subscriptionPrice {
            restore = true
            alertVC.addAction(UIAlertAction(title: "Buy a 1-year subscription for \(yearPrice)", style: .default, handler: { (action) in
                performOnMainThread({
                    completion(.journal)
                })
            }))
        }
        if restore == true {
            alertVC.addAction(UIAlertAction(title: "Restore my purchase", style: .default, handler: { (action) -> Void in
                performOnMainThread({
                    completion(.restore)
                })
            }))
        }
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alertVC
    }
    
    class func Login(article: Article, completion: @escaping (_ type: LoginType)->()) -> UIAlertController {
        
        var contentData: [AnyHashable: Any] = [:]
        contentData[AnalyticsConstant.TagPageType] = Constants.Page.Type.ec_ss
        AnalyticsHelper.MainInstance.trackState(Constants.Page.Name.IssueAccessOptions, stateContentData: contentData)
        
        var restore = false
        let alertVC = UIAlertController(title: "Access Options", message: "Please choose an option below to view these articles", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "I am an existing member/subscriber", style: .default, handler: { (action) -> Void in
            performOnMainThread({
                completion(.login)
            })
        }))
        
        if let yearPrice = article.journal.subscriptionPrice {
            restore = true
            alertVC.addAction(UIAlertAction(title: "Subscribe 1 year for \(yearPrice)", style: .default, handler: { (action) in
                performOnMainThread({
                    completion(.journal)
                })
            }))
        }
        if restore == true {
            alertVC.addAction(UIAlertAction(title: "Restore my purchase", style: .default, handler: { (action) -> Void in
                performOnMainThread({
                    completion(.restore)
                })
            }))
        }
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alertVC
    }
    
    class func pleaseWait() -> UIAlertController {
    
        let alert = UIAlertController(title: "Please wait...", message: "", preferredStyle: .alert)
        return alert
    }
    
    class func noAccess() -> UIAlertController {
        
        let alert = UIAlertController.init(title: "Access denied.", message: "Your login credentials do not provide access to this material.", preferredStyle: .alert)
        return alert
    }
    
    
    //  MARK: - Reading List -
    
    class func NoneSelected() -> UIAlertController {
        
        let alertVC = UIAlertController(title: "Sorry", message: "No articles to delete.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alertVC
    }
    
    //  MARK: - PDF -
    
    class func NoApp() -> UIAlertController {
    
        let alertVC = UIAlertController(title: "", message: "Application not found.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alertVC
    }
    
    
    // MARK: - Supplement -
    
    class Supplement {
        
        class func Downloading() -> UIAlertController {
            let alertVC = UIAlertController(title: "Message", message: "Supplement is Downloading", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            return alertVC
        }
        
        class func DownloadAll(article: Article) -> UIAlertController {
            let alertVC = UIAlertController(title: "Download", message: "*Video, Audio and Other Files for this Article", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "All Multimedia* \(article.abstractAndFullTextSupplementRemainingSize.convertToFileSize())", style: .default) { (action) in
                DMManager.sharedInstance.downloadFullTextSupplement(article: article)
            })
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            return alertVC
        }
        
        class func DownloadSolo(media: Media) -> UIAlertController {
            let alertVC = UIAlertController(title: "Download", message: "*Video, Audio and Other Files for this Article", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "This Media \(media.fileSize.intValue.convertToFileSize())", style: .default) { (alert) in
                APIManager.sharedInstance.downloadMediaFile(media)
            })
            alertVC.addAction(UIAlertAction(title: "All Multimedia* \(media.article.abstractAndFullTextSupplementRemainingSize.convertToFileSize())", style: .default) { (action) in
                DMManager.sharedInstance.downloadFullTextSupplement(article: media.article)
            })
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            return alertVC
        }
    }
    
    class func AddToReadingList(_ completion:@escaping (_ goToReadingList: Bool)->()) -> UIAlertController {
        let alertVC = UIAlertController(title: "Added to Reading List!", message: "This article has been added to your Reading List.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Don't show again", style: .default, handler: { (action) in
            UserConfig.MainInstance.ShowGoToBookmarks = false
        }))
        alertVC.addAction(UIAlertAction(title: "Go to my Reading List", style: .default, handler: { (action) in
            performOnMainThread({
                completion(true)
            })
        }))
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alertVC
    }
    
    class func RemovedFromReadingList() -> UIAlertController {
        let alert = UIAlertController(title: "Done", message: "Bookmark has been removed.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    
    class func Delete(_ completion: @escaping (_ delete: Bool)->()) -> UIAlertController {
        let alertVC = UIAlertController(title: "Are you sure you want to delete?", message: "Deleting will remove this content from your device.", preferredStyle: .alert)

        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            performOnMainThread({
                completion(false)
            })
        }))
        alertVC.addAction(UIAlertAction(title: "Yes, Delete", style: .default, handler: { (action) in
            performOnMainThread({
                completion(true)
            })
        }))
        return alertVC
    }
    
    class func cannotDelete() -> UIAlertController {
        
        let alertVC = UIAlertController(title: "Articles that are in Reading List or that have notes will not be deleted.", message: "", preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alertVC
    }
    
    class func MailSent() -> UIAlertController {
        let alertVC = UIAlertController(title: nil, message: "Mail sent successfully.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alertVC
    }
    
    
    class func MailCanceled() -> UIAlertController {
        let alertVC = UIAlertController(title: nil, message: "Mail Cancelled.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alertVC
    }
    
    class func ArticlesDeleted() -> UIAlertController {
        let alertVC = UIAlertController(title: "Info", message: "Articles Deleted", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alertVC
    }
    
    
    // MARK: PDF
    
    class func OpenAsPDF(_ article: Article, completion:@escaping (_ open: Bool)->()) -> UIAlertController {
        let alertVC = UIAlertController(
            title          : .none,
            message        : .none,
            preferredStyle : .alert
        )
        alertVC.addAction(UIAlertAction(title: "Open as PDF - \(Int(article.downloadInfo.pdfFileSize).convertToFileSize())", style: .default, handler: { (action) in
            completion(true)
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            completion(false)
        }))
        return alertVC
    }
    
    
    //  MARK: SSO Login
    
    class func chooseLogin() -> UIAlertController {
        let alertVC = UIAlertController(
            title          : "Message",
            message        : "Please choose an account to login.",
            preferredStyle: .alert
        )
        alertVC.addAction(OK_ACTION)
        
        return alertVC
    }
}

enum LoginType {
    case login
    case issue
    case journal
    case restore
}
