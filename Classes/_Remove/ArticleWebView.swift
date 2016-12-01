//
//  ArticleWebView.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 9/9/15.
//  Copyright © 2015 Sharkey, Justin (ELS-CON). All rights reserved.
//

import UIKit
import WebKit
import AVKit
import MediaPlayer
import SafariServices
import Cartography

private struct MediaRequestType {
    
    static let Key = "request"
    
    static let Stream = "stream"
    static let Download = "download"
}

// TODO: Remove?

class ArticleWebView: UIViewController, UIWebViewDelegate {
    
    var index: Int?
    weak var article: Article!
    var webView: UIWebView!
    weak var parentVC: ArticlePageViewController?
    let ciManager = CIManager()
    
    let fsm = FileSystemManager.sharedInstance
    
    var javascriptToEvaluate:[String] = []
    
    var jsToLoad: String?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = UIWebView()
        webView.delegate = self
        view.addSubview(webView)
        webView.backgroundColor = UIColor.whiteColor()
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        constrain(webView) { (webView) -> () in
            guard let superview = webView.superview else {
                return
            }
            
            webView.left == superview.left
            webView.top == superview.top
            webView.right == superview.right
            webView.bottom == superview.bottom
        }
        
        loadHTML()
        
        setupNotifications()
    }
    
    func loadHTML() {
        if article.downloadInfo.fullTextDownloadStatus == .Downloaded {
            loadHTMLPath(fsm.articleHTMLPath(article))
        } else if article.downloadInfo.abstractDownloadStatus == .Downloaded {
            let html = fsm.articleAbstractHTMLPath(article)
            loadHTMLPath(html)
        } else {
            loadAbstract()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        for js in javascriptToEvaluate {
            self.webView.stringByEvaluatingJavaScriptFromString(js)
        }
        javascriptToEvaluate = []
        hideDownloadedMedia()
    }
    
    func loadAbstract() {
        let articleURL = NSBundle.mainBundle().URLForResource("article", withExtension: "html")!
        let articleData = NSData(contentsOfURL: articleURL)!
        var articleString = NSString(data: articleData, encoding: NSUTF8StringEncoding)!
        
        if let articleTitle = article.articleTitle {
            articleString = articleString.stringByReplacingOccurrencesOfString("REPLACE_TITLE", withString: articleTitle)
        } else {
            articleString = articleString.stringByReplacingOccurrencesOfString("REPLACE_TITLE", withString: "")
        }
        
        if let articleAuthors = article.author {
            articleString = articleString.stringByReplacingOccurrencesOfString("REPLACE_AUTHORS", withString: articleAuthors)
        } else {
            articleString = articleString.stringByReplacingOccurrencesOfString("REPLACE_AUTHORS", withString: "")
        }
        
        let cssPath = FileSystemManager.sharedInstance.journalPath(article.journal!) + "css/style.css"
        if let cssData = NSData(contentsOfFile: cssPath) {
            if let cssString = NSString(data: cssData, encoding: NSUTF8StringEncoding) {
                articleString = articleString.stringByReplacingOccurrencesOfString("REPLACE_CSS", withString: cssString as String)
            } else {
                articleString = articleString.stringByReplacingOccurrencesOfString("REPLACE_CSS", withString: "")
            }
        } else {
            articleString = articleString.stringByReplacingOccurrencesOfString("REPLACE_CSS", withString: "")
        }
        
        print(articleString)
        
        loadHTMLString(articleString as String)
    }
    
    // MARK: - Notifications -
    
    func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(supplementFileDownloadSuccessful(_:)), name: Notification.Download.Media.Successful, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(supplementFileDownloadFailure(_:)), name: Notification.Download.Media.Failure, object: nil)
    }
    
    func supplementFileDownloadSuccessful(notification: NSNotification) {
        let media = notification.object as! Media
        let string = "document.getElementById('\(media.fileName)').style.display = 'none';"
        webView.stringByEvaluatingJavaScriptFromString(string)
    }
    
    func supplementFileDownloadFailure(notification: NSNotification) {
        
    }
    
    // MARK: - Webview -
    
    func webViewDidFinishLoad(webView: UIWebView) {
        hideDownloadedMedia()
        loadIPAuth()
        
        if article.downloadInfo.fullTextDownloadStatus == .Downloaded {

        } else if article.downloadInfo.abstractDownloadStatus == .Downloaded {
            webView.stringByEvaluatingJavaScriptFromString("var iDiv = document.createElement('div'); iDiv.id = 'download'; iDiv.className = 'download'; iDiv.innerHTML = \"<style>#download { background-color: #3D3D3D; color: white; padding-top: 5pt; padding-bottom: 5pt; padding-left: 10pt; padding-right: 10pt; display: inline-block; border-radius: 4pt; font-size: 12pt; } #download a:link { color: white; vertical-align: middle; text-decoration: none; }</style><a href='http://download'>Download</a>\"; document.getElementsByTagName('body')[0].appendChild(iDiv);")
        } else {
            webView.stringByEvaluatingJavaScriptFromString("var iDiv = document.createElement('div'); iDiv.id = 'download'; iDiv.className = 'download'; iDiv.innerHTML = \"<style>#download { background-color: #3D3D3D; color: white; padding-top: 5pt; padding-bottom: 5pt; padding-left: 10pt; padding-right: 10pt; display: inline-block; border-radius: 4pt; font-size: 12pt; } #download a:link { color: white; vertical-align: middle; text-decoration: none; }</style><a href='http://download'>Download</a>\"; document.getElementsByTagName('body')[0].appendChild(iDiv);")
        }
    }
    
    func hideDownloadedMedia() {
        if let medias = article.medias?.allObjects as? [Media] {
            for media in medias {
                if media.downloaded.boolValue {
                    webView.stringByEvaluatingJavaScriptFromString("document.getElementById('\(media.fileName)').style.display = 'none';")
                }
            }
        }
    }
    
    func loadIPAuth() {
        if let ipAuth = article.ipAuthentication {
            sendIPUsage()
            if IPInfo.Instance.shouldShowIPBanner {
                addIPBanner(ipAuth)
            } else {
                if IPInfo.Instance.currentIPBanner != ipAuth.bannerText! {
                    addIPBanner(ipAuth)
                }
            }
        }
    }
    
    func addIPBanner(ipAuth: IPAuthentication) {
        let method = "ipInfoBanner('\(ipAuth.bannerText!)')"
        webView.stringByEvaluatingJavaScriptFromString(method)
        IPInfo.Instance.currentIPBanner = ipAuth.bannerText!
        IPInfo.Instance.shouldShowIPBanner = true
    }
    
    func sendIPUsage() {
        APIManager.sharedInstance.reportUsageForArticle(article, formatType: .HTML, completion: nil)
    }
    
    func hideIPAuth() {
        webView.stringByEvaluatingJavaScriptFromString("closeIPInfo();")
        IPInfo.Instance.shouldShowIPBanner = false
    }
    
    func loadHTMLPath(path: String) {
        let url = NSURL(string: path)!
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }
    
    func loadHTMLString(html: String) {
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func downloadCompleted(sender: NSNotification) {
        if let vc = parentVC {
            vc.articles[vc.currentIndex] = DatabaseManager.SharedInstance.getArticle(articleInfoId: article.articleInfoId)!
        }
        loadHTML()
        parentVC?.setupToolbar()
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if "\(request.URL!)" == "http://download/" {

        } else if "\(request.URL!)" == "didtap://closeBanner" {
            hideIPAuth()
            return false
        }
        
        let requestString = "\(request.URL!)"
        if requestString.containsString("https://ci-dev.elsevier-jbs.com/") {
            let ciController = CIController()
            ciController.modalPresentationStyle = .OverCurrentContext
            ciController.modalTransitionStyle = .CrossDissolve
            ciController.url = request.URL!
            ciController.directLink = true
            parentVC!.navigationController?.presentViewController(ciController, animated: true, completion: nil)
            return false
        }
        
        switch navigationType {
        case .LinkClicked:
            
            guard let url = request.URL else {
                return false
            }
            
            if let fileName = url.fileName() {
                if let media = article.mediaForFile(fileName) {
                    loadMedia(media, withURL: url, ofType: media.mediaFileType())
                    return false
                }
            }
            
            let path = "\(url)"
            let articlePath = fsm.articleHTMLPath(article)
            
            if path.containsString(articlePath) {
                return true
            } else if path.containsString("wwww.kiwidemourl.com") {
                return false
            }
            
            loadExternalURL(request.URL!)
            return false
            
        default:
            print("default")
        }
        return true
    }
    
    func loadMedia(media: Media, withURL url: NSURL, ofType type: MediaFileType) {
        
        let parameters = url.parameters()
        if let requestType = parameters[MediaRequestType.Key] {
            
            if requestType == MediaRequestType.Stream {
                
                switch type {
                    
                case .Video:
                    if media.downloaded.boolValue {
                        loadVideoWithURL(url)
                    } else {
                        if !InternetHelper.sharedInstance.available {
                            let avController = AlertHelper.NetworkUnavailable()
                            presentViewController(avController, animated: true, completion: nil)
                            return
                        }
                        loadVideo(media)
                    }
                    
                case .Audio:
                    if media.downloaded.boolValue {
                        loadAudioWithURL(url)
                    } else {
                        if !InternetHelper.sharedInstance.available {
                            let avController = AlertHelper.NetworkUnavailable()
                            presentViewController(avController, animated: true, completion: nil)
                            return
                        }
                        loadAudioWithURL(media.downloadURL())
                    }
                    
                default:
                    print("Default")
                    
                }
                
            } else if requestType == MediaRequestType.Download {
                
                switch type {
                    
                case .Video, .Audio:
                    if !InternetHelper.sharedInstance.available {
                        let avController = AlertHelper.NetworkUnavailable()
                        presentViewController(avController, animated: true, completion: nil)
                        return
                    }
                    showDownloadAlert(media)
                
                default:
                    print("Default")
                    
                }
            }
            
        } else {
            
            switch type {
                
            case .Document:
                if media.downloaded.boolValue {
                    loadOtherWithURL(url)
                } else {
                    showDownloadAlert(nil)
                }
                
            case .Presentation:
                if media.downloaded.boolValue {
                    loadOtherWithURL(url)
                } else {
                    showDownloadAlert(nil)
                }
                
            case .Spreadsheet:
                if media.downloaded.boolValue {
                    loadOtherWithURL(url)
                } else {
                    showDownloadAlert(nil)
                }
                
            case .PDF:
                if media.downloaded.boolValue {
                    loadOtherWithURL(url)
                } else {
                    showDownloadAlert(nil)
                }
                
            case .Image:
                loadImageWithURL(url)
                
            case .Table:
                print("Table")
                
            case .Other:
                if media.downloaded.boolValue {
                    loadOtherWithURL(url)
                } else {
                    showDownloadAlert(nil)
                }
                
            default:
                print("Default")
                
            }
        }
    }
    
    // MARK: - Figure -
    
    func loadImageWithURL(url: NSURL) {
        
        guard let fileName = url.fileName() else {
            return
        }
        
        if let media = article.mediaForFile(fileName) {
            let imageVC = ImageViewController(figure: media, showBackButton: false)
            presentViewController(UINavigationController(rootViewController: imageVC), animated: true, completion: nil)
        } else {
            loadExternalURL(url)
        }
    }
    
    // MARK: - Video -
    
    func loadVideoWithURL(url: NSURL) {
        let vc = VideoViewController(url: url)
        let nvc = UINavigationController(rootViewController: vc)
        parentVC!.navigationController?.presentViewController(nvc, animated: true, completion: nil)
    }
    
    func loadVideo(media: Media) {
        let url = CKURLRequest.ArticleMediaURL(media, download: !media.downloaded.boolValue)
        let videoVC = VideoViewController(url: url)
        let navigationVC = UINavigationController(rootViewController: videoVC)
        parentVC!.navigationController?.presentViewController(navigationVC, animated: true, completion: nil)
    }
    
    // MARK: - Audio -
    
    func loadAudioWithURL(url: NSURL) {
        let vc = AudioViewController(url: url)
        let nvc = UINavigationController(rootViewController: vc)
        parentVC!.navigationController?.presentViewController(nvc, animated: true, completion: nil)
    }
    
    // MARK: - Other -
    
    func loadOtherWithURL(url: NSURL) {
        let path = url.path!
        let newURL = NSURL(fileURLWithPath: path)
        let interactionVC = UIDocumentInteractionController(URL: newURL)
        interactionVC.delegate = self
        interactionVC.presentPreviewAnimated(true)
    }

    // MARK: - Download Alert -
    
    func showDownloadAlert(media: Media?) {
        
        if !InternetHelper.sharedInstance.available {
            let avController = AlertHelper.NetworkUnavailable()
            presentViewController(avController, animated: true, completion: nil)
            return
        }
        
        let alert = UIAlertController(title: "Download", message: "*Video, Audio and Other Files for this Article", preferredStyle: .Alert)
        
        if let m = media {
            alert.addAction(UIAlertAction(title: "This \(m.type) - " + m.fileSize.integerValue.convertToFileSize(), style: .Default, handler: { (action) -> Void in
                APIManager.sharedInstance.downloadMediaFile(m)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.webView.stringByEvaluatingJavaScriptFromString("document.getElementById('\(m.fileName)-img').src = '../../../images/progress.gif';")
                    self.webView.stringByEvaluatingJavaScriptFromString("document.getElementById('\(m.fileName)').removeAttribute('href');")
                })
            }))
        }
        
        if media == nil || article.undownloadedMediaCount > 1 {
            let filesize = article.downloadInfo.fullTextSupplFileSize.integerValue
            alert.addAction(UIAlertAction(title: "All Multimedia * - " + filesize.convertToFileSize(), style: .Default, handler: { (action) -> Void in
                DLManager.sharedInstance.downloadArticleSupplement(self.article)

                if let medias = self.article.medias?.allObjects as? [Media] {
                    for media in medias {
                        if !media.downloaded.boolValue {
                            self.webView.stringByEvaluatingJavaScriptFromString("document.getElementById('\(media.fileName)-img').src = '../../../images/progress.gif';")
                            self.webView.stringByEvaluatingJavaScriptFromString("document.getElementById('\(media.fileName)').removeAttribute('href');")
                        }
                    }
                }
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func loadExternalURL(url: NSURL) {
        let safariVC = SFSafariViewController(URL: url)
        presentViewController(safariVC, animated: true, completion: nil)
    }
}

// MARK: - UIDocumentInteractionControllerDelegate -

extension ArticleWebView: UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerViewForPreview(controller: UIDocumentInteractionController) -> UIView? {
        return view
    }
    
    func documentInteractionControllerRectForPreview(controller: UIDocumentInteractionController) -> CGRect {
        return view.frame
    }
}
