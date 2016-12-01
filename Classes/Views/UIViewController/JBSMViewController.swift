//
//  JBSMViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/14/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

enum ScreenTransitionState {
    case willTransition
    case didTransition
}

enum ScreenType {
    case mobile
    case tablet
    
    static func TypeForSize(_ size: CGSize) -> ScreenType {
        if size.width < 768 {
            return .mobile
        } else {
            return .tablet
        }
    }
}

enum OrientationType {
    case portrait
    case landscape
    case unknown
    
    static func CurrentOrientation() -> OrientationType {
        let orientation = JBSMDevice().currentOrientation()
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            return .landscape
        case .portrait, .portraitUpsideDown:
            return .portrait
        default:
            return .unknown
        }
    }
}

struct LoginViewControllerInfo {
    
    enum `Type` {
        case aip
        case aipList
        case issue
        case openAccess
    }
    
    let journal: Journal
    var issue: Issue?
    var article: Article?
    var media: Media?
    var articles: [Article] = []
    
    var pushVC = false
    var forMediaDownload: Bool?
    var type: Type?
    
    init(journal: Journal, issue: Issue?, article: Article?) {
        self.journal = journal
        self.issue = issue
        self.article = article
    }
    
    init(article: Article) {
        self.journal = article.journal
        self.issue = article.issue
        self.article = article
    }
    
    init?(articles: [Article]) {
        guard articles.count > 0 else {
            return nil
        }
        self.journal = articles[0].journal
        self.articles = articles
        self.type = .aipList
    }
}

public class JBSMViewController: UIViewController, AnnouncementControllerDelegate {
    
    public var currentJournal: Journal?
    var currentIssue: Issue?
    
    var analyticsScreenName: String?
    var analyticsScreenType: String?
    
    var _registerForKeyboardChange: Bool = false
    
    weak var currentPopover: UIPopoverPresentationController?
    
    var currentlyDisplayedView = true

    var screenType: ScreenType {
        get {
            return ScreenType.TypeForSize(view.frame.size)
        }
    }
    
    var screenTitle: String {
        get {
            return ""
        }
    }
    
    var screenTitleJournal: String {
        get {
            if let journal = currentJournal {
                if screenType == .mobile {
                    if let title = journal.journalTitleIPhone {
                        return title
                    }
                } else {
                    if let title = journal.journalTitle {
                        return title
                    }
                }
            }
            return ""
        }
    }
    
