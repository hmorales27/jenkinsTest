//
//  SOController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/14/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography
//import FileBrowser

public class SLViewController: JBSMViewController, SLTableViewItemTypeProtocol, UIGestureRecognizerDelegate {
    
    weak var barButtonItem: UIBarButtonItem?
    
    var enabled = true
    
    //var journal: Journal!
    
    fileprivate let slTableView = UITableView(frame: CGRect.zero, style: .plain)
    fileprivate let slAlphaView = UIView()
    
    fileprivate var slTableViewData: SLTableViewDelegate?
    
    var selectedType: SLTableViewItemType?
    
    // Slider
    
    var slTableViewLeftConstraint: NSLayoutConstraint?
    
    var slTableViewLeftConstant: CGFloat {
        get {
            guard let constraint = slTableViewLeftConstraint else {
                return 0
            }
            return constraint.constant
        }
        set(constant) {
            
            var _constant = constant
            if _constant > 0 {
                _constant = 0
            }
            if _constant > sliderMaxEndingPosition {
                _constant = sliderMaxEndingPosition
            }
            
            slTableViewLeftConstraint?.constant = _constant
        }
    }
    
    let sliderMaxStartingPosition = CGFloat(80)
    let sliderMaxEndingPosition = CGFloat(300)
    
    var sliderOpened = false
    var sliderXPosition = CGFloat(0)
    let sliderWidth = CGFloat(300)
    
    let slMaxAlpha: CGFloat = 0.6
    let slMinAlpha: CGFloat = 0.0
    
    
    var _sliderShouldSlide = false
    var sliderShouldSlide: Bool {
        get {
            return _sliderShouldSlide
        }
        set(slide) {
            _sliderShouldSlide = slide
            if slide {
                slTableView.isScrollEnabled = false
            } else {
                slTableView.isScrollEnabled = true
            }
        }
    }
    
    // MARK: - Initializer -
    
    public init(journal: Journal) {
        super.init(nibName: nil, bundle: nil)
        self.currentJournal = journal
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        enabled = false
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Lifecycle -
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupSL()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSL()
    }
    
    // MARK: - Setup
    
    func setupSL() {
        if enabled {
            setupSLSubviews()
            setupSLAutoLayout()
            setupSLView()
            setupSLAlphaView()
            setupSLTableView()
            
            if self as? ArticlesViewController == nil {
                setupNotifications()
            }
        }
    }
    
    func setupSLSubviews() {
        view.addSubview(slAlphaView)
        view.addSubview(slTableView)
    }
    
    func setupSLAutoLayout() {
        constrain(slTableView, slAlphaView) { (tableView, alphaView) -> () in
            guard let superview = tableView.superview else {
                return
            }
            
            alphaView.top    == superview.top
            alphaView.right  == superview.right
            alphaView.bottom == superview.bottom
            alphaView.left   == superview.left
            
            tableView.top    == superview.top
            tableView.bottom == superview.bottom
            tableView.width  == 300
            slTableViewLeftConstraint = (tableView.left == superview.left - 300)
        }
    }
    
