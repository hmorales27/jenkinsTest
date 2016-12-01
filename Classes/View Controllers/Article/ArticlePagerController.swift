//
// ArticlePagerController
//

import UIKit
import Cartography
import SafariServices
import MessageUI
import Social

enum ArticlePagerType {
    case article
    case cme
    case advertisement
}
enum Direction {
    case FORWARD
    case BACKWARD
}
class ArticlePagerItem {
    let type: ArticlePagerType
    var article: Article?
    var orderIndex: Int?
    
    init(type: ArticlePagerType, article: Article? = nil) {
        self.type = type
        if let _article = article {
            self.article = _article
        }
    }
}

class ArticlePagerController: JBSMViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, ArticleNavigationDelegate, ArticleUtilityToolbarDelegate, CIManagerDelegate, CIAvailabilityViewDelegate, SupplementMediaControllerDelegate, ShareViewControllerDelegate, ArticleViewControllerDelegate, UIPopoverPresentationControllerDelegate, UIDocumentInteractionControllerDelegate, ArticleAnalyticsDelegate, ArticleInfoSlideOutProtocol {
    
    var cameFromReadingList: Bool = false
    
    weak var pageController: ArticlePagerController?
    
    var backTitleString: String?
    var isAdvertisement = false
    var isUserFullScreen = false
    var networkUnavailable = !NETWORK_AVAILABLE
    // MARK: DATA
    
    let articleCount: Int
    
    let pagerArray: [ArticlePagerItem]
    var pagerIndex: Int = -1
    
    var leftIndex: Int {
        if pagerIndex > 0 {
            if networkUnavailable && pagerArray[pagerIndex - 1].type == .advertisement && pagerIndex - 2 >= 0{
                return pagerIndex - 2
            }
            return pagerIndex - 1
        }
        return -1
    }
    var rightIndex: Int {
        if pagerIndex < pagerArray.count - 1 {
            if networkUnavailable && pagerArray[pagerIndex + 1].type == .advertisement && pagerIndex + 2 < pagerArray.count{
                return pagerIndex + 2
            }
        }
        return pagerIndex + 1
    }
    
    var leftItem: ArticlePagerItem? {
        return leftIndex >= 0 ? pagerArray[leftIndex] : nil
    }
    
    var currentItem: ArticlePagerItem! {
        return pagerArray[pagerIndex]
    }
    var rightItem: ArticlePagerItem? {
        return rightIndex < pagerArray.count ? pagerArray[rightIndex] : nil
    }
    
    var drawerIsOpen = false
    var drawerShouldBeOpen = false
    
    var passedInNote: Note?
    
    // MARK: PAGER
    
    let pager = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var pagerLeftPadding: NSLayoutConstraint?
    var pagerRightPadding: NSLayoutConstraint?
        
    let articleInfoSlideOut = ArticleInfoSlideOutViewController()
    
    var leftVC: UIViewController?
    var centerVC: UIViewController!
    var rightVC: UIViewController?
    
    // MARK: NAVIGATION
    
    var navigationToolbar: ArticleNavigationToolbar!
    
    let utilityToolbar = ArticleUtilityToolbar()
    var utilityToolbarBottomConstraint: NSLayoutConstraint?
    
    let contentInnovation = CIManager()
    let contentInnovationButton = CIAvailabilityView()
    
    let supplementController = SupplementMediaController()
    let advertisementVC = AdvertisementViewController()
    
    let reachability = Reachability.forInternetConnection()
    
    var dismissable: Bool = false
    
    let containerView = UIView()
    
    // MARK: - Initializers -
    