    var screenTitleApp: String {
        get {
            if let publisher = DatabaseManager.SharedInstance.getAppPublisher() {
                if screenType == .mobile {
                    if let title = publisher.appTitleIPhone {
                        return title
                    }
                } else {
                    if let title = publisher.appTitle {
                        return title
                    }
                }
            }
            return ""
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.lightGray
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _setupNotifications()
        setupNavigationBar()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if analyticsScreenName != .none {
            analyticsTagScreen()
        }
    }
    
    func analyticsTagScreen() {
        var contentData: [AnyHashable: Any] = [:]
        contentData[AnalyticsConstant.TagPageType] = analyticsScreenType
        AnalyticsHelper.MainInstance.trackState(analyticsScreenName!, stateContentData: contentData)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _destroypNotifications()
    }
    
    fileprivate func _setupNotifications() {
        let notificationCenter = NotificationCenter.default
        if _registerForKeyboardChange == true {
            notificationCenter.addObserver(self, selector: #selector(keyboardDisplayDidChange(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            notificationCenter.addObserver(self, selector: #selector(keyboardDisplayDidChange(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }

        notificationCenter.addObserver(self, selector: #selector(_notification_download_issue_started(_:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.DownloadStarted), object: nil)
        notificationCenter.addObserver(self, selector: #selector(_notification_download_issue_completed(_:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.DownloadComplete), object: nil)
        notificationCenter.addObserver(self, selector: #selector(_notification_download_aip_started(_:)), name: NSNotification.Name(rawValue: Notification.Download.AIP.Started), object: nil)
        notificationCenter.addObserver(self, selector: #selector(_notification_download_aip_completed(_:)), name: NSNotification.Name(rawValue: Notification.Download.AIP.Completed), object: nil)
        notificationCenter.addObserver(self, selector: #selector(deviceOrientationDidChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(notification_announcement_updated), name: NSNotification.Name(rawValue: Notification.Announcement.Updated), object: nil)
    }
    
    func notification_announcement_updated() {

    }
    
    func deviceOrientationDidChange(_ sender: Foundation.Notification) {
        self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    func keyboardDisplayDidChange(_ notification: Foundation.Notification) {
        guard let userInfo = (notification as NSNotification).userInfo else {
            return
        }
        guard let endFrame = (userInfo["UIKeyboardFrameEndUserInfoKey"] as? NSValue)?.cgRectValue else {
            return
        }
        if notification.name == NSNotification.Name.UIKeyboardWillShow {
            updateKeyboardForRect(endFrame)
        } else {
            updateKeyboardForRect(CGRect.zero)
        }
    }
    
    func updateKeyboardForRect(_ rect: CGRect) {
        
    }
    
    fileprivate func _update() {
        
    }
    
    fileprivate func _destroy() {
        _destroyNotifications()
    }
    
    fileprivate func _destroyNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Buttons -
    
    lazy var settingsBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: JBSMImages.Settings(), style: .plain, target: self, action: #selector(settingsButtonClicked(_:)))
        barButtonItem.accessibilityLabel = "Settings Menu"
        barButtonItem.accessibilityTraits = UIAccessibilityTraitNone
        return barButtonItem
    }()
    
    lazy var backBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: JBSMImages.Back(), style: .plain, target: self, action: #selector(backButtonClicked(_:)))
    }()
    
    lazy var menuBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "Menu"), style: .plain, target: self, action: #selector(menuButtonClicked(_:)))
        barButtonItem.accessibilityLabel = "Open Slide Menu"
        barButtonItem.accessibilityTraits = UIAccessibilityTraitNone
        return barButtonItem
    }()
    
    lazy var closeBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "Close"), style: .plain, target: self, action: #selector(closeButtonClicked(_:)))
    }()
    
    lazy var searchBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "Search"), style: .plain, target: self, action: #selector(searchButtonClicked(_:)))
        barButtonItem.accessibilityLabel = "Search Menu"
        barButtonItem.accessibilityTraits = UIAccessibilityTraitNone
        return barButtonItem
    }()
    
    lazy var infoBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "Info"), style: .plain, target: self, action: #selector(infoButtonClicked(_:)))
        barButtonItem.accessibilityLabel = "Information Menu"
        barButtonItem.accessibilityTraits = UIAccessibilityTraitNone
        return barButtonItem
    }()
    
    var _alertBarButtonItem: UIBarButtonItem?
    
    var weakAlertBarButtonItem: BBBadgeBarButtonItem?
    
    func alertBarButtonItem() -> BBBadgeBarButtonItem {
        let customButton = UIButton(type: .custom)
        customButton.setImage(UIImage(named: "Alert"), for: UIControlState())
        customButton.frame = CGRect(x: 0, y: 0, width: 46, height: 30)
        customButton.addTarget(self, action: #selector(alertButtonClicked(_:)), for: .touchUpInside)
        let barButton = BBBadgeBarButtonItem(customUIButton: customButton)
        
        var totalCount = 0
        var unreadCount = 0
        
        //  Check announcement.opened? May need to add logic to check if they've been deleted.
        let announcements = DatabaseManager.SharedInstance.getAllAnnouncements()
        for announcement in announcements {
            if announcement.opened == false {
                unreadCount += 1
            }
            totalCount += 1
        }
        
        barButton?.badgeValue = "\(unreadCount)"
        let accessibility = unreadCount > 1 ? "You have \(unreadCount) unread announcements" :
                            unreadCount == 1 ? "You have \(unreadCount) unread announcement" : "You have no new announcements."
        
        customButton.accessibilityLabel = "Announcement menu. " + accessibility

        
        if totalCount == 0 {
            barButton?.isEnabled = false
        }
        
        return barButton!
        
    }
    
    var _downloadBarButtonItem: UIBarButtonItem?
    
    func getDownloadBarButtonItem() -> BBBadgeBarButtonItem {
        let customButton = UIButton(type: .custom)
        customButton.setImage(UIImage(named: "Download"), for: UIControlState())
        customButton.frame = CGRect(x: 0, y: 0, width: 46, height: 30)
        customButton.addTarget(self, action: #selector(downloadButtonClicked(_:)), for: .touchUpInside)
        let barButton = BBBadgeBarButtonItem(customUIButton: customButton)
        
        let sections = DMManager.sharedInstance.sectionsWithFullTextOrSupplement
        if sections.count > 0 {
            barButton?.badgeValue = "\(sections.count)"
        }

        return barButton!
    }
    
    func newRightBarButtonItems() -> [UIBarButtonItem] {
        var items: [UIBarButtonItem] = []
        _alertBarButtonItem = alertBarButtonItem()
        weakAlertBarButtonItem = _alertBarButtonItem as? BBBadgeBarButtonItem
        items += [settingsBarButtonItem, searchBarButtonItem, infoBarButtonItem, _alertBarButtonItem!]
        
        if DMManager.sharedInstance.sectionsWithFullTextOrSupplement.count > 0 {
            _downloadBarButtonItem = getDownloadBarButtonItem()
            items.append(_downloadBarButtonItem!)
        }
        return items
    }
    
    var rightBarButtonItems: [UIBarButtonItem] {
        var items: [UIBarButtonItem] = []
        _alertBarButtonItem = alertBarButtonItem()
        weakAlertBarButtonItem = _alertBarButtonItem as? BBBadgeBarButtonItem
        items += [settingsBarButtonItem, searchBarButtonItem, infoBarButtonItem, _alertBarButtonItem!]
        
        if DMManager.sharedInstance.sectionsWithFullTextOrSupplement.count > 0 {
            _downloadBarButtonItem = getDownloadBarButtonItem()
            items.append(_downloadBarButtonItem!)
        }
        return items
    }
    
    //  MARK: - AnnouncementsVC Delegate
    
    func announcementsDidUpdate() {
        self.navigationItem.rightBarButtonItems = rightBarButtonItems
    }
    
    
    // MARK: - Actions -
    
    func settingsButtonClicked(_ sender: UIBarButtonItem) {
        self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
        let settingsVC = SettingsVC()
        if let journal = currentJournal {
            settingsVC.currentJournal = journal
        }
        let navigationVC = UINavigationController(rootViewController: settingsVC)
        navigationVC.modalPresentationStyle = .popover
        navigationVC.popoverPresentationController?.barButtonItem = sender
        navigationVC.preferredContentSize = CGSize(width: 400, height: 500)
        navigationVC.popoverPresentationController?.backgroundColor = AppConfiguration.NavigationItemColor
        navigationVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppConfiguration.NavigationBarColor]
        navigationVC.navigationBar.barTintColor = AppConfiguration.NavigationItemColor
        navigationVC.navigationBar.tintColor = AppConfiguration.NavigationBarColor
        self.currentPopover = navigationVC.popoverPresentationController
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    func menuButtonClicked(_ sender: AnyObject) {
        self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
        if let slider = self as? SLViewController {
            slider.toggleSliderMenu(sender)
        }
    }
    
    func backButtonClicked(_ sender: UIBarButtonItem) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    func closeButtonClicked(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func downloadButtonClicked(_ sender: UIBarButtonItem) {
        guard navigationItem.rightBarButtonItems?.count == 5, let button = navigationItem.rightBarButtonItems?[4] else {
            return
        }
        self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
        let downloadVC = DMSectionsViewController()
        downloadVC.enabled = false
        downloadVC.currentJournal = self.currentJournal
        let navigationVC = UINavigationController(rootViewController: downloadVC)
        navigationVC.modalPresentationStyle = UIModalPresentationStyle.popover
        navigationVC.popoverPresentationController?.barButtonItem = button
        navigationVC.preferredContentSize = CGSize(width: 400, height: 500)
        navigationVC.popoverPresentationController?.backgroundColor = AppConfiguration.NavigationItemColor
        navigationVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppConfiguration.NavigationBarColor]
        navigationVC.navigationBar.barTintColor = AppConfiguration.NavigationItemColor
        navigationVC.navigationBar.tintColor = AppConfiguration.NavigationBarColor
        self.currentPopover = navigationVC.popoverPresentationController
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    func searchButtonClicked(_ sender: UIBarButtonItem) {
        self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
        let information = SearchInformation()
        information.currentIssue = currentIssue
        information.currentJournal = currentJournal
        
        let searchVC = SearchViewController(information: information)
        searchVC.title = "Search"
        let navigationVC = UINavigationController(rootViewController: searchVC)
        navigationVC.modalPresentationStyle = UIModalPresentationStyle.popover
        navigationVC.popoverPresentationController?.barButtonItem = sender
        
        let popoverwWidth = view.frame.size.width * 0.75
        navigationVC.preferredContentSize = CGSize(width: popoverwWidth, height: 90)
        
        navigationVC.popoverPresentationController?.backgroundColor = AppConfiguration.NavigationItemColor
        navigationVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppConfiguration.NavigationBarColor]
        navigationVC.navigationBar.barTintColor = AppConfiguration.NavigationItemColor
        navigationVC.navigationBar.tintColor = AppConfiguration.NavigationBarColor
        self.currentPopover = navigationVC.popoverPresentationController
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    func infoButtonClicked(_ sender: UIBarButtonItem) {
        performOnMainThread {
            self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
            let infoVC = InfoViewController()
            infoVC.viewController = self
            let navigationVC = UINavigationController(rootViewController: infoVC)
            navigationVC.modalPresentationStyle = .popover
            navigationVC.popoverPresentationController?.barButtonItem = sender
            navigationVC.popoverPresentationController?.backgroundColor = AppConfiguration.NavigationItemColor
            navigationVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppConfiguration.NavigationBarColor]
            navigationVC.navigationBar.barTintColor = AppConfiguration.NavigationItemColor
            navigationVC.navigationBar.tintColor = AppConfiguration.NavigationBarColor
            self.currentPopover = navigationVC.popoverPresentationController
            self.present(navigationVC, animated: true, completion: nil)
        }
    }
    
    func alertButtonClicked(_ sender: UIBarButtonItem) {
        self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
        let announcementsVC = AnnouncementsViewController()
        announcementsVC.enabled = false
        announcementsVC.delegate = self
        
        //  Use announcementsVC delegate.
        
        let navigationVC = UINavigationController(rootViewController: announcementsVC)
        navigationVC.modalPresentationStyle = .popover
        navigationVC.popoverPresentationController?.barButtonItem = _alertBarButtonItem
        navigationVC.preferredContentSize = CGSize(width: 400, height: 500)
        navigationVC.popoverPresentationController?.backgroundColor = AppConfiguration.NavigationItemColor
        navigationVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppConfiguration.NavigationBarColor]
        navigationVC.navigationBar.barTintColor = AppConfiguration.NavigationItemColor
        navigationVC.navigationBar.tintColor = AppConfiguration.NavigationBarColor
        self.currentPopover = navigationVC.popoverPresentationController
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    var navigationBarRequiresRightButtons = false
    var navigationBarRequiresBack = false
    
    func setupNavigationBar() {
        navigationItem.rightBarButtonItems = nil
    }
    
    func newUpdateNavigationBar() {
        
    }
    
    
    fileprivate func _destroypNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func _notification_download_issue_started(_ notification: Foundation.Notification) {
        performOnMainThread { 
            self.setupNavigationBar()
            self.newUpdateNavigationBar()
        }
    }
    
    @objc fileprivate func _notification_download_issue_completed(_ notification: Foundation.Notification) {
        performOnMainThread { 
            self.setupNavigationBar()
            self.newUpdateNavigationBar()
        }
    }
    
    func _notification_download_aip_started(_ notification: Foundation.Notification) {
        performOnMainThread {
            self.setupNavigationBar()
            self.newUpdateNavigationBar()
        }
    }
    
    func _notification_download_aip_completed(_ notification: Foundation.Notification) {
        performOnMainThread {
            self.setupNavigationBar()
            self.newUpdateNavigationBar()
        }
    }
    
    // MARK: - Rotation & Multitasking
    
    func updateViewsForScreenChange(_ type: ScreenType) {

    }
    
    func updateViewsForScreenChange(_ type: ScreenType, expectedWidth: CGFloat) {
        
    }
    
    func updateViewsForScreenChange(_ type: ScreenType, withExpectedWidth width: CGFloat, forTransitionState state: ScreenTransitionState) {
        
    }
    
    override public func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    override public func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard currentlyDisplayedView else { return }

        coordinator.animate(alongsideTransition: { (coordinatorContext) in
            self.updateViewsForScreenChange(ScreenType.TypeForSize(size), withExpectedWidth: size.width, forTransitionState: .willTransition)
        }) { (coordinatorContext) in
            self.updateViewsForScreenChange(ScreenType.TypeForSize(size), withExpectedWidth: size.width, forTransitionState: .didTransition)
        }
        updateViewsForScreenChange(ScreenType.TypeForSize(size))
        updateViewsForScreenChange(ScreenType.TypeForSize(size), expectedWidth: size.width)
    }
    
    func backButtons(_ text: String, dark: Bool = true) -> [UIBarButtonItem] {
        
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(backButtonClicked(_:)), for: .touchUpInside)
        
        let size = text.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]).width
        button.frame = CGRect(x: 0, y: 0, width: size + 24, height: 20)
        button.setTitle(text, for: UIControlState())
        if dark == true {
            button.setTitleColor(UIColor.black, for: UIControlState())
            button.setTitleColor(UIColor.veryLightGray(), for: .selected)
        } else {
            button.setTitleColor(UIColor.white, for: UIControlState())
            button.setTitleColor(UIColor.veryLightGray(), for: .selected)
        }
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        
        let image = UIImage(named: "Back")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        button.setImage(image, for: UIControlState())
        if dark == true {
            button.tintColor = UIColor.black
        } else {
            button.tintColor = UIColor.white
        }
        
        let navButton = UIBarButtonItem(customView: button)
        navButton.target = self
        navButton.action = #selector(self.backButtonClicked(_:))
        let negativeSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeSpace.width = -16
        return [negativeSpace, navButton]
    }

    
}

