//
// Article View Controller
//

import UIKit
import Cartography
import WebKit
import SafariServices
import MessageUI

enum ArticleURLRequestType {
    case external
    case contentInnovation
}

enum ArticleDisplayType {
    case none
    case abstract
    case fullText
}

protocol ArticleViewControllerDelegate: class {
    func articleViewController(_ viewController: ArticleViewController, didRequestMedia media: Media)
    func articleViewController(_ viewController: ArticleViewController, didRequestURL url: URL, ofType type: ArticleURLRequestType)
}

protocol ArticleAnalyticsDelegate: class {
    func sendAnalyticsFor(article: Article, withViewController articleVC: ArticleViewController, withScreenType screenType: String)
    func articleTagAction(article: Article, withAction action: AnalyticsHelper.ContentAction)
}

protocol ArticleViewControllerLinkClickedDelegate: class {
    func handleArticleLinkClicked(request: URLRequest) -> Bool
}

class ArticleWebView: UIWebView, UIGestureRecognizerDelegate {
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class ArticleViewController: JBSMViewController, UIWebViewDelegate, NoteViewDelegate, TextSizeViewControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, Crossmark, ArticleViewControllerLinkClickedDelegate {
    

    
    // Views
    
    let webView = ArticleWebView()
    
    // Data
    
    let article: Article
    let ciManager = CIManager()
    
    // Properties
    
    weak var delegate: ArticleViewControllerDelegate?
    weak var analyticsDelegate: ArticleAnalyticsDelegate?
    
    weak var parentVC: ArticlePagerController?
    
    let containerView = UIView()
    
    let advertisementVC = AdvertisementViewController()
    
    weak var linkClickedDelegate: ArticleViewControllerLinkClickedDelegate?
    
    // Misc
    
    var articleType: ArticleDisplayType = .none
    
    var fullText: Bool = false
    
    var passedInNote: Note?
    
    var isMediaAuth = false
    
    lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userDidDoubleTapArticle(_:)))
        tapGesture.numberOfTapsRequired = 2
        tapGesture.delegate = self
        return tapGesture
    }()
    
    func userDidDoubleTapArticle(_ sender: UITapGestureRecognizer) {
        guard let parentVC = self.parentVC else { return }
        parentVC.isUserFullScreen = !parentVC.isUserFullScreen
        parentVC.updateFullScreen()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Initializers -
    
    init(article: Article, delegate: ArticleViewControllerDelegate? = nil) {
        self.article = article
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        linkClickedDelegate = self
        setup()
        update()
        NotificationCenter.default.addObserver(self, selector: #selector(fontDidChange(_:)), name: NSNotification.Name(rawValue: Notification.Font.DidChange), object: nil)
        automaticallyAdjustsScrollViewInsets = false
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var productInfoForAnalytics: String {
        get {
            let contentType = article.fullTextDownloaded ? Constants.Content.ValueTypeAbstract : Constants.Content.ValueTypeFull
            
            var bibliographicInfo: String = ""
            if let issueId = article.issue?.issueId {
                bibliographicInfo = "\(issueId)"
            }
            
            return AnalyticsHelper.MainInstance.createProductInforForEventAction(
                article.articleInfoId,
                fileFormat: Constants.Content.ValueFormatHTML,
                contentType: contentType,
                bibliographicInfo: bibliographicInfo,
                articleStatus: nil,
                articleTitle: article.articleTitle!.lowercased(),
                accessType: "article:\(article.journal.accessType!.lowercased()):standard")
        }
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        analyticsScreenName = article.fullTextDownloaded ? Constants.Page.Name.Fulltext : Constants.Page.Name.Abstract
        analyticsScreenType = Constants.Page.Type.cp_ca

        super.viewDidLoad()
    }
    
    func fontDidChange(_ notification: Foundation.Notification) {
        self.updateTextSize(TextSizeType(rawValue: notification.object as! Int)!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for media in article.allMedia where media.fileType == .Video || media.fileType == .Audio {
            updateMediaHTML(media, withStatus: media.downloadStatus)
        }
        
    }
    
    // MARK: - Setup -
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupNotifications()
        setupWebView()
        
        view.clipsToBounds = true
        
        if article.fullTextDownloadStatus != .downloaded {
            advertisementVC.setup(.iPadPortrait, journal: article.journal)
        }
        
        let addNoteBarButtonItem = UIMenuItem(title: "Add Note", action: #selector(noteMenuItemWasClicked(_:)))
        addNoteBarButtonItem.isAccessibilityElement = true
        UIMenuController.shared.menuItems = [addNoteBarButtonItem]
        let action = UIAccessibilityCustomAction.init(name: "Add note", target: self, selector: #selector(noteMenuItemWasClicked(_:)))
        webView.accessibilityCustomActions = [action]
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard article.downloadInfo.fullTextDownloadStatus == .downloaded else { return false }
        guard action == #selector(noteMenuItemWasClicked(_:)) else { return false }
        return true
    }
    
    func setupSubviews() {
        view.addSubview(containerView)
        containerView.addSubview(webView)
        containerView.addSubview(advertisementVC.view!)
        advertisementVC.view.isHidden = true
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    func setupAutoLayout() {
        constrain(webView, containerView, advertisementVC.view!) { (webView, containerView, adView) -> () in
            guard let superview = containerView.superview else { return }
            
            containerView.left   == superview.left
            containerView.top    == superview.top
            containerView.right  == superview.right
            containerView.bottom == superview.bottom
            
            webView.left   == containerView.left
            webView.top    == containerView.top
            webView.right  == containerView.right
            webView.bottom == containerView.bottom
            
            //adView.top    == webView.bottom
            //adView.right  == containerView.right
            //advertisementVC.bottomConstraint = (adView.bottom == containerView.bottom + 90)
            //adView.left   == containerView.left
        }
    }
    
    func setupNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(notification_Article_UpdateWithJavascript(_:)), name: NSNotification.Name(rawValue: Notification.Article.UpdateWithJavascript), object: article)
        
        // Abstract
        
        if article.downloadInfo.abstractDownloadStatus != .downloaded && article.downloadInfo.abstractDownloadStatus != .notAvailable {
            NotificationCenter.default.addObserver(self, selector: #selector(abstractDownloadUpdated(_:)), name: NSNotification.Name.AbstractDownloadUpdated, object: article)
        }
        
        if article.downloadInfo.abstractSupplDownloadStatus != .downloaded && article.downloadInfo.abstractSupplDownloadStatus != .notAvailable {
            NotificationCenter.default.addObserver(self, selector: #selector(abstractSupplementDownloadUpdated(_:)), name: NSNotification.Name(rawValue: Notification.Download.AbstractSupplement.started), object: article)
            NotificationCenter.default.addObserver(self, selector: #selector(abstractSupplementDownloadUpdated(_:)), name: NSNotification.Name(rawValue: Notification.Download.AbstractSupplement.Successful), object: article)
        }
        
        // Full Text
        
        if article.downloadInfo.fullTextDownloadStatus != .downloaded && article.downloadInfo.fullTextDownloadStatus != .notAvailable {
            NotificationCenter.default.addObserver(self, selector: #selector(fullTextDownloadUpdated(_:)), name: NSNotification.Name.FullTextDownloadUpdated, object: article)
        }
        if article.downloadInfo.fullTextDownloadStatus != .downloaded && article.downloadInfo.fullTextDownloadStatus != .notAvailable {
            NotificationCenter.default.addObserver(self, selector: #selector(fullTextDownloadUpdated(_:)), name: NSNotification.Name(rawValue: Notification.Download.FullText.Successful), object: article)
            NotificationCenter.default.addObserver(self, selector: #selector(fullTextDownloadUpdated(_:)), name: NSNotification.Name(rawValue: Notification.Download.FullText.started), object: article)
            NotificationCenter.default.addObserver(self, selector: #selector(fullTextDownloadUpdated(_:)), name: NSNotification.Name(rawValue: Notification.Download.FullText.Failure), object: article)
            NotificationCenter.default.addObserver(self, selector: #selector(fullTextDownloadUpdated(_:)), name: NSNotification.Name(rawValue: Notification.Download.FullText.Updated), object: article)
        }
        
        if article.downloadInfo.fullTextSupplDownloadStatus != .downloaded && article.downloadInfo.fullTextSupplDownloadStatus != .notAvailable {
            NotificationCenter.default.addObserver(self, selector: #selector(fullTextSupplementDownloadUpdated(_:)), name: NSNotification.Name.FullTextSupplementDownloadUpdated, object: article)
        }
        
        if let issue = article.issue {
            NotificationCenter.default.addObserver(self, selector: #selector(fullTextSupplementDownloadUpdated(_:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.UpdateCount), object: issue)
            NotificationCenter.default.addObserver(self, selector: #selector(fullTextDownloadUpdated(_:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.DownloadComplete), object: issue)
        }

        for media in article.allMedia where (media.fileType == .Audio || media.fileType == .Video) {
            NotificationCenter.default.addObserver(self, selector: #selector(mediaDownloadStatusUpdated(_:)), name: NSNotification.Name(rawValue: Notification.Download.Media.Updated), object: media)
        }
    }
    
    func downloadIssueUpdated(notification: NSNotification) {
        
    }
    
    func setupWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = UIColor.white
        webView.delegate = self
        webView.scrollView.delegate = self
        webView.scalesPageToFit = true
        webView.addGestureRecognizer(doubleTapGestureRecognizer)
        webView.dataDetectorTypes = UIDataDetectorTypes()
    }
    
    func setupMedia() {
        for media in article.allMedia {
            switch media.fileType {
            case .Audio, .Video:
                updateMediaHTML(media, withStatus: media.downloadStatus)
            default:
                break
            }
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        updateNavigationItemsForScreenType(screenType)
    }
    
    // MARK: - Update -
    
    func update() {
        loadHTML()
    }
    
    func updateNavigationItemsForScreenType(_ type: ScreenType) {
        performOnMainThread { 
            switch type {
            case .tablet:
                self.parentVC?.navigationItem.rightBarButtonItems = self.parentVC?.rightBarButtonItems
            default:
                break
            }
        }
    }
    
    // MARK: - Notifications -
    
    // MARK: Abstract
    
    
    func abstractDownloadUpdated(_ notification: Foundation.Notification) {
        guard let article = notification.object as? Article else {
            return
        }
        switch article.downloadInfo.abstractDownloadStatus {
        case .downloaded:
            loadHTML()
        default:
            break
        }
    }
    
    // MARK: Abstract Supplements
    
    func abstractSupplementDownloadUpdated(_ notification: Foundation.Notification) {
        guard let article = notification.object as? Article else {
            return
        }
        for media in article.allMedia where ((media.fileType == .Video || media.fileType == .Audio) && media.articleType == .abstract) {
            updateMediaHTML(media, withStatus: media.downloadStatus)
        }
    }
    
    // MARK: FullText
    
    
    func fullTextDownloadUpdated(_ notification: Foundation.Notification) {
        guard let article = notification.object as? Article else {
            return
        }
        switch article.fullTextDownloadStatus {
        case .downloaded:
            performOnMainThread({
                self.reloadHTML()
            })
        case .downloading:
            performOnMainThread({ 
                self.replaceDownloadWithDownloading()
            })
        case .downloadFailed:
            guard self.article.articleId == article.articleId else {
                return
            }
            performOnMainThread({ 
                self.reloadHTML()
            })
        default:
            break
        }
        
    }
    
    // MARK: Full Text Supplement
    
    func fullTextSupplementDownloadUpdated(_ notification: Foundation.Notification) {
        for media in article.allMedia where ((media.fileType == .Audio || media.fileType == .Video) && media.articleType == .fullText) {
            updateMediaHTML(media, withStatus: media.downloadStatus)
        }
    }
    
    // MARK: Javascript
    
    func notification_Article_UpdateWithJavascript(_ notification: Foundation.Notification) {
        guard let js = notification.object as? String else {
            log.warning("Notificaion Should Be A String")
            return
        }
        webView.stringByEvaluatingJavaScript(from: js)
    }
    
    // MARK: Media
    
    func mediaDownloadStatusUpdated(_ notification: Foundation.Notification) {
        guard let media = notification.object as? Media else {
            return
        }
        updateMediaHTML(media, withStatus: media.downloadStatus)
    }
    
    // MARK: - HTML -
    
    func loadHTML() {
        if article.downloadInfo.fullTextDownloadStatus == .downloaded {
            articleType = .fullText
            loadFullText()
        } else if article.downloadInfo.abstractDownloadStatus == .downloaded {
            articleType = .abstract
            loadAbstract()
        } else {
            loadNonAbstract()
        }
    }
    
    func reloadHTML() {
        if article.downloadInfo.fullTextDownloadStatus == .downloaded {
            parentVC?.utilityToolbar.update(article)
            analyticsDelegate?.sendAnalyticsFor(article: article, withViewController: self, withScreenType: Constants.ScreenType.FullText)
            articleType = .fullText
            loadFullText()
        } else if article.downloadInfo.abstractDownloadStatus == .downloaded {
            articleType = .abstract
            loadAbstract()
        } else {
            loadNonAbstract()
        }
    }
    
    func loadFullText() {
        
        performOnMainThread { 
            self.advertisementVC.bottomConstraint?.constant = 90
        }
        
        do {
            var html = try String(contentsOfFile: article.fulltextHTMLPath)
            let baseURLPath = article.fulltextBasePath
            
            html = html.replacingOccurrences(of: "\\", with: "\"")
            html = html.replacingOccurrences(of: "  ", with: " ")
            html = html.replacingOccurrences(of: "</body ", with: "</body >")

            webView.loadHTMLString(html, baseURL: URL(string: baseURLPath))
            fullText = true
            parentVC?.updateForCenterArticle()
        } catch let error as NSError {
            log.error(error.localizedDescription)
            let _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func loadAbstract() {
        do {
            let html = try String(contentsOfFile: article.abstractHTMLPath)
            let baseURLPath = article.abstractDirectory
            webView.loadHTMLString(html, baseURL: URL(string: baseURLPath))
            addIssueDownloadingView()
        } catch let error as NSError {
            log.error(error.localizedDescription)
           let _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func loadNonAbstract() {
        if let html = NonAbstractHTML(article: article) {
            webView.loadHTMLString(html.html, baseURL: nil)
        } else {
            log.error("Unable To Create Non Abstract HTML")
        }
    }
    
    // MARK: - How To Use The App -
    
    func showHowToUseTheApp() {
        if UserConfig.MainInstance.ShowHowToUseTheApp == true {
            let howToUseVC = HowToUseTheAppController()
            let navigationVC = UINavigationController(rootViewController: howToUseVC)
            navigationVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
            present(navigationVC, animated: true, completion: nil)
            UserConfig.MainInstance.ShowHowToUseTheApp = false
        }
    }

    
    // MARK: - Media -
    
    
    func updateMediaHTML(_ media: Media, withStatus status: DownloadStatus) {
        performOnMainThread { 
            var text: String = ""

            switch media.downloadStatus {
            case .notDownloaded:
                text = "updateMediaStatus('\(media.fileName)', 0);"
            case .downloading:
                text = "updateMediaStatus('\(media.fileName)', 1);"
            case .downloaded:
                text = "updateMediaStatus('\(media.fileName)', 2);"
            default:
                break
            }
            self.webView.stringByEvaluatingJavaScript(from: text)
        }
    }
    
    // MARK: - IP Auth -
    
    func loadIPAuth() {
        guard article.downloadInfo.fullTextDownloadStatus == .downloaded else {
            return
        }
        
        if let ipAuth = article.ipAuthentication {
            sendIPUsage()
            if IPInfo.Instance.shouldShowIPBanner {
                addIPBanner(ipAuth)
            } else {
                if IPInfo.Instance.currentIPBanner != ipAuth.bannerText! {
                    addIPBanner(ipAuth)
                }
            }
        } else if article.isArticleOpenAccessOrArchive {
            if IPInfo.Instance.isDate(article.dateOfRelease, validForISSN: article.journal.issn) {
                if let banner = IPInfo.Instance.currentIPBanner {
                    addIPBannerText(banner)
                }
                sendIPUsage()
            }
        }
        
        
    }
    
    func addIPBanner(_ ipAuth: IPAuthentication) {
        if let bannerText = ipAuth.titleId {
            addIPBannerText(bannerText)
        }
    }
    
    func addIPBannerText(_ bannerText: String) {
        if bannerText != "" {
            let method = "ipInfoBanner('\(bannerText)')"
            webView.stringByEvaluatingJavaScript(from: method)
            IPInfo.Instance.currentIPBanner = bannerText
            IPInfo.Instance.shouldShowIPBanner = true
        }
    }
    
    func sendIPUsage() {
        APIManager.sharedInstance.reportUsageForArticle(article, formatType: .HTML, completion: nil)
    }
    
    func hideIPAuth() {
        webView.stringByEvaluatingJavaScript(from: "closeIPInfo();")
        IPInfo.Instance.shouldShowIPBanner = false
    }
    
    // MARK: - Web View Delegate -
    
    func downloadArticle(_ article: Article) {
        let alertVC = Alerts.Download(article: article, completion: { (push) in
            guard push else { return }
            self.sendContentDownloadAnalytics(article: article)
            performOnMainThread({
                self.replaceDownloadWithDownloading()
            })
        })
        performOnMainThread {
            self.present(alertVC, animated: true, completion: nil)
        }
    }

    override func pushViewControllerWith(_articles: [Article]?, firstArticle: Article, issue: Issue?) {

        return
    }
    
    func handleElsevierLink(url: URL) {
        if url.host == "deeplink" || url.host == "viewarticle" {
            handleReferenceLink(url: url)
        }
    }
    
    func handleReferenceLink(url: URL) {
        let parameters = url.parameters()
        
        guard let journalIssn = parameters["issn"] else {
            return
        }
        let issuePii = parameters["issuepii"]
        guard let articlePii = parameters["articlepii"] else {
            return
        }
        
        let referenceVC = ReferenceLinkViewController(journalIssn: journalIssn, issuePii: issuePii, articlePii: articlePii)
        let navigationController = UINavigationController(rootViewController: referenceVC)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
        present(navigationController, animated: true, completion: nil)
        return
    }
    
    private func deepLinkForArticle(_ article: Article) {
        performOnMainThread {
            let info = Overlord.CurrentAppInformation(publisher: article.journal.publisher, journal: article.journal, issue: article.issue, article: article)
            if article.issue != nil {
                AppDelegate.shared.overlord?.navigateToViewControllerType(.issueArticle, appInfo: info)
            } else {
                AppDelegate.shared.overlord?.navigateToViewControllerType(.aipArticle, appInfo: info)
            }
        }
    }
    
    func handleMailTo(url: URL) {
        guard NETWORK_AVAILABLE == true && NETWORKING_ENABLED else {
            Alerts.NoNetwork().present(from: self)
            return
        }
        
        let emailAddress = url.absoluteString.replacingOccurrences(of: "mailto:", with: "")
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([emailAddress])
            mail.setMessageBody("", isHTML: true)
            
            present(mail, animated: true, completion: nil)
        } else {
            // show failure alert
        }
    }
    
    func handleArticleLinkClicked(request: URLRequest) -> Bool {
        guard let url = request.url else {
            return false
        }
        
        if url.scheme == "elsevier" || url.scheme == "elsevier-jbsm" || url.scheme == "elseview-jbsm" {
            handleElsevierLink(url: url)
            return false
        }
        
        if url.absoluteString.contains("mailto:") {
            handleMailTo(url: url)
            return false
        }
        if url.absoluteString.contains("crossmark") {
            let parameters = url.parameters()
            guard let articlePii = parameters["articlepii"] else {
                return false
            }
            pushCrossmarkVC(sender: self, issn: article.journal.issn, articlePii: articlePii)
            return false
        }
        
        if url.absoluteString == "dl://article" {
            
            guard NETWORK_AVAILABLE == true && NETWORKING_ENABLED else {
                Alerts.NoNetwork().present(from: self)
                return false
            }
            userDidRequestFullTextDownload(article, pushVC: false)
            return false
        }
        
        if url.absoluteString.contains("didtap://closeBanner") {
            hideIPAuth()
            return false
        }
        
        if url.absoluteString.contains("highlight:") {
            let highlightId = url.absoluteString.replacingOccurrences(of: "highlight:", with: "")
            loadAddNoteView(highlightId)
            return false
        }
        
        if let fileName = url.fileName() {
            if let media = article.mediaForFile(fileName) {
                
                if media.downloadStatus != .downloaded {
                    if InternetHelper.sharedInstance.available == false {
                        performOnMainThread({
                            self.present(Alerts.NoNetwork(), animated: true, completion: nil)
                        })
                        return false
                    }
                }
                switch media.fileType {
                    
                case .Audio, .Video:
                    
                    let parameters = url.parameters()
                    
                    if let requestType = parameters["request"] {
                        if requestType == "download" {
                            let downloadStatus = media.downloadStatus
                            guard downloadStatus != .downloading && downloadStatus != .downloaded else {
                                return false
                            }
                            switch media.articleType {
                            case .fullText:
                                if media.userHasAccess {
                                    showDownloadDialogueForMedia(media)
                                } else if article.userHasAccess == false {
                                    showMediaAuthenticationAlert(media: media, forDownload:  true)
                                }
                            case .abstract:
                                showDownloadDialogueForMedia(media)
                            }
                        } else if requestType == "stream" {
                            switch media.articleType {
                            case .fullText:
                                if media.userHasAccess || media.downloadStatus == .downloaded || media.downloadStatus == .downloading {
                                    delegate?.articleViewController(self, didRequestMedia: media)
                                } else {
                                    showMediaAuthenticationAlert(media: media, forDownload: false)
                                }
                            case .abstract:
                                delegate?.articleViewController(self, didRequestMedia: media)
                            }
                        } else {
                            log.error("Request Type is neither 'download' or 'stream'")
                        }
                    } else {
                        if media.downloadStatus == .downloaded {
                            delegate?.articleViewController(self, didRequestMedia: media)
                        } else {
                            showDownloadDialogueForMedia(media)
                        }
                    }
                default:
                    delegate?.articleViewController(self, didRequestMedia: media)
                }
                return false
            }
        }
        
        if url.absoluteString.contains("/ci/widget/") {
            delegate?.articleViewController(self, didRequestURL: url, ofType: .contentInnovation)
            return false
        }
        
        if url.absoluteString.contains(article.fulltextBasePath) {
            return true
        }
        
        if url.absoluteString.contains("www.kiwidemourl.com") {
            return false
        }
        
        if url.absoluteString.contains("file:///show/") {
            let fileName = url.absoluteString.replacingOccurrences(of: "file:///show/", with: "")
            let htmlName = fileName + ".html"
            let basePath = CachesDirectoryPath + "/Licenses/" + htmlName
            
            do {
                let html = try String(contentsOfFile: basePath)
                loadHTMLString(html)
            } catch let error as NSError {
                log.error(error.localizedDescription)
            }
            return false
        }
        
        delegate?.articleViewController(self, didRequestURL: url, ofType: .external)
        
        return false
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        switch navigationType {
        case .linkClicked:
            guard let result = linkClickedDelegate?.handleArticleLinkClicked(request: request) else {
                return false
            }
            return result 
        default:
            break
        }
        
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //  Going to have to begin step through here I think (bad access crash on -setupMedia)
        
        setupMedia()
        updateCSSForNotes()
        if let textSize = UserDefaults.standard.value(forKey: Strings.TextSize.UserDefaultsKey) as? Int {
            webViewShouldZoomToLevel(textSize)
        }
        
        if article.downloadInfo.fullTextDownloadStatus == .downloaded {
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Article.Finished), object: nil, userInfo: ["article":article])
            performOnMainThread({ 
                self.showHowToUseTheApp()
            })
        }
        
        if article.downloadInfo.fullTextDownloadStatus == .downloading {
            addDownloadingView()
        } else if article.downloadInfo.fullTextDownloadStatus != .downloaded {
            addIssueDownloadingView()
        }
        
        if let note = self.passedInNote {
            performOnMainThread({ 
                self.webView.stringByEvaluatingJavaScript(from: "window.location.hash = ''")
                self.webView.stringByEvaluatingJavaScript(from: "window.location.hash = '\(note.highlightId)';")
            })
            
        }
        self.passedInNote = nil
        
        if article.openAccess.oaIdentifier != 0 {
            if let text = article.openAccess.oaInfoHTML {
                self.webView.stringByEvaluatingJavaScript(from: "populateArticleInfoHtml(\"\(text)\",\"ios\")")
                performOnMainThreadAfter(seconds: 1, tasks: { 
                    self.webView.stringByEvaluatingJavaScript(from: "populateArticleInfoHtml(\"\(text)\",\"ios\")")
                })
            }
        }
        
        loadIPAuth()
        performOnMainThread { 
            self.updateWebViewContentSizeToFitFrame()
        }
        
        switch article.downloadInfo.fullTextDownloadStatus {
        case .downloaded:
            break
        default:
            performOnMainThread({ 
                self.webView.stringByEvaluatingJavaScript(from: "document.body.style.paddingBottom = '100px'")
            })
        }
        
        changeAudioVideoForOldHTML()
        updateWebViewForContentSize()
    }
    
    func changeAudioVideoForOldHTML() {
        guard let path = Bundle.main.path(forResource: "search", ofType: "html") else { return }
        do {
            let jsCode = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            let ftCode = jsCode + "testMultimediaExist()"
            let absCode = jsCode + "testMultimediaExistForAbstract()"
            webView.stringByEvaluatingJavaScript(from: ftCode)
            webView.stringByEvaluatingJavaScript(from: absCode)
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
    }
    
    func updateWebViewContentSizeToFitFrame() {
        let height = self.webView.scrollView.contentSize.height
        let width = self.view.frame.width
        self.webView.bounds = CGRect(x: 0, y: 0, width: width, height: self.view.frame.size.height)
        self.webView.frame = CGRect(x: 0, y: 0, width: width, height: self.view.frame.size.height)
        self.webView.scrollView.contentSize = CGSize(width: width, height: height)
        self.updateViewConstraints()
        self.webView.setNeedsDisplay()
        self.webView.setNeedsLayout()
        self.webView.scrollView.setNeedsDisplay()
        self.webView.scrollView.setNeedsLayout()
        self.webView.scrollView.updateConstraints()
        self.webView.scrollView.contentSize = CGSize(width: width, height: height)
        
        
        self.webView.scalesPageToFit = true
    }
    
    func updateWebViewForContentSize() {
        self.webView.scalesPageToFit = true
        
        performOnMainThreadAfter(seconds: 1) {
            let height = self.webView.scrollView.contentSize.height
            let width = self.view.frame.width
            self.webView.scrollView.contentSize = CGSize(width: width, height: height)
        }
        
    }
    
    // MARK: - Notes -
    
    func noteMenuItemWasClicked(_ sender: UIMenuItem) {
        
        if parentVC?.drawerIsOpen == true {
            performOnMainThread {
                self.parentVC?.openDrawer(false)
            }
        }
        
        let bundlePath = Bundle.main.bundlePath
        let searchHTMLPath = bundlePath + "/search.html"
        let notePadImagePath = bundlePath + "/notePad.png"
        
        do {
            var searchJS = try String(contentsOfFile: searchHTMLPath)
            searchJS.append("highlightsText('\(notePadImagePath)')")
            
            DispatchQueue.main.async(execute: {
                
                self.webView.stringByEvaluatingJavaScript(from: "closeIPInfo();")
                var htmlContent = self.webView.stringByEvaluatingJavaScript(from: searchJS)
                if let auth = self.article.ipAuthentication {
                    self.addIPBanner(auth)
                }
                
                guard let selectionComponents = htmlContent?.components(separatedBy: "<noteseparator>") else {
                    return
                }
                guard selectionComponents.count > 2 else {
                    return
                }
                
                htmlContent = selectionComponents[0]
                let idString = selectionComponents[1]
                var highlightText = selectionComponents[2]
                
                highlightText = highlightText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                highlightText = highlightText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                var dataSource = NoteViewDataSource(article: self.article, highlightedText: highlightText)
                dataSource.noteId = idString
                dataSource.savedOnDate = DateFormatter(dateFormat: "MMM dd, yyyy HH:mm:ss").string(from: Date())
                dataSource.selectionInnerHTMLString = htmlContent
                dataSource.showUserNote = ""
                
                let addNoteView = AddNoteView(dataSource: dataSource)
                addNoteView.modalPresentationStyle = .custom
                addNoteView.delegate = self
                self.parent?.present(addNoteView, animated: true, completion: nil)
            })
            
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
    }
    
    func loadAddNoteView(_ highlightId: String) {
        DispatchQueue.main.async(execute: {
            if let note = DatabaseManager.SharedInstance.getNote(article: self.article, highlightId: highlightId) {
                let dataSource = NoteViewDataSource(note: note)
                
                let addNoteView = AddNoteView(dataSource: dataSource)
                addNoteView.modalPresentationStyle = .custom
                addNoteView.delegate = self
                self.parent?.present(addNoteView, animated: true, completion: nil)
            }
        })
    }
    
    func noteViewDidClickUpdateNote(_ note: Note, userNote: String) {
        DatabaseManager.SharedInstance.performChangesAndSave { 
            note.noteText = userNote
        }
    }
    
    func noteViewDidClickSaveText(_ dataSource: NoteViewDataSource) {
        analyticsDelegate?.articleTagAction(article: self.article, withAction: AnalyticsHelper.ContentAction.addNote)
        do {
            let htmlPath = dataSource.article!.fulltextHTMLPath
            self.webView.stringByEvaluatingJavaScript(from: "closeIPInfo();")
            let htmlString = try String(contentsOfFile: htmlPath, encoding: String.Encoding.ascii)
            if let auth = self.article.ipAuthentication {
                self.addIPBanner(auth)
            }
            
            
            
            let htmlComponents = htmlString.components(separatedBy: "<body")
            let htmlFooterComponents = htmlString.components(separatedBy: "</body>")
            
            var headerComponent: String = ""
            var bodyComponent: String = ""
            var footerComponent: String = ""
            
            if htmlComponents.count > 0 {
                headerComponent = htmlComponents[0]
                let bodyStyleComponents = htmlComponents[1].components(separatedBy: ">")
                if bodyStyleComponents.count > 0 {
                    bodyComponent = bodyStyleComponents[0]
                }
            }
            
            if htmlFooterComponents.count > 1 {
                footerComponent = htmlFooterComponents[1]
            }
            
            var finalHTML = headerComponent + "<body \(bodyComponent)>"
            if let selectionInnerHTMLString = dataSource.selectionInnerHTMLString {
                finalHTML.append(selectionInnerHTMLString)
            }
            finalHTML.append("</body \(footerComponent)")
            
            try finalHTML.write(toFile: dataSource.article!.fulltextHTMLPath, atomically: true, encoding: String.Encoding.utf8)
            
            DatabaseManager.SharedInstance.performChangesAndSave({
                DatabaseManager.SharedInstance.addOrUpdateNote(self.article, selectedText: dataSource.highlightedText!, noteText: dataSource.note!, highlightId: dataSource.noteId!)
                self.parentVC?.updateForCenterArticle()
            })
            
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
    }
    
    func noteViewDidClickDelete(_ note: Note) {
        performOnMainThread { 
            self.removeNoteForId(note.highlightId)
            
            let db = DatabaseManager.SharedInstance
            db.performChangesAndSave({
                db.moc?.delete(note)
                self.parentVC?.updateForCenterArticle()
            })
            
        }
    }
    
    func noteViewDidClickCancel(_ noteId: String) {
        removeNoteForId(noteId)
    }
    
    func removeNoteForId(_ noteId: String) {
        performOnMainThread { 
            do {
                let path = Bundle.main.bundlePath + "/search.html"
                let jsCode = try String(contentsOfFile: path)
                let deleteJSString = jsCode + "deletetagValue('\(noteId)')"
                self.webView.stringByEvaluatingJavaScript(from: deleteJSString)
                let getInnerHTMLJS = jsCode + "getInnerHtml();"
                guard let selectionString = self.webView.stringByEvaluatingJavaScript(from: getInnerHTMLJS) else {
                    return
                }
                let filePath = self.article.fulltextHTMLPath
                let savedHTML = try String(contentsOfFile: filePath)
                
                let htmlComponents = savedHTML.components(separatedBy: "<body")
                
                var headerComponent: String = ""
                var bodyComponent: String = ""
                var footerComponent: String = ""
                
                if htmlComponents.count > 0 {
                    headerComponent = htmlComponents[0]
                    if htmlComponents.count > 1 {
                        var bodyStyleComp = htmlComponents[1].components(separatedBy: ">")
                        if bodyStyleComp.count > 0 {
                            bodyComponent = bodyStyleComp[0]
                        }
                    }
                }
                
                var htmlFooterComponents = savedHTML.components(separatedBy: "</body")
                if htmlFooterComponents.count > 1 {
                    footerComponent = htmlFooterComponents[1]
                }
                
                var finalHTML = headerComponent + "<body \(bodyComponent)>"
                finalHTML = finalHTML + selectionString
                finalHTML = finalHTML + "</body \(footerComponent)"
                try finalHTML.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
                
            } catch let error as NSError {
                log.error(error.localizedDescription)
            }
        }
    }
    
    func updateCSSForNotes() {
        do {
            
            let bundlePath = Bundle.main.bundlePath
            
            let stylescriptJSPath = bundlePath + "/stylescript.js"
            let noteImagePath = bundlePath + "/notePad.png"
            
            var jsChangeImageString  = try String(contentsOfFile: stylescriptJSPath)
            jsChangeImageString.append("changeNotesIconImage('\(noteImagePath)');")

            var jsChangeCSSScript = try String(contentsOfFile: stylescriptJSPath)
            jsChangeCSSScript.append("changeNotesIconCSS();")
            
            DispatchQueue.main.async(execute: { 
                self.webView.stringByEvaluatingJavaScript(from: jsChangeImageString)
                self.webView.stringByEvaluatingJavaScript(from: jsChangeCSSScript)
                self.webView.stringByEvaluatingJavaScript(from: "document.body.style.webkitTouchCallout='none';")
            })

        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
    }
    
    func noteViewDidSendMail() {
        
        //  Display alert
        
        performOnMainThread { 
            
            self.dismiss(animated: true) {
                
                let alert = Alerts.MailSent()
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: - Text Size -
    
    func textSizeShouldUpdateToSize(_ textSize: TextSizeType) {
        AnalyticsHelper.MainInstance.analyticsTagAction(.font, additionalInfo: "")
        updateTextSize(textSize)
    }
    
    func updateTextSize(_ textSize: TextSizeType) {
        performOnMainThread { 
            self.webViewShouldZoomToLevel(textSize.rawValue)
        }
    }
    
    func webViewShouldZoomToLevel(_ level: Int) {
        performOnMainThread { 
            self.webView.stringByEvaluatingJavaScript(from: "zoomIn(\(level))")
        }
    }
    
    // MARK: - Downloading Views -
    
    fileprivate let downloading_article = "downloading-article"
    fileprivate let download_article = "download-article"
    
    fileprivate let downloading_issue = "downloading-issue"
    fileprivate let download_issue = "download-issue"
    
    func addIssueDownloadingView() {
        
        var articleDownloading: Bool?
        if let vc = parentVC {
            if vc.cameFromReadingList {
                articleDownloading = true
            }
        }
        if articleDownloading == .none {
            if article.issue == .none {
                articleDownloading = true
            } else {
                articleDownloading = false
            }
        }
        guard let _articleDownloading = articleDownloading else { return }
        
        var fileName: String
        if _articleDownloading {
            fileName = download_article
        } else {
            fileName = article.isArticleOnlyOpenAccess ? download_article : download_issue
        }

        guard let downloadPath = Bundle.main.path(forResource: fileName, ofType: "html") else { return }
        do {
            let downloadHTML = try NSString(contentsOfFile: downloadPath, encoding: String.Encoding.utf8.rawValue)
            let html  = "var para = document.createElement(\"div\"); para.setAttribute(\"id\", \"swiftdownloadbox\"); para.innerHTML = \"\(downloadHTML)\"; document.body.appendChild(para);"
            webView.stringByEvaluatingJavaScript(from: html)
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
    }
    
    func addDownloadingView() {
        
        var articleDownloading: Bool?
        if let vc = parentVC {
            if vc.cameFromReadingList {
                articleDownloading = true
            }
        }
        if articleDownloading == .none {
            if article.issue == .none {
                articleDownloading = true
            } else {
                articleDownloading = false
            }
        }
        
        guard let _articleDownloading = articleDownloading else { return }
        
        var fileName: String
        if _articleDownloading {
            fileName = "downloading-article"
        } else {
            fileName = article.isArticleOnlyOpenAccess ? "downloading-article" : "downloading-issue"
        }
        
        guard let downloadingPath = Bundle.main.path(forResource: fileName, ofType: "html") else { return }
        do {
            let downloadingHTML = try NSString(contentsOfFile: downloadingPath, encoding: String.Encoding.utf8.rawValue)
            let html  = "var para = document.createElement(\"div\"); para.setAttribute(\"id\", \"swiftdownloadbox\"); para.innerHTML = \"\(downloadingHTML)\"; document.body.appendChild(para);"
            webView.stringByEvaluatingJavaScript(from: html)
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
    }
    
    func replaceDownloadWithDownloading() {
        
        var articleDownloading: Bool?
        if let vc = parentVC {
            if vc.cameFromReadingList {
                articleDownloading = true
            }
        }
        if articleDownloading == .none {
            if article.issue == .none {
                articleDownloading = true
            } else {
                articleDownloading = false
            }
        }
        
        var fileName: String
        if articleDownloading == true {
            fileName = "downloading-article"
        } else {
            fileName = article.isArticleOnlyOpenAccess ? "downloading-article" : "downloading-issue"
        }

        guard let downloadingPath = Bundle.main.path(forResource: fileName, ofType: "html") else { return }
        do {
            let downloadingHTML = try NSString(contentsOfFile: downloadingPath, encoding: String.Encoding.utf8.rawValue)
            let html = "var div = document.getElementById(\"swiftdownloadbox\"); div.innerHTML = \"\(downloadingHTML)\";"
            webView.stringByEvaluatingJavaScript(from: html)
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Article.Started), object: self, userInfo: ["article": article])
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
    }
    
    // MARK: - Became Active -
    
    func didBecomeCenterArticle() {
        if let textSize = UserDefaults.standard.value(forKey: Strings.TextSize.UserDefaultsKey) as? Int {
            webViewShouldZoomToLevel(textSize)
        }
        let screenType = article.downloadInfo.fullTextDownloadStatus == .downloaded ? Constants.ScreenType.FullText : Constants.ScreenType.Abstract
        analyticsDelegate?.sendAnalyticsFor(article: article, withViewController: self, withScreenType: screenType)
        performOnMainThread { 
            self.webView.becomeFirstResponder()
        }
    }
    
    // MARK: - Authentication -
    
    func loadExternalURL(_ url: URL) {
        loadAndPresentURL(url: url)
    }
    
    func loadHTMLString(_ htmlString: String) {
        let webViewController = WebViewController()
        webViewController.enabled = false
        webViewController.string = htmlString
        webViewController.contentType = WebViewControllerContentTypes.string
        webViewController.isDismissable = true
        let navigationVC = UINavigationController(rootViewController: webViewController)
        present(navigationVC, animated: true, completion: nil)
    }
}

//  MARK: LoginVcDelegate override

extension ArticleViewController {
    
    override func didLoginForMedia(_ media: Media, forDownload: Bool) {
        super.didLoginForMedia(media, forDownload: forDownload)

        delegate?.articleViewController(self, didRequestMedia: media)
    }
}