    init(article: Article, articleArray: [Article], dismissable _dismissable: Bool? = nil) {
        
        var _index           : Int = 0
        var _articleIndex    : Int = 0
        var _articleCount    : Int = 0
        let _adInterval      : Int = 3
        var _adCounter       : Int = 1
        var _previousArticle : Article?
        var _mappedArray     : [ArticlePagerItem]    = []
        
        while _articleIndex < articleArray.count {
            let _article = articleArray[_articleIndex]
            var _addArticle: Bool = false
            
            if _adCounter > _adInterval {
                if _previousArticle?.isCME == true || _article.isCME == true {
                    _addArticle = true
                } else {
                    _mappedArray.append(ArticlePagerItem(type: .advertisement))
                    _adCounter = 1
                }
            } else {
                _addArticle = true
            }
            if _addArticle == true {
                if _article == article {
                    self.pagerIndex = _index
                }
                let item = ArticlePagerItem(type: .article, article: _article)
                item.orderIndex = _articleIndex + 1
                _mappedArray.append(item)
                _previousArticle = _article
                _adCounter    += 1
                _articleIndex += 1
                _articleCount += 1
            }
            _index += 1
        }
        
        self.pagerArray = _mappedArray
        self.articleCount = _articleCount
        
        
        
        if let dismissable = _dismissable {
            self.dismissable = dismissable
        }
        
        super.init(nibName: nil, bundle: nil)
        
        addChildViewController(advertisementVC)
        advertisementVC.didMove(toParentViewController: self)
        
        
        self.currentJournal = article.journal
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        updateForCenterArticle()
        isAccessibilityElement = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let article = currentItem.article else { return }

        utilityToolbar.update(article)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func backButtonClicked(_ sender: UIBarButtonItem) {
        articleInfoSlideOut.hideSlideout(true)
        articleInfoSlideOut.view.isHidden = true
        super.backButtonClicked(sender)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        advertisementVC.setup(AdType.iPadPortrait, journal: currentJournal!)
    }
    
    
    // MARK: - Setup -
    
    var accessibilityItems: [AnyObject] = []
    
    
    override func accessibilityElementCount() -> Int {
        return accessibilityItems.count
    }
    
    override func accessibilityElement(at index: Int) -> Any? {
        return accessibilityItems[index]
    }
    
    override func index(ofAccessibilityElement element: Any) -> Int {
        var index = 0
        for item in accessibilityItems {
            if item === element as AnyObject {
                return index
            }
            index += 1
        }
        return index
    }
    
    func setup() {
        navigationToolbar = ArticleNavigationToolbar(screenType: self.screenType)
        articleInfoSlideOut.delegate = self
        articleInfoSlideOut.parentVC = self
        
        setupSubviews()
        setupAutoLayout()
        setupPager()
        setupSupplementMediaController()
        setupContentInnovation()
        setupNavigationBar()
        setupNavigationToolbar()
        setupUtilityToolbar()
        
        self.reachability?.startNotifier()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showNoNetworkAlert(notification:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_readinglist_showdialogue(_:)), name: NSNotification.Name.ShowReadingListDialogue, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_readinglist_removedialogue(_:)), name: NSNotification.Name.HideReadingListDialogue, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateViewControllers(notification:)), name: NSNotification.Name.reachabilityChanged, object: reachability)
        NotificationCenter.default.addObserver(self, selector: #selector(showNoNetworkAlert(notification:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        if screenType == .mobile {
            articleInfoSlideOut.view.isHidden = true
        }
    }
    
    func setupSubviews() {
        
        addChildViewController(pager)
        pager.didMove(toParentViewController: self)
        pager.delegate = self
        pager.dataSource = self
        pager.automaticallyAdjustsScrollViewInsets = false
        view.addSubview(pager.view)
        
        view.addSubview(advertisementVC.view)

        view.addSubview(contentInnovationButton)
        view.addSubview(navigationToolbar)
        view.addSubview(utilityToolbar)
        
        supplementController.setup(pager.view)
        
        view.addSubview(articleInfoSlideOut.view)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            pager.view!,
            contentInnovationButton,
            navigationToolbar,
            utilityToolbar,
            articleInfoSlideOut.view!,
            advertisementVC.view!
        ]
        
        constrain(subviews) { (views) in
            
            let pager             = views[0]
            let contentInnovation = views[1]
            let navigation        = views[2]
            let utility           = views[3]
            let articleInfo       = views[4]
            let advertisement     = views[5]
            
            guard let superview = pager.superview else {
                return
            }
            
            articleInfo.top == superview.top
            articleInfo.bottom == utility.top
            articleInfo.right == pager.left + 33
            articleInfo.width == 280 + 33
            
            pager.top == superview.top
            pagerRightPadding = (pager.right == superview.right)
            pagerLeftPadding = (pager.left == superview.left)
            
            advertisement.right == superview.right
            advertisement.bottom == pager.bottom
            advertisement.left == superview.left
            
            contentInnovation.top == superview.top + 16
            contentInnovation.right == pager.right - 16
            
            navigation.top == pager.bottom
            navigation.right == pager.right
            navigation.left == pager.left
            navigation.height == 44
            
            utility.top == navigation.bottom
            utility.right == superview.right
            utilityToolbarBottomConstraint = (utility.bottom == superview.bottom)
            utility.left == superview.left
            utility.height == 44
        }
    }
    
    func setupPager() {
        
        var viewControllers: [UIViewController] = []
        
        if let leftItem = self.leftItem {
            leftVC = viewControllerForItem(leftItem)
        }
        centerVC = viewControllerForItem(currentItem)
        if let _centerVC = centerVC as? ArticleViewController {
            _centerVC.analyticsDelegate = self
            _centerVC.didBecomeCenterArticle()
            _centerVC.passedInNote = self.passedInNote
        }
        viewControllers.append(centerVC)
        if let rightItem = self.rightItem {
            rightVC = viewControllerForItem(rightItem)
        }
        
        pager.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        centerVC.view.becomeFirstResponder()
    }
    
    func viewControllerForItem(_ item: ArticlePagerItem) -> UIViewController? {
        switch item.type {
        case .article, .cme:
            guard let article = item.article else {
                return nil
            }
            let vc = ArticleViewController(article: article, delegate: self)
            vc.parentVC = self
            return vc
        case .advertisement:
            guard DatabaseManager.SharedInstance.getAppPublisher() != nil else {
                return nil
            }
            let fullPageAd = FullPageAdViewController(journal: self.currentJournal!)
            return fullPageAd
        }
    }
    
    func setupNavigationToolbar() {
        navigationToolbar.articleNavigationDelegate = self
    }
    
    func setupUtilityToolbar() {
        utilityToolbar.utilityDelegate = self
    }
    
    func setupContentInnovation() {
        contentInnovation.delegate = self
        contentInnovationButton.delegate = self
    }
    
    func setupSupplementMediaController() {
        supplementController.delegate = self
    }
    
    
    // MARK: - Update -
    
    

    
    // MARK: - Layout -
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        updateNavigationTitle()
        updateNavigationItemsForScreenType(screenType)
        
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func updateNavigationTitle() {

    }
    
    func updateNavigationItemsForScreenType(_ type: ScreenType) {
        DispatchQueue.main.async {
            
            if self.dismissable == true {
                self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
            } else {
                var backTitle: String
                if let title = self.backTitleString {
                    backTitle = title
                } else {
                    backTitle = "Back"
                }
                let button = self.backButton(backTitle)
                
                let navButton = UIBarButtonItem(customView: button)
                
                if let customView = navButton.customView {
                    customView.accessibilityLabel = backTitle + ", back"
                }
                navButton.target = self
                navButton.action = #selector(self.backButtonClicked(_:))
                let negativeSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
                negativeSpace.width = -16
                self.navigationItem.leftBarButtonItems = [negativeSpace, navButton]
            }
            switch type {
            case .mobile:
                let bbi = UIBarButtonItem(image: UIImage(named: "NavigationOutline"), style: .plain, target: self, action: #selector(self.infoButtonWasClicked(_:)))
                bbi.accessibilityLabel = "Article citation"
                self.navigationItem.rightBarButtonItem = bbi
            case .tablet:
                self.navigationItem.rightBarButtonItems = self.rightBarButtonItems
            }
        }
    }
    
    func backButton(_ title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(backButtonClicked(_:)), for: .touchUpInside)
        
        let size = title.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]).width
        button.frame = CGRect(x: 0, y: 0, width: size + 24, height: 20)
        button.setTitle(title, for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.setTitleColor(UIColor.veryLightGray(), for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        
        let image = UIImage(named: "Back")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        button.setImage(image, for: UIControlState())
        button.tintColor = UIColor.white
        
        return button
    }
    
    // MARK: - Helpers -
    
    // MARK: - Page View Controller -
    
    var pendingVC: UIViewController?
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingVC = pendingViewControllers[0]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return rightVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return leftVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed == true {
            clearArticleAnalyticsDelegates()
            if let pendingVC = pendingVC {
                pageWithViewController(pendingVC)
                if let cvc = centerVC as? ArticleViewController {
                    cvc.analyticsDelegate = self
                    cvc.didBecomeCenterArticle()
                }
//                else if let adv = centerVC as? FullPageAdViewController {
//                    //adv.loadRequest()
//                }
                updateForCenterArticle()
            }
            
        }
        pendingVC = nil
    }
    
    func clearArticleAnalyticsDelegates() {
        if let articleVC = leftVC as? ArticleViewController {
            articleVC.analyticsDelegate = nil
        }
        if let articleVC = centerVC as? ArticleViewController {
            articleVC.analyticsDelegate = nil
        }
        if let articleVC = rightVC as? ArticleViewController {
            articleVC.analyticsDelegate = nil
        }
    }
    
    
    
    func pageWithViewController(_ viewController: UIViewController) {
        
        if viewController == leftVC {
            pageBackward()
        } else if viewController == rightVC {
            pageForward()
        } else {
            log.error("Attempting to Present a VC that's not recognized")
        }
    }
    func updatePagerIndex(direction: Direction) {
        if direction == Direction.FORWARD {
            
        }
    }
    func updateViewControllers(notification: NSNotification) {
        networkUnavailable = !NETWORK_AVAILABLE
        if let lI = leftItem {
            if let lVC = viewControllerForItem(lI) {
                leftVC = lVC
            }
        }
        if let rI = rightItem {
            if let rVC = viewControllerForItem(rI) {
                rightVC = rVC
            }
        }
    }
    func pageForward() {
        leftVC = centerVC
        centerVC = rightVC
        rightVC = nil
        pagerIndex = rightIndex
        if let rightItem = self.rightItem {
            rightVC = viewControllerForItem(rightItem)
        }
        
        if let articleVC = centerVC as? ArticleViewController {
            AnalyticsHelper.MainInstance.analyticsTagAction(AnalyticsHelper.ContentAction.next, additionalInfo: articleVC.productInfoForAnalytics)
        }
        pager.setViewControllers([centerVC], direction: .forward, animated: true, completion: nil)
    }
    
    func pageBackward() {
        rightVC = centerVC
        centerVC = leftVC
        leftVC = nil
        pagerIndex = leftIndex
        if let leftItem = self.leftItem {
            leftVC = viewControllerForItem(leftItem)
        }
        if let articleVC = centerVC as? ArticleViewController {
            AnalyticsHelper.MainInstance.analyticsTagAction(AnalyticsHelper.ContentAction.previous, additionalInfo: articleVC.productInfoForAnalytics)
        }
        pager.setViewControllers([centerVC], direction: .reverse, animated: true, completion: nil)
    }
    
    // MARK: - Article Navigation Toolbar -
    
    func articleNavigationToolbar(_ toolbar: ArticleNavigationToolbar, didSelectType type: ArticleNavigationType) {
        switch type {
        case .next:
            if let rightVC = self.rightVC {
                pageWithViewController(rightVC)
            }
        case .previous:
            if let leftVC = self.leftVC {
                pageWithViewController(leftVC)
            }
        }
        if let cvc = centerVC as? ArticleViewController {
            cvc.analyticsDelegate = self
            cvc.didBecomeCenterArticle()
        }
        performOnMainThread { 
            self.updateForCenterArticle()
        }
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    // MARK: - Article Utility Toolbar -
    
    func articleUtilityToolbar(_ toolbar: ArticleUtilityToolbar, didSelectButton button: UIBarButtonItem, ofType type: ArticleUtilityToolbarType) {
        switch type {
        case .bookmark:
            DatabaseManager.SharedInstance.performChangesAndSave({ () -> () in
                guard let article = self.currentItem.article else {
                    return
                }
                article.toggleStarred()
            })
        case .share:
            showShareSheet(button)
        case .fontSize:
            guard let articleVC = centerVC as? ArticleViewController else { return }
            let textSizeVC = TextSizeViewController()
            textSizeVC.delegate = articleVC
            let navigationVC = UINavigationController(rootViewController: textSizeVC)
            navigationVC.modalPresentationStyle = UIModalPresentationStyle.popover
            navigationVC.popoverPresentationController?.barButtonItem = toolbar.fontSizeBarButtonItem
            navigationVC.popoverPresentationController?.backgroundColor = AppConfiguration.NavigationBarColor
            navigationVC.popoverPresentationController?.delegate = self
            navigationVC.preferredContentSize = CGSize(width: 200, height: 40)
            navigationVC.popoverPresentationController?.permittedArrowDirections = .any
            present(navigationVC, animated: true, completion: nil)
        case .pdf:
            guard let article = currentItem.article else {
                return
            }
            
            let alertVC = Alerts.OpenAsPDF(article, completion: { (open) in
                guard open == true else {
                    return
                }
                switch article.downloadInfo.pdfDownloadStatus {
                case .downloaded:
                    self.showPDF(article: article)
                default:
                    if FileSystemManager.sharedInstance.pathExists(article.oldPDFFilePath) {
                        DatabaseManager.SharedInstance.performChangesAndSave({ 
                            article.downloadInfo.pdfDownloadStatus = .downloaded
                            self.showPDF(article: article)
                        })
                        return
                    }
                    performOnMainThread({
                        guard NETWORK_AVAILABLE == true else {
                            
                            self.showNoNetworkAlert(notification: nil)
                            return
                        }
                        
                        self.showPDFDownloadDialogue()
                    })
                }
            })
            alertVC.popoverPresentationController?.barButtonItem = button
            alertVC.present(from: self)
        case .info:
            break
        }
    }
    
    
    
    func openPDFWithPath(_ path: String) {
        guard let article = currentItem.article else {
            return
        }
        let pdfController = PDFPreviewControl(article: article)
        let navigationVC = UINavigationController(rootViewController: pdfController)
        performOnMainThread({
            self.present(navigationVC, animated: true, completion: nil)
        })
    }
    
    func showPDF(article: Article) {
        self.analyticsScreenViewForPDF(article: article)
        openPDFWithPath(article.pdfPath)
    }
    
    func showPDFDownloadDialogue() {
        guard let article = currentItem.article else { return }
        
        let alertVC = UIAlertController(title: "Do you want to download the PDF?", message: "", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Download PDF", style: .default, handler: { (action) in
            
            performOnMainThread({
                guard NETWORK_AVAILABLE else {
                    
                    self.showNoNetworkAlert(notification: nil)
                    return
                }
                
                let avc = UIAlertController(title: "Downloading PDF", message: "", preferredStyle: .alert)
                avc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    // TODO: Cancel Download?
                }))
                self.present(avc, animated: true, completion: nil)
                self.sendContentDownloadAnalyticsForPDF(article: article)
                
                let downloader = PDFDownload()
                downloader.downloadPDF(article, completion: { (success) in
                    performOnMainThread({
                        if success == true {
                            DatabaseManager.SharedInstance.performChangesAndSave({
                                article.downloadInfo.pdfDownloadStatus = .downloaded
                            })
                            avc.dismiss(animated: true, completion: {
                                self.showPDF(article: article)
                            })
                        }
                    })
                }, update: { (percent) in
                    performOnMainThread({
                        let _percent = Int(percent * 100)
                        avc.message = "\(_percent) %"
                    })
                    
                })
            })
            
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func showShareSheet(_ button: UIBarButtonItem) {
        
        guard NETWORK_AVAILABLE == true else {
            
            showNoNetworkAlert(notification: nil)
            return
        }
        
        
        if let articleVC = centerVC as? ArticleViewController {
            AnalyticsHelper.MainInstance.analyticsTagAction(AnalyticsHelper.ContentAction.share, additionalInfo: articleVC.productInfoForAnalytics)
        }
        guard let article = currentItem.article else {
            return
        }
        let shareVC = ShareViewController(article: article, delegate:  self)
        let navigationVC = UINavigationController(rootViewController: shareVC)
        navigationVC.modalPresentationStyle = UIModalPresentationStyle.popover
        navigationVC.popoverPresentationController?.barButtonItem = button
        navigationVC.popoverPresentationController?.backgroundColor = AppConfiguration.NavigationBarColor
        navigationVC.popoverPresentationController?.delegate = self
        navigationVC.preferredContentSize = shareVC.expectesSize
        switch self.screenType {
        case .tablet:
            navigationVC.popoverPresentationController?.barButtonItem = button
        default:
            break
        }
        present(navigationVC, animated: true, completion: {})
    }
    
    // MARK: - Content Innovation -
    
    func contentInnovationShouldHideButton() {
        DispatchQueue.main.async { 
            self.contentInnovationButton.isHidden = true
        }
    }
    
    func contentInnovationShouldShowButton(_ textToShow: String, buttonToShow: String) {
        DispatchQueue.main.async {
            if let centerVC = self.centerVC as? ArticleViewController {
                centerVC.webView.stringByEvaluatingJavaScript(from: "document.body.style.paddingTop = '50px'")
                let imagePath = CachesDirectoryPath + "appimages/" + buttonToShow
                var _image: UIImage
                if let image = UIImage(contentsOfFile: imagePath) {
                    _image = image
                } else {
                    _image = UIImage(named: "DefaultCI")!
                }
                self.contentInnovationButton.button.setImage(_image, for: UIControlState())
                self.contentInnovationButton.ciManager = self.contentInnovation
                self.contentInnovationButton.showButtonWithText(textToShow as NSString)
                
                
                //  Set value for optional on CIbutton that is reference to CIManager
                
            }
        }
    }
    
    func ciAvailabilityViewWasSelected() {
        
        guard let response = contentInnovation.response else { return }
        
        let contentInnovationVC = CIController()
        contentInnovationVC.delegate = contentInnovation
        contentInnovationVC.modalPresentationStyle = .overCurrentContext
        contentInnovationVC.modalTransitionStyle = .crossDissolve
        if let articleVC = centerVC as? ArticleViewController {
            contentInnovationVC.productInfo = articleVC.article.productInfoForHTML
        }
        
        if response.widgetModel.count == 1 {
            guard let url = URL(string: response.widgetModel[0].widgetSrcUrl) else { return }
            contentInnovationVC.setupDirectLinkForURL(url)
        }
        navigationController?.present(contentInnovationVC, animated: true, completion: nil)
    }

    // MARK: - Supplement Controller -
    
    func supplementMediaControllerActive(_ active: Bool) {
        
    }
    
    func supplementMediaControllerDidSelectType(_ type: DisplayFileType, withMedia media: [Media]) {
        var viewController: UIViewController
        switch type {
        case .Figure:
            analyticsTagSubScreen(Constants.ScreenType.Figures)
            viewController = ImagesViewController(figures: media)
        case .Table:
            analyticsTagSubScreen(Constants.ScreenType.Tables)
            viewController = TablesViewController(tables: media)
        case .Audio:
            analyticsTagSubScreen(Constants.ScreenType.Audios)
            viewController = AudiosViewController(medias: media)
        case .Video:
            analyticsTagSubScreen(Constants.ScreenType.Videos)
            viewController = VideosViewController(medias: media)
        case .Other:
            guard let article = currentItem.article else {
                return
            }
            switch article.downloadInfo.fullTextSupplDownloadStatus {
            case .downloaded:
                analyticsTagSubScreen(Constants.ScreenType.Others)
                viewController = OthersTableViewController(medias: media)
            case .downloading:
                present(Alerts.Supplement.Downloading(), animated: true, completion: nil)
                return
            default:
                if article.userHasAccess == true {
                    present(Alerts.Supplement.DownloadAll(article: article), animated: true, completion: nil)
                } else if article.userHasAccess == false {
                    
                    guard let _media = media.first else { return }
                    showMediaAuthAlert(media: _media, forDownload: true)
                }
                return
            }
        }
        navigationController?.present(UINavigationController(rootViewController: viewController), animated: true, completion: nil)
    }

    // MARK: - Article View Controller -
    
    func articleViewController(_ viewController: ArticleViewController, didRequestURL url: URL, ofType type: ArticleURLRequestType) {
        
        switch type {
            
        case .external:
            
            guard NETWORK_AVAILABLE && NETWORKING_ENABLED else {
                let alertVC = Alerts.NoNetwork()
                performOnMainThread({ 
                    self.present(alertVC, animated: true, completion: nil)
                })
                return
            }
            
            loadAndPresentURL(url: url)
            
        case .contentInnovation:
            
            guard NETWORK_AVAILABLE && NETWORKING_ENABLED else {
                let alertVC = Alerts.NoNetwork()
                performOnMainThread({
                    self.present(alertVC, animated: true, completion: nil)
                })
                return
            }
            
            if let article = self.currentItem.article {
                if contentInnovation.numberOfContentInnovations() > 1 {
                    AnalyticsHelper.MainInstance.contentInnovationAnalyticsTagAction(getProductInfoForAnalytics(article), widgetName: "")
                } else {
                    if let widget = contentInnovation.contentInnovationWidgetForInt(0) {
                        AnalyticsHelper.MainInstance.contentInnovationAnalyticsTagAction(getProductInfoForAnalytics(article), widgetName: widget.widgetName)
                    }
                }
            }
            
            let contentInnovationVC = CIController(url: url)
            contentInnovationVC.delegate = contentInnovation
            contentInnovationVC.modalPresentationStyle = .overCurrentContext
            contentInnovationVC.modalTransitionStyle = .crossDissolve
            present(contentInnovationVC, animated: true, completion: nil)
        }
    }
    
    func articleViewController(_ viewController: ArticleViewController, didRequestMedia media: Media) {
        
        var viewController: UIViewController!
        switch media.fileType {
        case .Image:
            viewController = ImagePageController(figures: [media], index: 0)
        case .Table:
            viewController = TablesViewController(tables: [media])
        case .Audio:
            viewController = AudioViewController(media: media, dismissable: true)
        case .Video:
            viewController = VideoViewController(media: media, isDismissable: true)
        case .Other, .PDF, .Document, .Presentation, .Spreadsheet:
            switch media.downloadStatus {
            case .downloaded:
                let previewer = OtherFilePreviewControl(media: media)
                previewer.navigationItem.rightBarButtonItem = nil
                previewer.currentPreviewItemIndex = 0
                previewer.navigationItem.setRightBarButtonItems(nil, animated: true)
                previewer.close = true
                //let controller = UINavigationController(rootViewController: previewer)
                //self.centerVC.presentViewController(controller, animated: true, completion: nil)
                previewer.navigationController?.navigationItem.rightBarButtonItem = nil
                navigationController?.pushViewController(previewer, animated: false)
            case .downloading:
                present(Alerts.Supplement.Downloading(), animated: true, completion: nil)
            default:
                present(Alerts.Supplement.DownloadAll(article: media.article), animated: true, completion: nil)
            }
            //openPDFWithPath(media.pathString)
            return
        default:
            break
        }
        present(UINavigationController(rootViewController: viewController), animated: true, completion: nil)
    }

    // MARK: - Share -
    
    func shareViewController(_ viewController: ShareViewController, didRequestShareOfType type: ShareType) {
        
        performOnMainThread {
            viewController.dismiss(animated: true, completion: {
                
                guard NETWORK_AVAILABLE == true else {
                    
                    Alerts.NoNetwork().present(from: self)
                    return
                }
                
                switch type {
                    
                    
                case .emailArticle:
                    self.shareArticleByEmail(withPDF: false)
                case .emailPDF:
                    if let article = self.currentItem.article {
                        AnalyticsHelper.MainInstance.analyticsTagAction(.share, additionalInfo: self.getProductInfoForAnalytics(article))
                    }
                    self.shareArticleByEmail(withPDF: true)
                case .facebook:
                    self.shareArticleViaSocial(SLServiceTypeFacebook)
                case .twitter:
                    self.shareArticleViaSocial(SLServiceTypeTwitter)
                default:
                    break
                }
            })
        }
    }
    
    func shareArticleByEmail(withPDF pdf: Bool) {
        guard let article = currentItem.article else {
            return
        }
        if pdf == true {
            if article.downloadInfo.pdfDownloadStatus == .downloaded {
                
                let data = try? Data(contentsOf: URL(fileURLWithPath: article.pdfPath))
                self.shareArticlebyEmail(withData: data)
            }
            else if article.downloadInfo.pdfDownloadStatus != .downloaded {
            
                let alertVC = UIAlertController(title: "Do you want to download the PDF?", message: nil, preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Download PDF", style: .default, handler: { (action) in
                    let downloadingVC = UIAlertController(title: "Downloading PDF", message: nil, preferredStyle: .alert)
                    downloadingVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    performOnMainThread({
                        self.present(downloadingVC, animated: true, completion: nil)
                    })
                    APIManager.sharedInstance.downloadPDF(article: article, completion: { (success) in
                        performOnMainThread({
                            downloadingVC.dismiss(animated: true, completion: {
                                if success == true {
                                    let data = try? Data(contentsOf: URL(fileURLWithPath: article.pdfPath))
                                    self.shareArticlebyEmail(withData: data)
                                }
                            })
                        })
                    })
                }))
                alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                performOnMainThread({
                    self.present(alertVC, animated: true, completion: nil)
                })
            }
        } else {
            shareArticlebyEmail(withData: nil)
        }
    }
    
    func shareArticlebyEmail(withData data: Data?) {
        performOnMainThread { 
            guard let article = self.currentItem.article else {
                return
            }
            guard MFMailComposeViewController.canSendMail() == true else {
                // TODO: Show Dialogue
                return
            }
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setBccRecipients(nil)
            mailVC.setBccRecipients(nil)
            mailVC.setSubject("Recommended article from \(article.journal.journalTitle!)")
            mailVC.setMessageBody(article.emailBody, isHTML: true)
            if let _data = data {
                mailVC.addAttachmentData(_data, mimeType: "application/pdf", fileName: article.articleTitle! + ".pdf")
            }
            self.present(mailVC, animated: true, completion: nil)
        }
    }
    
    func shareArticleViaSocial(_ type: String) {
        guard let article = currentItem.article else {
            return
        }
        let sharingAvailable = SLComposeViewController.isAvailable(forServiceType: type)
        
        let vc = sharingAvailable == true ? SLComposeViewController(forServiceType: type) : UIAlertController.init(title: "", message: "", preferredStyle: .alert)

        if let _vc = vc as? SLComposeViewController, let doiLink = article.doiLink {
            
                switch type {
                case SLServiceTypeFacebook:
                    _vc.add(URL(string: doiLink)!)
                case SLServiceTypeTwitter:
                    _vc.setInitialText(doiLink)
                default:
                    break
            }
        } else if let _vc = vc as? UIAlertController {
            
            if type == SLServiceTypeFacebook {
                _vc.title = "No Facebook account"
                _vc.message = "There are no Facebook accounts configured. You can add or create a Facebook account in Settings."
                
            } else if type == SLServiceTypeTwitter {
                _vc.title = "Can't send tweet"
                _vc.message = "You can't send a tweet right now. Make sure your device has an internet connection and you have at least one Twitter account setup."
            }
            _vc.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
        }
        performOnMainThread {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    //  MARK: - Alerts - 
    
    func showNoNetworkAlert(notification: NSNotification?) {
        
        guard NETWORK_AVAILABLE == false || NETWORKING_ENABLED == false else {
            
            return
        }
        
        Alerts.NoNetwork().present(from: self)
    }
    
    func notification_readinglist_showdialogue(_ notification: NSNotification) {
        guard let article = currentItem.article else {
            return
        }
        let alertVC = Alerts.AddToReadingList { (goToReadingList) in
            let bookmarkVC = BookmarksViewController(journal: article.journal)
            self.navigationController?.popToRootViewControllerAndLoadViewController(bookmarkVC)
        }
        performOnMainThread {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func notification_readinglist_removedialogue(_ notification: Foundation.Notification) {
        
        let alert = Alerts.RemovedFromReadingList()
        performOnMainThread {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func infoButtonWasClicked(_ sender: UIBarButtonItem) {
        performOnMainThread { 
            guard let article = self.currentItem.article, let viewController = self.centerVC as? ArticleViewController else {
                return
            }
            let articleInfoVC = ArticleInfoViewController(article: article, webView: viewController)
            articleInfoVC.parentVC = self
            let navigationVC = UINavigationController(rootViewController: articleInfoVC)
            self.present(navigationVC, animated: true, completion: nil)
        }
    }
    
    func analyticsTagSubScreen(_ viewType: String) {
        
        guard let articleVC = centerVC as? ArticleViewController else {
            return
        }
        let article = articleVC.article
        
        guard var stateContentData = getMapForContentValuesForAnalytics(false) else {
            return
        }
        
        var stateName: String = ""
        
        stateContentData[AnalyticsConstant.TagPageType] = Constants.Page.Type.cp_ca as AnyObject?
        stateContentData[Constants.Events.ContentDownload] = "0" as AnyObject?
        stateContentData[Constants.Events.ContentShare] = "0" as AnyObject?
        stateContentData[Constants.Events.ContentTurnAway] = "0" as AnyObject?
        stateContentData[Constants.Events.ContentView] = "1" as AnyObject?
        stateContentData[Constants.Events.ContentLogin] = "0" as AnyObject?
        stateContentData[Constants.Events.PDFView] = "0" as AnyObject?
        stateContentData[Constants.Events.ContentSaveToList] = "0" as AnyObject?
        stateContentData[Constants.Events.ContentUpsell] = "0" as AnyObject?
        
        if viewType == Constants.ScreenType.Abstract {
            
            stateName = Constants.Page.Name.Abstract
            stateContentData[Constants.Events.AbstractView] = "1" as AnyObject?
            stateContentData[Constants.Events.FullView] = "0" as AnyObject?
            
        } else if viewType == Constants.ScreenType.FullText {
            
            stateName = Constants.Page.Name.Fulltext
            stateContentData[Constants.Events.AbstractView] = "0" as AnyObject?
            stateContentData[Constants.Events.FullView] = "1" as AnyObject?
            
        } else if viewType == Constants.ScreenType.Audios {
            
            stateName = Constants.Page.Name.FulltextAudio
            
        } else if viewType == Constants.ScreenType.Videos {
            
            stateName = Constants.Page.Name.FulltextVideo
            
        } else if viewType == Constants.ScreenType.Figures {
            
            stateName = Constants.Page.Name.FulltextFigures
            
        } else if viewType == Constants.ScreenType.Tables {
            
            stateName = Constants.Page.Name.FulltextTable
            
        } else if viewType == Constants.ScreenType.Citation {
            
            stateName = Constants.Page.Name.FulltextCitation
            stateContentData.removeValue(forKey: Constants.Events.ContentView)
            stateContentData[AnalyticsConstant.TagPageType] = Constants.Page.Type.cp_ci as AnyObject?
            
        } else if viewType == Constants.ScreenType.Outline {
            
            stateName = Constants.Page.Name.FulltextOutline
            
        } else if viewType == Constants.ScreenType.Others {
            
            stateName = "jb:fulltext:other"
        }
        
        stateContentData[Constants.Events.ProductInfo] = getProductInfoForAnalytics(article) as AnyObject?
        AnalyticsHelper.MainInstance.setArticleDetailsContextInfo(stateContentData)
        AnalyticsHelper.MainInstance.trackState(stateName, stateContentData: stateContentData)
    }
    
    func getMapForContentValuesForAnalytics(_ isPDF: Bool) -> [String: AnyObject]? {
        guard let articleVC = centerVC as? ArticleViewController else {
            return nil
        }
        let article = articleVC.article
        
        let contentType = articleVC.article.downloadInfo.fullTextHTMLDownloadStatus == .downloaded ? Constants.Content.ValueTypeFull : Constants.Content.ValueTypeAbstract
        
        var issueNumber: String?
        if let _issueNumber = article.issue?.issueNumber {
            issueNumber = _issueNumber
        }
        
        var contentUsageMap = AnalyticsHelper.MainInstance.createMapForContentUsage(
            article.journal.accessType,
            contentID: article.articleInfoId,
            bibliographic: AnalyticsHelper.MainInstance.createBibliographicInfo(article.issue?.volume, issue: issueNumber),
            contentFormat: isPDF ? Constants.Content.ValueFormatPDF : Constants.Content.ValueFormatHTML,
            contentInnovationName: nil,
            contentStatus: nil,
            contentTitle: article.articleTitle,
            contentType: contentType,
            contentViewState: articleVC.fullText ? Constants.ScreenType.FullText : Constants.ScreenType.Abstract
        )
        
        if isPDF == false {
            contentUsageMap[Constants.Events.HTMLView] = "1" as AnyObject?
        }
        
        return contentUsageMap
    }
    
    fileprivate func getProductInfoForAnalytics(_ article: Article, pdf: Bool = false) -> String {
        
        guard let articleVC = centerVC as? ArticleViewController else {
            return ""
        }
        
        var issueNumber: String?
        if let _issueNumber = article.issue?.issueNumber {
            issueNumber = _issueNumber
        }
        
        let contentType = articleVC.article.downloadInfo.fullTextHTMLDownloadStatus == .downloaded ? Constants.Content.ValueTypeFull : Constants.Content.ValueTypeAbstract
        return AnalyticsHelper.MainInstance.createProductInforForEventAction(
            article.articleInfoId,
            fileFormat: pdf == false ? Constants.Content.ValueFormatHTML : Constants.Content.ValueFormatPDF,
            contentType: contentType,
            bibliographicInfo: AnalyticsHelper.MainInstance.createBibliographicInfo(article.issue?.volume, issue: issueNumber),
            articleStatus: nil,
            articleTitle: article.articleTitle!.lowercased(),
            accessType: article.journal.accessType
        )
    }
    
    func sendAnalyticsFor(article: Article, withViewController articleVC: ArticleViewController, withScreenType screenType: String) {
        guard articleVC == centerVC else {
            return
        }
        analyticsTagSubScreen(screenType)
    }
    
    func articleTagAction(article: Article, withAction action: AnalyticsHelper.ContentAction) {
        AnalyticsHelper.MainInstance.analyticsTagAction(action, additionalInfo: getProductInfoForAnalytics(article))
    }
    
    //  MARK: ArticleInfoSlideOutProtocol
    
    func openDrawer(_ open: Bool) {
        if open == true {
            UIView.animate(withDuration: 0.2, animations: {
                self.pagerLeftPadding?.constant = 280
                self.pagerRightPadding?.constant = 280
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.pagerLeftPadding?.constant = 0
                self.pagerRightPadding?.constant = 0
                self.view.layoutIfNeeded()
            })
        }
        drawerIsOpen = open
        drawerShouldBeOpen = open
    }
    
    func noteTabWasClicked() {
        //toggleTabView()
    }
    
    func outlineTabWasClicked() {
        //toggleTabView()
    }
    
    func openNote(_ note: Note) {
        guard let articleVC = centerVC as? ArticleViewController else {
            return
        }
        articleVC.webView.stringByEvaluatingJavaScript(from: "window.location.hash = ''")
        articleVC.webView.stringByEvaluatingJavaScript(from: "window.location.hash = '\(note.highlightId)';")
    }
    
    func openReference(_ reference: Reference) {
        guard let articleVC = centerVC as? ArticleViewController else {
            return
        }
        articleVC.webView.stringByEvaluatingJavaScript(from: "window.location.hash = ''")
        articleVC.webView.stringByEvaluatingJavaScript(from: "window.location.hash = '\(reference.sectionId!)';")
    }
    
    func presentMailVC(_ mailVC: MFMailComposeViewController) {
        
        self.present(mailVC, animated: true, completion: nil)
    }
}

// MARK: - Update -

extension ArticlePagerController {
    
    // MARK: CENTER ARTICLE
    
    func updateForCenterArticle() {
        
        supplementController.reset()
        contentInnovation.clearContentInnovation()
        articleInfoSlideOut.hideSlideout(true)

        switch currentItem.type {
        case .advertisement:
            isAdvertisement = true
            
            if self.screenType == .tablet {
                self.articleInfoSlideOut.view.isHidden = true
            }
            
            performOnMainThread({
                self.advertisementVC.view.isHidden = true
            })
        default:
            isAdvertisement = false
            
            advertisementVC.loadAd()
            
            if self.screenType == .tablet {
                self.articleInfoSlideOut.view.isHidden = false
            }
            
            if drawerShouldBeOpen == true {
                openDrawer(true)
            }
            if let article = currentItem.article {
                
                performOnMainThread({
                    switch article.downloadInfo.fullTextDownloadStatus {
                    case .downloaded:
                        self.advertisementVC.view.isHidden = true
                    default:
                        self.advertisementVC.view.isHidden = false
                    }
                })
                
                self.title = article.journal.journalTitle
                
                currentIssue = article.issue
                
                articleInfoSlideOut.update(article)
                updateSupplement(article: article)
                updateCI(article: article)
                utilityToolbar.update(article)
                if let index = currentItem.orderIndex {
                    updateNavigationToolbar(article: article, articleIndex: index)
                }
            } else {
                performOnMainThread {
                    self.advertisementVC.view.isHidden = true
                }
            }
            
            if let articleVC = centerVC as? ArticleViewController {
                performOnMainThread({
                    articleVC.updateWebViewContentSizeToFitFrame()
                })
            }
        }
        
        updateFullScreen()
    }
    
    // MARK: FULLSCREEN
    
    func updateFullScreen() {
        
        let fullscreen = isAdvertisement || isUserFullScreen ? true : false
        
        if fullscreen {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            UIView.animate(withDuration: 0.0, animations: {
                self.utilityToolbarBottomConstraint?.constant = 88
                self.view.layoutIfNeeded()
            })
            
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            UIView.animate(withDuration: 0.0, animations: {
                self.utilityToolbarBottomConstraint?.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func goFullscreen(_ fullscreen: Bool) {
        performOnMainThread {
            if fullscreen {
                self.navigationController?.setNavigationBarHidden(true, animated: false)
                UIView.animate(withDuration: 0.0, animations: {
                    self.utilityToolbarBottomConstraint?.constant = 88
                    self.view.layoutIfNeeded()
                })
                
            } else {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                UIView.animate(withDuration: 0.0, animations: {
                    self.utilityToolbarBottomConstraint?.constant = 0
                    self.view.layoutIfNeeded()
                })
                
            }
        }
    }
    
    // MARK: CONTENT INNOVATION
    
    func updateCI(article: Article) {
        
        guard NETWORKING_ENABLED && CONTENT_INNOVATION_CALL_ENABLED else { return }
        
        contentInnovationButton.reset()
        
        if NETWORK_AVAILABLE {
            if article.downloadInfo.fullTextDownloadStatus == .downloaded {
                contentInnovation.getContentInnovation(article: article, journal: article.journal, fullText: true)
            } else {
                contentInnovation.getContentInnovation(article: article, journal: article.journal, fullText: false)
            }
        }
    }
    
    // MARK: SUPPLEMENT
    
    func updateSupplement(article: Article) {
        supplementController.update(article)
    }
    
    // MARK: NAVIGATION BAR
    
    func updateNavigationToolbar(article: Article, articleIndex: Int) {
        var text: String
        if let issue = article.issue {
            text = issue.releaseDateAbbrDisplay! + " Issue"
        } else {
            text = article.journal.aipTitle!
        }
        text += ": Article \(articleIndex) of \(articleCount)"
        navigationToolbar.titleBarButtonItem.title = text
        
        
        if leftItem == nil {
            navigationToolbar.previousBarButtonItem.isEnabled = false
        } else {
            navigationToolbar.previousBarButtonItem.isEnabled = true
        }
        
        if rightItem == nil {
            navigationToolbar.nextBarButtonItem.isEnabled = false
        } else {
            navigationToolbar.nextBarButtonItem.isEnabled = true
        }
    }
}



extension ArticlePagerController {
    
    
    override func didLoginForMedia(_ media: Media, forDownload: Bool) {

        guard let article = currentItem.article else {
            return
        }
        present(Alerts.Supplement.DownloadAll(article: article), animated: true, completion: nil)
    }
}