// MARK: - Analytics

extension JBSMViewController {

    // MARK: - ARTICLE
    
    func sendContentDownloadAnalytics(article: Article) {
        let productInfo: String = getProductInfoForAnalytics(article: article)
        let contentValues: [String: AnyObject] = getMapForContentValuesForAnalytics(article: article)
        AnalyticsHelper.MainInstance.contentDownloadAnalytics(productInfo, contentInfo: contentValues)
    }
    
    func getProductInfoForAnalytics(article: Article) -> String {
        return AnalyticsHelper.MainInstance.createProductInforForEventAction(
            article.articleInfoId,
            fileFormat: Constants.Content.ValueFormatHTML,
            contentType: "xocs:scope-full",
            bibliographicInfo: AnalyticsHelper.MainInstance.createBibliographicInfo(article.issue?.volume, issue: article.issue?.issueNumber),
            articleStatus: "",
            articleTitle: article.articleTitle!.lowercased(),
            accessType: article.journal.accessType
        )
    }
    
    func getMapForContentValuesForAnalytics(article: Article) -> [String: AnyObject] {
        return AnalyticsHelper.MainInstance.createMapForContentUsage(
            article.journal.accessType,
            contentID: article.articleInfoId,
            bibliographic: AnalyticsHelper.MainInstance.createBibliographicInfo(article.issue?.volume, issue: article.issue?.issueNumber),
            contentFormat: Constants.Content.ValueFormatHTML,
            contentInnovationName: nil,
            contentStatus: nil,
            contentTitle: article.articleTitle!.lowercased(),
            contentType: "xocs:scope-full",
            contentViewState: nil
        )
    }
    