    func setupSLView() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(userIsPanning(_:)))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func setupSLTableView() {
        slTableView.backgroundColor = UIColor.colorWithHexString("1D1D1D")
        slTableView.isHidden = true
        slTableView.clipsToBounds = false
        slTableView.separatorColor = UIColor.clear
        slTableView.register(SLTableViewCell.self, forCellReuseIdentifier: SLTableViewCell.Identifier)
        slTableView.register(SLSearchTableViewCell.self, forCellReuseIdentifier: SLSearchTableViewCell.Identifier)
    }
    
    func setupSLAlphaView() {
        slAlphaView.backgroundColor = UIColor.black
        slAlphaView.alpha = slMinAlpha
        slAlphaView.isHidden = true
        addTapToAlphaView()
    }
    
    func addTapToAlphaView() {
        guard slAlphaView.gestureRecognizers?.first as? UITapGestureRecognizer == nil else {
            return
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(slAlphaViewWasClicked(_:)))
        slAlphaView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func slAlphaViewWasClicked(_ sender: AnyObject) {
        closeSliderMenu()
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(notification_authentication_login(_:)), name: NSNotification.Name(rawValue: Notification.Authentication.Login), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_issue_downloadstarted(_:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.DownloadStarted), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_isue_downloadcomplete(_:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.DownloadComplete), object: nil)
    }
    
    func notification_authentication_login(_ notification: Foundation.Notification) {
        updateSL()
    }
    
    func notification_download_issue_downloadstarted(_ notification: Foundation.Notification) {
        updateSL()
    }
    
    func notification_download_isue_downloadcomplete(_ notification: Foundation.Notification) {
        updateSL()
    }
    
    // MARK: - Update
    
    func updateSL() {
        if enabled {
            updateSLTableViewForScreen(screenType)
        }
    }
    
    func updateSLTableViewForScreen(_ type: ScreenType) {
        guard let journal = currentJournal else {
            return
        }
        slTableViewData = SLTableViewDelegate(journal: journal)
        if let _selectedType = self.selectedType {
            slTableViewData?.selectedType = _selectedType
        }
        slTableView.delegate = slTableViewData
        slTableView.dataSource = slTableViewData
        slTableViewData?.delegate = self
        slTableViewData?.update(screenType: type)
        slTableViewData?.tableView = slTableView
        slTableView.reloadData()
    }
    
    func moveSliderToFront() {
        view.bringSubview(toFront: slAlphaView)
        view.bringSubview(toFront: slTableView)
    }
    
    // MARK: - Slider -
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: view)
            if abs(velocity.y) > abs(velocity.x) {
                return false
            }
        }
        return true
    }
    
    var offset: CGFloat = 0
    
    func userIsPanning(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        switch(gesture.state) {
        case .began:
            beginUserPanning(location)
        case .changed:
            changeUserPanning(location)
        case .ended:
            endUserPanning(location)
        default:
            return
        }
    }
    
    func beginUserPanning(_ location: CGPoint) {
        
        slTableView.isHidden = false
        sliderShouldSlide = false
        
        if sliderOpened {
            if location.x < sliderMaxEndingPosition {
                offset = sliderMaxEndingPosition - location.x
            }
            sliderShouldSlide = true
            return
        }
        
        if !sliderOpened {
            if location.x < sliderMaxStartingPosition {
                sliderShouldSlide = true
                slAlphaView.isHidden = false
            }
            return
        }
    }
    
    func changeUserPanning(_ location: CGPoint) {
        guard sliderShouldSlide else { return }
        
        if sliderOpened {
            let constraint = location.x > sliderMaxEndingPosition ? sliderMaxEndingPosition : location.x
            setFrontViewConstraints(constraint)
        } else {
            let constraint = location.x > sliderMaxEndingPosition ? sliderMaxEndingPosition : location.x
            setFrontViewConstraints(constraint)
        }
    }
    
    func endUserPanning(_ location: CGPoint) {
        guard sliderShouldSlide else { return }
        
        if sliderOpened {
            location.x < sliderMaxEndingPosition * (2/3) ? closeSliderMenu() : openSlideMenu()
        } else {
            location.x > sliderMaxStartingPosition * (1/3) ? openSlideMenu() : closeSliderMenu()
        }
        offset = 0
    }
    
    
 
    func setFrontViewConstraints(_ constraint:CGFloat) {
        
        let xPosition = -sliderWidth + constraint + offset
        slTableViewLeftConstant = xPosition
        
        let showingWidth = slTableViewLeftConstant + sliderMaxEndingPosition
        let showingPercent = showingWidth / sliderMaxEndingPosition
        let alpha = slMaxAlpha * showingPercent
        
        UIView.animate(withDuration: 0.01, animations: { 
            self.slAlphaView.alpha = alpha
        }) 
        
    }
    
    func toggleSliderMenu(_ sender: AnyObject) {
        if let _sender = sender as? UIBarButtonItem {
            _sender.accessibilityLabel = sliderOpened ? "Open slide menu" : "Close slide menu"
        }
        sliderOpened ? closeSliderMenu() : openSlideMenu()
    }
    
    fileprivate var slDuration: TimeInterval = 0.3
    
    func closeSliderMenu() {
        slideMenuDidClose()
        
        UIView.animate(withDuration: slDuration, animations: {
            
            self.slTableViewLeftConstant = -self.sliderMaxEndingPosition
            self.slAlphaView.alpha = self.slMinAlpha
            
            self.view.layoutIfNeeded()
            
            }, completion: { (success) in
            
                self.slTableView.isHidden = true
                self.slAlphaView.isHidden = true
                
        }) 
        
        sliderOpened = false
        sliderShouldSlide = false
        sliderXPosition = 0
    }
    
    func openSlideMenu() {
        slideMenuDidOpen()
        
        UIView.animate(withDuration: 0.01, animations: {
            
            self.slTableView.isHidden = false
            self.slAlphaView.isHidden = false
            self.view.layoutIfNeeded()
            
            }, completion: { (success) in
                
                UIView.animate(withDuration: self.slDuration, animations: {
                    self.slAlphaView.alpha = self.slMaxAlpha
                    self.slTableViewLeftConstant = 0
                    self.view.layoutIfNeeded()
                    
                })
        }) 
        sliderOpened = true
        sliderShouldSlide = false
        sliderXPosition = sliderMaxEndingPosition
    }
    
    // Override Methods
    
    func slideMenuDidOpen() {
        
    }
    
    func slideMenuDidClose() {
        
    }
    
    // MARK: - SLTableView -
    
    func slTableViewNavigateWithType(_ type: SLTableViewItemType) {
        
        guard let journal = currentJournal else {
            return
        }
        
        switch type {
        case .close:
            
            _ = self.overlord?.popViewController(animated: true)
            
        case .highlight:
            
            let highlightVC = HighlightViewController(journal: journal)
            _ = self.overlord?.removeSelfAndPushViewController(highlightVC, animated: false)
            
        case .articlesInPress:
            let aipVC = AIPVC(journal: journal)
            _ = self.overlord?.removeSelfAndPushViewController(aipVC, animated: false)
            
        case .latestIssue:
            let articleVC = StoryboardHelper.Articles()
            if let firstIssue = journal.firstIssue {
                articleVC.issue = firstIssue
            }
            articleVC.currentJournal = journal
            self.overlord?.removeSelfAndPushViewController(articleVC, animated: false)
            
        case .topArticles:
            let topArticlesVC = TopArticlesMasterVC.init(journal: journal)
            self.overlord?.removeSelfAndPushViewController(topArticlesVC, animated: false)
            
        case .allIssues:
            
            let issuesVC = IssuesViewController(journal: journal)
            self.overlord?.removeSelfAndPushViewController(issuesVC, animated: false)
            
        case .readingList:
            
            let readingVC = BookmarksViewController(journal: journal)
            self.overlord?.removeSelfAndPushViewController(readingVC, animated: false)
            
        case .notes:
            
            let notesVC = NotesViewController(journal: journal)
            self.overlord?.removeSelfAndPushViewController(notesVC, animated: false)
            
        case .aimAndScope:
            
            guard let html = journal.aimScopeHTML else {
                return
            }
            
            let infoVC = JournalInfoViewController(html: html, title: "Aim & Scope", journal: journal)
            infoVC.analyticsScreenName = Constants.Page.Name.AimsScope
            infoVC.analyticsScreenType = Constants.Page.Type.np_gp
            infoVC.currentJournal = journal
            infoVC.selectedType = SLTableViewItemType.aimAndScope
            self.overlord?.removeSelfAndPushViewController(infoVC, animated: false)
                
        case .editorialBoard:
            
            guard let html = journal.editorialHTML else {
                return
            }
            
            let editorialVC = JournalInfoViewController(html: html, title: "Editorial Board", journal: journal)
            editorialVC.analyticsScreenName = Constants.Page.Name.EditorialBoard
            editorialVC.analyticsScreenType = Constants.Page.Type.np_gp
            editorialVC.currentJournal = journal
            editorialVC.selectedType = SLTableViewItemType.editorialBoard
            self.overlord?.removeSelfAndPushViewController(editorialVC, animated: false)

        case .support:
            guard let publisher = DatabaseManager.SharedInstance.getAppPublisher() else {
                return
            }

            let webViewController = WebViewController(journal: journal)
            webViewController.analyticsScreenName = Constants.Page.Name.InfoTC
            webViewController.analyticsScreenType = Constants.Page.Type.np_gp
            webViewController.string = Strings.SUPPORT_HTML
            webViewController.contentType = WebViewControllerContentTypes.string
            webViewController.pageTitle = "Support"
            webViewController.selectedType = SLTableViewItemType.support
            webViewController.showHeaderView = true
            let bundlePath = Bundle.main.bundlePath
            webViewController.baseURL = URL(fileURLWithPath: bundlePath)
            self.overlord?.removeSelfAndPushViewController(webViewController, animated: false)

        case .feedback:
            
            let feedbackVC = FeedbackViewController(journal: journal)
            feedbackVC.analyticsScreenName = Constants.Page.Name.InfoFeedback
            feedbackVC.analyticsScreenType = Constants.Page.Type.np_gp
            feedbackVC.selectedType = SLTableViewItemType.feedback
            feedbackVC.showHeaderView = true
            self.overlord?.removeSelfAndPushViewController(feedbackVC, animated: false)
            
        case .termsAndCoditions:
            if let publisher = DatabaseManager.SharedInstance.getAppPublisher() {
                if let toc = publisher.terms {
                    let webViewController = WebViewController(journal: journal)
                    webViewController.analyticsScreenName = Constants.Page.Name.InfoTC
                    webViewController.analyticsScreenType = Constants.Page.Type.np_gp
                    webViewController.string = toc
                    webViewController.contentType = WebViewControllerContentTypes.string
                    webViewController.pageTitle = "Terms & Conditions"
                    webViewController.selectedType = SLTableViewItemType.termsAndCoditions
                    webViewController.showHeaderView = true
                    navigationController?.pushViewController(webViewController, animated: true)
                }
            }
        case .faqs:
            if let publisher = DatabaseManager.SharedInstance.getAppPublisher() {
                if let toc = publisher.faq {
                    let webViewController = WebViewController(journal: journal)
                    webViewController.analyticsScreenName = Constants.Page.Name.InfoFAQ
                    webViewController.analyticsScreenType = Constants.Page.Type.np_gp
                    webViewController.string = toc
                    webViewController.contentType = WebViewControllerContentTypes.string
                    webViewController.pageTitle = "FAQs"
                    webViewController.selectedType = SLTableViewItemType.faqs
                    webViewController.showHeaderView = true
                    navigationController?.pushViewController(webViewController, animated: true)
                }
            }
        case .howToUseTheApp:
            let howToUseVC = HowToUseTheAppController()
            let navigationVC = UINavigationController(rootViewController: howToUseVC)
            navigationVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
            present(navigationVC, animated: true, completion: nil)
        case .usage:
            let usageVC = UsageViewController(journal: journal)
            usageVC.selectedType = SLTableViewItemType.usage
            navigationController?.popToRootViewControllerAndLoadViewController(usageVC)
        case .pushNotifications:
            let pushVC = PushNotesVC()
            pushVC.currentJournal = currentJournal
            navigationController!.navigationBar.topItem!.title = ""
            navigationController?.pushViewController(pushVC, animated: true)
        case .downloads:
            guard DMManager.sharedInstance.sectionsWithFullTextOrSupplement.count > 0 else {
                return
            }
            let sectionVC = DMSectionsViewController()
            sectionVC.currentJournal = self.currentJournal
            navigationController?.pushViewController(sectionVC, animated: true)
        case .login:
            
            if NETWORK_AVAILABLE == false {
                
                let alertVC = Alerts.NoNetwork()
                performOnMainThread({
                    self.present(alertVC, animated: true, completion: nil)
                })
            }
            else if NETWORK_AVAILABLE == true {
                let alert = Alerts.pleaseWait()
                present(alert, animated: true, completion: {
                    
                    self.dismiss(animated: true, completion: {
                        
                        let loginVC = LoginViewController(journal: journal)
                        loginVC.selectedType = SLTableViewItemType.login
                        loginVC.isDismissable = true
                        let navigationVC = UINavigationController(rootViewController: loginVC)
                        self.present(navigationVC, animated: true, completion: nil)
                    })
                })
            }
        case .logout:
            let journals = DatabaseManager.SharedInstance.getAllJournals()
            
            for _journal in journals {
            
                if let authentication = _journal.authentication {
                    DatabaseManager.SharedInstance.performChangesAndSave({
                        DatabaseManager.SharedInstance.moc?.delete(authentication)
                    })
                    performOnMainThread({
                        DatabaseManager.SharedInstance.moc?.refresh(_journal, mergeChanges: true)
                        self.updateSL()
                    })
                    let alertVC = UIAlertController(title: "Message", message: "You have successfully logged out.", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alertVC, animated: true, completion: { })
                }
            }
        case .announcements:
            if DatabaseManager.SharedInstance.getAllAnnouncements().count > 0 {
                let announcementsVC = AnnouncementsViewController(journal: journal)
                announcementsVC.shouldShowMenuButton = true
                announcementsVC.selectedType = SLTableViewItemType.announcements
                navigationController?.popToRootViewControllerAndLoadViewController(announcementsVC)
            }
        case .fileBrowser:
            //let fileBrowser = FileBrowser(initialPath: FileSystem.Caches.URL)
            //self.presentViewController(fileBrowser, animated: true, completion: nil)
            break
        case .search:
            break
        }
    }
    
    func slTableViewNavigateWithType(_ type: SLTableViewItemType, text: String) {
        if type == .search {
            let information = SearchInformation()
            information.currentIssue = currentIssue
            information.currentJournal = currentJournal
            information.preText = text
            let searchVC = SearchViewController(information: information)
            searchVC.dismissable = true
            let navigationController = UINavigationController(rootViewController: searchVC)
            present(navigationController, animated: true, completion: nil)
        } else {
            slTableViewNavigateWithType(type)
        }
    }
    
    func slTableViewReloadSection(_ section: Int) {
        self.slTableView.reloadData()
    }
}