    // MARK: - ISSUE
    
    func sendContentDownloadAnalytics(issue: Issue) {
        let productInfo: String = getProductInfoForAnalytics(issue: issue)
        let contentValues: [String: AnyObject] = getMapForContentValuesForAnalytics(issue: issue)
        AnalyticsHelper.MainInstance.contentDownloadAnalytics(productInfo, contentInfo: contentValues)
    }
    
    func getProductInfoForAnalytics(issue: Issue) -> String {
        return AnalyticsHelper.MainInstance.createProductInforForEventAction(
            issue.issuePii,
            fileFormat: Constants.Content.ValueFormatHTML,
            contentType: "xocs:scope-full",
            bibliographicInfo: AnalyticsHelper.MainInstance.createBibliographicInfo(issue.volume, issue: issue.issueNumber),
            articleStatus: "",
            articleTitle: issue.issueTitle!.lowercased(),
            accessType: issue.journal.accessType
        )
    }
    
    func getMapForContentValuesForAnalytics(issue: Issue) -> [String: AnyObject] {
        return AnalyticsHelper.MainInstance.createMapForContentUsage(
            issue.journal.accessType,
            contentID: issue.issuePii,
            bibliographic: AnalyticsHelper.MainInstance.createBibliographicInfo(issue.volume, issue: issue.issueNumber),
            contentFormat: Constants.Content.ValueFormatHTML,
            contentInnovationName: nil,
            contentStatus: nil,
            contentTitle: issue.issueTitle!.lowercased(),
            contentType: "xocs:scope-full",
            contentViewState: nil
        )
    }
    
    // MARK: - PDF
    
    func sendContentDownloadAnalyticsForPDF(article: Article) {
        let productInfo = analyticsProductInfoForPDF(article: article)
        let contentValues = analyticsGetMapForContentValuesForPDF(article: article)
        AnalyticsHelper.MainInstance.contentDownloadAnalytics(productInfo, contentInfo: contentValues)
    }
    
    func analyticsScreenViewForPDF(article: Article) {
        var stateContentData = analyticsGetMapForContentValuesForPDF(article: article)
        stateContentData[AnalyticsConstant.TagPageType] = Constants.Page.Type.cp_ca as AnyObject?
        stateContentData[Constants.Events.ContentDownload] = "0" as AnyObject?
        stateContentData[Constants.Events.ContentShare] = "0" as AnyObject?
        stateContentData[Constants.Events.ContentTurnAway] = "0" as AnyObject?
        stateContentData[Constants.Events.ContentView] = "1" as AnyObject?
        stateContentData[Constants.Events.ContentLogin] = "0" as AnyObject?
        stateContentData[Constants.Events.PDFView] = "1" as AnyObject?
        stateContentData[Constants.Events.ContentSaveToList] = "0" as AnyObject?
        stateContentData[Constants.Events.ContentUpsell] = "0" as AnyObject?
        stateContentData[Constants.Events.ProductInfo] = analyticsProductInfoForPDF(article: article) as AnyObject?
        AnalyticsHelper.MainInstance.setArticleDetailsContextInfo(stateContentData)
        AnalyticsHelper.MainInstance.trackState(Constants.Page.Name.Fulltext, stateContentData: stateContentData)
    }
    
    func analyticsGetMapForContentValuesForPDF(article: Article) -> [String: AnyObject] {
        var contentUsageMap = AnalyticsHelper.MainInstance.createMapForContentUsage(
            article.journal.accessType,
            contentID: article.articleInfoId,
            bibliographic: AnalyticsHelper.MainInstance.createBibliographicInfo(article.issue?.volume, issue: article.issue?.issueNumber),
            contentFormat: Constants.Content.ValueFormatPDF,
            contentInnovationName: nil,
            contentStatus: nil,
            contentTitle: article.articleTitle,
            contentType: Constants.Content.ValueTypeFull,
            contentViewState: Constants.ScreenType.FullText
        )
        contentUsageMap[Constants.Events.PDFView] = "1" as AnyObject?
        return contentUsageMap
    }
    
    func analyticsProductInfoForPDF(article: Article) -> String {
        return AnalyticsHelper.MainInstance.createProductInforForEventAction(
            article.articleInfoId,
            fileFormat: Constants.Content.ValueFormatPDF,
            contentType: "xocs:scope-full",
            bibliographicInfo: AnalyticsHelper.MainInstance.createBibliographicInfo(article.issue?.volume, issue: article.issue?.issueNumber),
            articleStatus: "",
            articleTitle: article.articleTitle!.lowercased(),
            accessType: article.journal.accessType
        )
    }
    
    func updateNavigationTitle() {
        let font = UIFont.systemFontOfSize(16, weight: SystemFontWeight.Bold)
        let size = NSString(string: screenTitle).size(attributes: [NSFontAttributeName: font])
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        titleLabel.textColor = UIColor.white
        titleLabel.font = font
        titleLabel.text = screenTitle
        titleLabel.accessibilityLabel = screenTitle
//        titleLabel.accessibilityTraits = UIAccessibilityTraitNone
        
        self.navigationItem.titleView = titleLabel
        self.navigationItem.titleView?.accessibilityTraits = UIAccessibilityTraitNone
    }
    
    @discardableResult func loadAndPresentURL(url: URL) -> Bool {
        if #available(iOS 9.0, *) {
            let safariController = SFSafariViewController(url: url)
            let navigationController = UINavigationController(rootViewController: safariController)
            navigationController.setNavigationBarHidden(true, animated: false)
            self.present(navigationController, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        return true
    }
    
    @discardableResult func loadAndPresentURL(string: String) -> Bool {
        guard let url = URL(string: string) else {
            return false
        }
        return loadAndPresentURL(url: url)
    }
    
    func showAnnouncementAlertIfNecessary() {
        let count = DatabaseManager.SharedInstance.getUnreadAnnouncementsCount()
        guard count > 0 else {
            return
        }
        let alertVC = UIAlertController(title: "There are \(count) new announcements.", message: nil, preferredStyle: .alert)
        switch screenType {
        case .tablet:
            alertVC.addAction(UIAlertAction(title: "View", style: .default, handler: { (alert) in
                performOnMainThread({
                    self.alertButtonClicked(self._alertBarButtonItem!)
                })
            }))
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        case .mobile:
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        }
        alertVC.present(from: self)
    }
    
    func showUsageAlertIfNecessary() {
        
        switch DatabaseManager.SharedInstance.checkForMemoryWarning() {
        case .fiveGB:
            
            var show = true
            let usageResponse = UserDefaults.standard.value(forKey: Strings.UserDefaults.Usage5G) as? Bool
            if usageResponse != nil {
                show = usageResponse!
            } else {
                UserDefaults.standard.set(true, forKey: Strings.UserDefaults.Usage5G)
            }
            
            guard show == true else {
                return
            }
            
            let alertVC = UIAlertController(title: "Over 5 GB of journal content has been downloaded and is being stored on your device.", message: "You can manage your usage by deleting content you no longer need within the setting -> Usage menu.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (alert) in
                UserDefaults.standard.set(false, forKey: Strings.UserDefaults.Usage1G)
            }))
            alertVC.addAction(UIAlertAction(title: "Manage Your Usage", style: .default, handler: { (alert) in
                self.showUsageScreen(forJournal: self.currentJournal)
            }))
            self.present(alertVC, animated: true, completion: nil)
            
        case .oneGB:
            
            var show = true
            let usageResponse = UserDefaults.standard.value(forKey: Strings.UserDefaults.Usage1G) as? Bool
            if usageResponse != nil {
                show = usageResponse!
            } else {
                UserDefaults.standard.set(true, forKey: Strings.UserDefaults.Usage1G)
            }
            
            guard show == true else {
                return
            }
            
            let alertVC = UIAlertController(title: "Over 1 GB of journal content has been downloaded and is being stored on your device.", message: "You can manage your usage by deleting content you no longer need within the setting -> Usage menu.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (alert) in
                UserDefaults.standard.set(false, forKey: Strings.UserDefaults.Usage1G)
            }))
            alertVC.addAction(UIAlertAction(title: "Manage Your Usage", style: .default, handler: { (alert) in
                self.showUsageScreen(forJournal: self.currentJournal)
            }))
            self.present(alertVC, animated: true, completion: nil)
            
        default:
            break
        }
    }
    
    func showUsageScreen(forJournal journal: Journal?) {
        switch screenType {
        case .mobile:
            
            self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
            let usageVC = UsageViewController()
            let navigationVC = UINavigationController(rootViewController: usageVC)
            navigationVC.modalPresentationStyle = .popover
            navigationVC.popoverPresentationController?.barButtonItem = settingsBarButtonItem
            navigationVC.preferredContentSize = CGSize(width: 400, height: 500)
            navigationVC.popoverPresentationController?.backgroundColor = AppConfiguration.NavigationItemColor
            navigationVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppConfiguration.NavigationBarColor]
            navigationVC.navigationBar.barTintColor = AppConfiguration.NavigationItemColor
            navigationVC.navigationBar.tintColor = AppConfiguration.NavigationBarColor
            self.currentPopover = navigationVC.popoverPresentationController
            self.present(navigationVC, animated: true, completion: nil)
            
        case .tablet:
            
            self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
            let usageVC = UsageViewController()
            let navigationVC = UINavigationController(rootViewController: usageVC)
            navigationVC.modalPresentationStyle = .popover
            navigationVC.popoverPresentationController?.barButtonItem = settingsBarButtonItem
            navigationVC.preferredContentSize = CGSize(width: 400, height: 500)
            navigationVC.popoverPresentationController?.backgroundColor = AppConfiguration.NavigationItemColor
            navigationVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppConfiguration.NavigationBarColor]
            navigationVC.navigationBar.barTintColor = AppConfiguration.NavigationItemColor
            navigationVC.navigationBar.tintColor = AppConfiguration.NavigationBarColor
            self.currentPopover = navigationVC.popoverPresentationController
            self.present(navigationVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Downloading -

extension JBSMViewController {
    
    // MARK: BUTTON CLICK
    
    func userDidClickDownload(forIssue issue: Issue) {
        
        guard NETWORK_AVAILABLE else {
            Alerts.NoNetwork().present(from: self)
            return
        }
        
        if issue.userHasAccess {
            download(issue: issue, startingWithArticle: nil, pushVC: false)
        } else {
            showIssueAuthenticationAlert(issue: issue, article: nil, pushVC: false)
        }
    }
    
    func userDidClickDownload(forArticle article: Article) {
        if article.issue != .none {
            userDidClickDownloadButtonForOpenAccessArticle(article)
        } else {
            userDidClickDownloadButtonForAIPArticle(article)
        }
    }
    
    func userDidClickDownloadButtonForAIPArticle(_ article: Article) {
        guard article.userHasAccess else {
            showAIPAuthenticationAlert(aipArticle: article, pushVC: false)
            return
        }
        download(aipArticle: article, pushVC: false)
    }
    
    func userDidClickDownloadButtonForOpenAccessArticle(_ article: Article) {
        guard article.isArticleOnlyOpenAccess else {
            log.error("Attempting to download an Open Access article that can't be downloaded individually")
            return
        }
        download(openAccessArticle: article, pushVC: false)
    }
    
    // MARK: CELL CLICK
    
    func userDidRequestFullTextDownload(_ article: Article, pushVC: Bool) {
        switch article.downloadInfo.fullTextDownloadStatus {
        case .downloadFailed, .notDownloaded:
            if let _issue = article.issue {
                if article.isArticleOnlyOpenAccess {
                    download(openAccessArticle: article, pushVC: pushVC)
                } else {
                    if _issue.userHasAccess {
                        download(issue: _issue, startingWithArticle: article, pushVC: pushVC)
                    } else {
                        showIssueAuthenticationAlert(issue: _issue, article: article, pushVC: pushVC)
                    }
                }
            } else {
                if article.userHasAccess {
                    download(aipArticle: article, pushVC: pushVC)
                } else {
                    showAIPAuthenticationAlert(aipArticle: article, pushVC: pushVC)
                }
            }
        default:
            break
        }
    }
    
    func didSelectArticleFromArticles(_ article: Article, articles: [Article]?) {
        let issue = article.issue ?? nil
        switch article.downloadInfo.fullTextDownloadStatus {
        case .downloaded, .downloading:
            pushViewControllerWith(_articles: articles, firstArticle: article, issue: issue)
        default:
            if article.downloadInfo.abstractDownloadStatus == .downloaded {
                pushViewControllerWith(_articles: articles, firstArticle: article, issue: issue)
            } else {
                guard NETWORK_AVAILABLE else {
                    Alerts.NoNetwork().present(from: self)
                    return
                }
                if article.downloadInfo.abstractDownloadStatus == .downloading {
                    showAbstractDownloadingAlert()
                } else {
                    userDidRequestFullTextDownload(article, pushVC: true)
                }
            }
        }
    }
    
    func userDidSelectAIPArticles(_ articles: [Article]) {
        guard articles.count > 0 else { return }
        for article in articles {
            if !article.userHasAccess {
                showAIPAuthenticationAlert(aipArticles: articles)
                return
            }
        }
        download(aipArticles: articles)
    }
    
    // MARK: DOWNLOAD
    
    func download(openAccessArticle article: Article, pushVC: Bool) {
        Alerts.DownloadOa(article) { (push) in
            guard pushVC == true else { return }
            guard push   == true else { return }
            self.pushViewControllerWith(_articles: self.articlesForPush, firstArticle: article, issue: article.issue)
        }.present(from: self)
    }
    
    func download(aipArticle article: Article, pushVC: Bool) {
        Alerts.Download(article: article) { (push) in
            guard pushVC == true else { return }
            guard push   == true else { return }
            self.pushViewControllerWith(_articles: self.articlesForPush, firstArticle: article, issue: nil)
        }.present(from: self)
    }
    
    func download(aipArticles articles: [Article]) {
        Alerts.Download(articles: articles) { }.present(from: self)
    }
    
    func download(issue: Issue, startingWithArticle article: Article?, pushVC: Bool) {
        Alerts.Download(issue: issue, startingWith: article) { (push) in
            guard pushVC     == true else    { return }
            guard push       == true else    { return }
            guard let article = article else { return }
            
            self.pushViewControllerWith(_articles: self.articlesForPush, firstArticle: article, issue: article.issue)
        }.present(from: self)
    }
    
    
    // MARK: PUSH VIEW CONTROLLER
    
    //  Will now need to pass in 'articlesForPush' in all pre-existing calls to this method.
    func pushViewControllerWith(_articles: [Article]?, firstArticle: Article, issue: Issue?) {
        
        var articles: [Article] = []
        var backTitle = "Back"
        
        if let __articles = _articles {
            articles = __articles
        }
        
        if let issue = issue {
//            if article.downloadInfo.fullTextDownloadStatus == .downloading {
//            }
            backTitle = issue.releaseDateAbbrDisplay ?? "Back"
            if _articles == nil {
                articles = DatabaseManager.SharedInstance.getAllArticlesForIssue(issue)
            }
        } else {
            backTitle = "AIPs"
            if _articles == nil {
                articles = DatabaseManager.SharedInstance.getAips(journal: firstArticle.journal)
            }
        }
        
        let articlePC = ArticlePagerController(article: firstArticle, articleArray: articles)
        articlePC.backTitleString = backTitle
        performOnMainThread {
            self.navigationController?.pushViewController(articlePC, animated: true)
        }
    }
    
    var articlesForPush: [Article]? {
        return nil
    }
    
    // MARK: ALERTS
    
    func showAbstractDownloadingAlert() {
        Alerts.AbstractDownloading().present(from: self)
    }
    
    func showAIPAuthenticationAlert(aipArticle article: Article, pushVC: Bool) {
        Alerts.Login(article: article) { (type) in
            switch type {
            case .login:
                var info = LoginViewControllerInfo(journal: article.journal, issue: nil, article: article)
                info.pushVC = pushVC
                self.showLoginViewController(info)
            case .journal:
                guard let featureId = article.journal.subscriptionId else { return }
                self.loginSubscribeToFeature(featureId: featureId)
            case .issue:
                break
            case .restore:
                self.loginRestorePurchase()
            }
        }.present(from: self)
    }
    
    func showAIPAuthenticationAlert(aipArticles articles: [Article]) {
        guard articles.count > 0 else { return }
        let journal = articles[0].journal
        Alerts.AuthenticateAIPs(articles[0].journal) { (type) in
            switch type {
            case .login:
                guard let info = LoginViewControllerInfo(articles: articles) else { return }
                self.showLoginViewController(info)
            case .journal:
                guard let featureId = journal?.subscriptionId else { return }
                self.loginSubscribeToFeature(featureId: featureId)
            case .issue:
                break
            case .restore:
                self.loginRestorePurchase()
            }
        }.present(from: self)
    }

    func showMediaAuthAlert(media: Media, forDownload: Bool) {
        let article = media.article
        var info = LoginViewControllerInfo(journal: (article?.journal)!, issue: nil, article: article)
        info.media = media
        info.forMediaDownload = forDownload
        showLoginViewController(info)
    }
    
    func showMediaAuthenticationAlert(media: Media, forDownload: Bool) {
        Alerts.Login(media: media) { (type) in
            switch type {
            case .login:
                var info = LoginViewControllerInfo(journal: media.article.journal, issue: media.article.issue, article: media.article)
                info.pushVC = false
                info.media = media
                info.forMediaDownload = forDownload
                self.showLoginViewController(info)
            case .journal:
                guard let featureId = media.article.journal.subscriptionId else { return }
                self.loginSubscribeToFeature(featureId: featureId)
            case .issue:
                guard let featureId = media.article.issue?.productId else { return }
                self.loginPurchaseFeature(featureId: featureId)
            case .restore:
                self.loginRestorePurchase()
            }
        }.present(from: self)
    }
    
    func showIssueAuthenticationAlert(issue: Issue, article: Article?, pushVC: Bool) {
        Alerts.Login(issue: issue) { (type) in
            switch type {
            case .login:
                var info = LoginViewControllerInfo(journal: issue.journal, issue: issue, article: article)
                info.pushVC = pushVC
                
                self.showLoginViewController(info)
            case .journal:
                guard let featureId = issue.journal.subscriptionId else { return }
                self.loginSubscribeToFeature(featureId: featureId)
            case .issue:
                guard let featureId = issue.productId else { return }
                self.loginPurchaseFeature(featureId: featureId)
            case .restore:
                self.loginRestorePurchase()
            }
        }.present(from: self)
    }
    
    func showDownloadDialogueForMedia(_ media: Media) {
        if media.article.fullTextDownloaded {
            Alerts.DownloadMedia(media, fullText: true).present(from: self)
        } else {
            Alerts.DownloadMedia(media, fullText: false).present(from: self)
        }
    }
    
    // MARK: LOGIN
    
    func showLoginViewController(_ info: LoginViewControllerInfo) {
        
        let loginVC = LoginViewController(info: info)
        loginVC.isDismissable = true
        loginVC.navigationItem.hidesBackButton = true
        loginVC.navigationItem.leftBarButtonItem = loginVC.closeBarButtonItem
        loginVC.loginDelegate = self

        let navigationVC = UINavigationController(rootViewController: loginVC)
        navigationVC.modalPresentationStyle = .formSheet
        
        performOnMainThread({ self.present(navigationVC, animated: true, completion: nil) })
    }
    
    // MARK: IAP
    
    func loginRestorePurchase() {
        MKStoreManager.shared().restorePreviousTransactions(onComplete: {
            Alerts.LoginRestoreTransactionCompleted().present(from: self)
        }) { (error) in
            log.error(error?.localizedDescription)
            Alerts.LoginRestoreTransactionFailed().present(from: self)
        }
    }
    
    func loginSubscribeToFeature(featureId: String) {
        if MKStoreManager.shared().isSubscriptionActive(featureId) {
            Alerts.LoginSubscriptionAlreadyPurchased().present(from: self)
        } else {
            MKStoreManager.shared().buyFeature(featureId, onComplete: { (purchasedFeature, purchasedReciept, availableDownloads) in
                if MKStoreManager.shared().isSubscriptionActive(featureId) {
                    Alerts.LoginSubscriptionSuccessful().present(from: self)
                } else {
                    Alerts.LoginSubscriptionFailed().present(from: self)
                }
                }, onCancelled: {
                    Alerts.LoginTransactionCancelled().present(from: self)
            })
        }
    }
    
    func loginPurchaseFeature(featureId: String) {
        if MKStoreManager.shared().isSubscriptionActive(featureId) {
            Alerts.LoginSubscriptionAlreadyPurchased().present(from: self)
        } else {
            MKStoreManager.shared().buyFeature(featureId, onComplete: { (purchasedFeature, purchasedReciept, availableDownloads) in
                if MKStoreManager.isFeaturePurchased(featureId) {
                    Alerts.loginPurchaseSuccessful().present(from: self)
                } else {
                    Alerts.loginPurchaseFailure().present(from: self)
                }
                }, onCancelled: {
                    Alerts.LoginTransactionCancelled().present(from: self)
            })
        }
    }
}

// MARK: - Login Delegate -

extension JBSMViewController: LoginVCDelegate {
    
    func userDidCompleteLogin(_ article: Article?, issue: Issue?) {

        if let _article = article, let _issue = issue {
            download(issue: _issue, startingWithArticle: _article, pushVC: false)
        } else if let _article = article {
            download(aipArticle: _article, pushVC: false)
        } else if let _issue = issue {
            download(issue: _issue, startingWithArticle: nil, pushVC: false)
        }
    }
    
    func userDidCompleteLogin(_ info: LoginViewControllerInfo) {
        if info.type == .aipList {
            download(aipArticles: info.articles)
        } else {
            if let _article = info.article, let _issue = info.issue {
                download(issue: _issue, startingWithArticle: _article, pushVC: info.pushVC)
            } else if let _article = info.article {
                download(aipArticle: _article, pushVC: info.pushVC)
            } else if let _issue = info.issue {
                download(issue: _issue, startingWithArticle: nil, pushVC: info.pushVC)
            }
        }
    }
    
    func didLoginForMedia(_ media: Media, forDownload: Bool) {
        let article = media.article

        if article?.userHasAccess == true && forDownload == true {
            showDownloadDialogueForMedia(media)
        } else if article?.userHasAccess == false {
            let alert = Alerts.noAccess()
            performOnMainThread({
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
}


enum MFMailComposeResultEnum {
    
}

extension JBSMViewController: MFMailComposeViewControllerDelegate {
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { 
            if result == MFMailComposeResult.sent {
                Alerts.MailSent().present(from: self)
                return
            }
            if result == MFMailComposeResult.saved {
                Alerts.MailSavedToDrafts().present(from: self)
                return
            }
            if result == MFMailComposeResult.failed {
                Alerts.MailCancelled().present(from: self)
                return
            }
            if result == MFMailComposeResult.cancelled {
                Alerts.MailCancelled().present(from: self)
                return
            }
        }
    }
}
