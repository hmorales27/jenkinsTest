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
    case WillTransition
    case DidTransition
}

enum ScreenType {
    case Mobile
    case Tablet
    
    static func TypeForSize(size: CGSize) -> ScreenType {
        if size.width < 768 {
            return .Mobile
        } else {
            return .Tablet
        }
    }
}

enum OrientationType {
    case Portrait
    case Landscape
    
    static func CurrentOrientation() -> OrientationType {
        let orientation = JBSMDevice().currentOrientation()
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            return .Landscape
        default:
            return .Portrait
        }
    }
}

struct LoginViewControllerInfo {
    
    enum `Type` {
        case AIP
        case AIPList
        case Issue
        case OpenAccess
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
        self.type = .AIPList
    }
}

public class JBSMViewController: UIViewController, AnnouncementControllerDelegate {
    
    var currentJournal: Journal?
    var currentIssue: Issue?
    
    var analyticsScreenName: String?
    var analyticsScreenType: String?
    
    var _registerForKeyboardChange: Bool = false
    
    weak var currentPopover: UIPopoverPresentationController?
    
    var currentlyDisplayedView = true
    
    var screenType: ScreenType {
        get {
            return ScreenType.TypeForSize(size: view.frame.size)
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
                if screenType == .Mobile {
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
                if screenType == .Mobile {
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
        var contentData: [String: Any] = [:]
        contentData[AnalyticsConstant.TagPageType] = analyticsScreenType
        AnalyticsHelper.MainInstance.trackState(pageName: analyticsScreenName!, stateContentData: contentData)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _destroypNotifications()
    }
    
    private func _setupNotifications() {
        let notificationCenter = NotificationCenter.default
        if _registerForKeyboardChange == true {
            notificationCenter.addObserver(self, selector: #selector(keyboardDisplayDidChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            notificationCenter.addObserver(self, selector: #selector(keyboardDisplayDidChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
        notificationCenter.addObserver(self, selector: #selector(_notification_download_issue_started(notification:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.DownloadStarted), object: nil)
        notificationCenter.addObserver(self, selector: #selector(_notification_download_issue_completed(notification:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.DownloadComplete), object: nil)
        notificationCenter.addObserver(self, selector: #selector(_notification_download_aip_started(notification:)), name: NSNotification.Name(rawValue: Notification.Download.AIP.Started), object: nil)
        notificationCenter.addObserver(self, selector: #selector(_notification_download_aip_completed(notification:)), name: NSNotification.Name(rawValue: Notification.Download.AIP.Completed), object: nil)
        notificationCenter.addObserver(self, selector: #selector(deviceOrientationDidChange(sender:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func deviceOrientationDidChange(sender: NSNotification) {
        self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    func keyboardDisplayDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let endFrame = (userInfo["UIKeyboardFrameEndUserInfoKey"] as? NSValue)?.cgRectValue else {
            return
        }
        if notification.name == NSNotification.Name.UIKeyboardWillShow {
            updateKeyboardForRect(rect: endFrame)
        } else {
            updateKeyboardForRect(rect: CGRect.zero)
        }
    }
    
    func updateKeyboardForRect(rect: CGRect) {
        
    }
    
    private func _update() {
        
    }
    
    private func _destroy() {
        _destroyNotifications()
    }
    
    private func _destroyNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Buttons -
    
    lazy var settingsBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: JBSMImages.Settings(), style: .plain, target: self, action: #selector(settingsButtonClicked(sender:)))
        barButtonItem.accessibilityLabel = "Settings Menu"
        barButtonItem.accessibilityTraits = UIAccessibilityTraitNone
        return barButtonItem
    }()
    
    lazy var backBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: JBSMImages.Back(), style: .plain, target: self, action: #selector(backButtonClicked(sender:)))
    }()
    
    lazy var menuBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "Menu"), style: .plain, target: self, action: #selector(menuButtonClicked(sender:)))
        barButtonItem.accessibilityLabel = "Open Slide Menu"
        barButtonItem.accessibilityTraits = UIAccessibilityTraitNone
        return barButtonItem
    }()
    
    lazy var closeBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "Close"), style: .plain, target: self, action: #selector(closeButtonClicked(sender:)))
    }()
    
    lazy var searchBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "Search"), style: .plain, target: self, action: #selector(searchButtonClicked(sender:)))
        barButtonItem.accessibilityLabel = "Search Menu"
        barButtonItem.accessibilityTraits = UIAccessibilityTraitNone
        return barButtonItem
    }()
    
    lazy var infoBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "Info"), style: .plain, target: self, action: #selector(infoButtonClicked(sender:)))
        barButtonItem.accessibilityLabel = "Information Menu"
        barButtonItem.accessibilityTraits = UIAccessibilityTraitNone
        return barButtonItem
    }()
    
    var _alertBarButtonItem: UIBarButtonItem?
    
    func alertBarButtonItem() -> BBBadgeBarButtonItem {
        let customButton = UIButton(type: .custom)
        customButton.setImage(UIImage(named: "Alert"), for: .normal)
        customButton.frame = CGRect(x: 0, y: 0, width: 46, height: 30)
        customButton.addTarget(self, action: #selector(alertButtonClicked(sender:)), for: .touchUpInside)
        
        guard let barButton = BBBadgeBarButtonItem(customUIButton: customButton) else {
            return BBBadgeBarButtonItem()
        }
        
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
        
        if unreadCount > 0 {
            barButton.badgeValue = "\(unreadCount)"
            customButton.accessibilityLabel = unreadCount > 1 ? "You have \(unreadCount) unread announcements" :
            "You have \(unreadCount) unread announcement"
        }
        
        if totalCount == 0 {
            barButton.isEnabled = false
        }
        
        return barButton
        
    }
    
    var _downloadBarButtonItem: UIBarButtonItem?
    
    func getDownloadBarButtonItem() -> BBBadgeBarButtonItem {
        let customButton = UIButton(type: .custom)
        customButton.setImage(UIImage(named: "Download"), for: .normal)
        customButton.frame = CGRect(x: 0, y: 0, width: 46, height: 30)
        customButton.addTarget(self, action: #selector(downloadButtonClicked(sender:)), for: .touchUpInside)
        let barButton = BBBadgeBarButtonItem(customUIButton: customButton)
        
        let sections = DMManager.sharedInstance.sectionsWithFullTextOrSupplement
        
        if sections.count > 0 {
            barButton?.badgeValue = "\(sections.count)"
        }
        
        return barButton!
    }
    
    var rightBarButtonItems: [UIBarButtonItem] {
        var items: [UIBarButtonItem] = []
        _alertBarButtonItem = alertBarButtonItem()
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
    
    func settingsButtonClicked(sender: UIBarButtonItem) {
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
    
    func menuButtonClicked(sender: Any) {
        self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
        if let slider = self as? SLViewController {
            slider.toggleSliderMenu(sender: sender)
        }
    }
    
    func backButtonClicked(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    func closeButtonClicked(sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func downloadButtonClicked(sender: UIBarButtonItem) {
        self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
        let downloadVC = DMSectionsViewController()
        downloadVC.enabled = false
        downloadVC.currentJournal = self.currentJournal
        let navigationVC = UINavigationController(rootViewController: downloadVC)
        navigationVC.modalPresentationStyle = UIModalPresentationStyle.popover
        navigationVC.popoverPresentationController?.barButtonItem = _downloadBarButtonItem
        navigationVC.preferredContentSize = CGSize(width: 400, height: 500)
        navigationVC.popoverPresentationController?.backgroundColor = AppConfiguration.NavigationItemColor
        navigationVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppConfiguration.NavigationBarColor]
        navigationVC.navigationBar.barTintColor = AppConfiguration.NavigationItemColor
        navigationVC.navigationBar.tintColor = AppConfiguration.NavigationBarColor
        self.currentPopover = navigationVC.popoverPresentationController
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    func searchButtonClicked(sender: UIBarButtonItem) {
        self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
        let information = SearchInformation()
        information.currentIssue = currentIssue
        information.currentJournal = currentJournal
        
        let searchVC = SearchViewController(information: information)
        searchVC.title = "Search"
        let navigationVC = UINavigationController(rootViewController: searchVC)
        navigationVC.modalPresentationStyle = UIModalPresentationStyle.popover
        navigationVC.popoverPresentationController?.barButtonItem = sender
        navigationVC.preferredContentSize = CGSize(width: 400, height: 500)
        navigationVC.popoverPresentationController?.backgroundColor = AppConfiguration.NavigationItemColor
        navigationVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppConfiguration.NavigationBarColor]
        navigationVC.navigationBar.barTintColor = AppConfiguration.NavigationItemColor
        navigationVC.navigationBar.tintColor = AppConfiguration.NavigationBarColor
        self.currentPopover = navigationVC.popoverPresentationController
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    func infoButtonClicked(sender: UIBarButtonItem) {
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
    
    func alertButtonClicked(sender: UIBarButtonItem) {
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
    
    
    private func _destroypNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func _notification_download_issue_started(notification: NSNotification) {
        performOnMainThread {
            self.setupNavigationBar()
        }
    }
    
    @objc private func _notification_download_issue_completed(notification: NSNotification) {
        performOnMainThread {
            self.setupNavigationBar()
        }
    }
    
    func _notification_download_aip_started(notification: NSNotification) {
        performOnMainThread {
            self.setupNavigationBar()
        }
    }
    
    func _notification_download_aip_completed(notification: NSNotification) {
        performOnMainThread {
            self.setupNavigationBar()
        }
    }
    
    // MARK: - Rotation & Multitasking
    
    func updateViewsForScreenChange(type: ScreenType) {
        
    }
    
    func updateViewsForScreenChange(type: ScreenType, expectedWidth: CGFloat) {
        
    }
    
    func updateViewsForScreenChange(type: ScreenType, withExpectedWidth width: CGFloat, forTransitionState state: ScreenTransitionState) {
        
    }
    
    override public func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    override public func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.currentPopover?.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        guard currentlyDisplayedView else { return }
        
        coordinator.animate(alongsideTransition: { (coordinatorContext) in
            self.updateViewsForScreenChange(type: ScreenType.TypeForSize(size: size), withExpectedWidth: size.width, forTransitionState: .WillTransition)
        }) { (coordinatorContext) in
            self.updateViewsForScreenChange(type: ScreenType.TypeForSize(size: size), withExpectedWidth: size.width, forTransitionState: .DidTransition)
        }
        updateViewsForScreenChange(type: ScreenType.TypeForSize(size: size))
        updateViewsForScreenChange(type: ScreenType.TypeForSize(size: size), expectedWidth: size.width)
    }
    
    func backButtons(text: String, dark: Bool = true) -> [UIBarButtonItem] {
        
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(backButtonClicked(sender:)), for: .touchUpInside)
        
        let size = text.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]).width
        button.frame = CGRect(x: 0, y: 0, width: size + 24, height: 20)
        button.setTitle(text, for: .normal)
        if dark == true {
            button.setTitleColor(UIColor.black, for: .normal)
            button.setTitleColor(UIColor.veryLightGray(), for: .selected)
        } else {
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitleColor(UIColor.veryLightGray(), for: .selected)
        }
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        
        let image = UIImage(named: "Back")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        button.setImage(image, for: .normal)
        if dark == true {
            button.tintColor = UIColor.black
        } else {
            button.tintColor = UIColor.white
        }
        
        let navButton = UIBarButtonItem(customView: button)
        navButton.target = self
        navButton.action = #selector(self.backButtonClicked(sender:))
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
        let contentValues = getMapForContentValuesForAnalytics(article: article)
        AnalyticsHelper.MainInstance.contentDownloadAnalytics(productInfo: productInfo, contentInfo: contentValues)
    }
    
    func getProductInfoForAnalytics(article: Article) -> String {
        return AnalyticsHelper.MainInstance.createProductInforForEventAction(
            articleInfoId: article.articleInfoId,
            fileFormat: Constants.Content.ValueFormatHTML,
            contentType: "xocs:scope-full",
            bibliographicInfo: AnalyticsHelper.MainInstance.createBibliographicInfo(volume: article.issue?.volume, issue: article.issue?.issueNumber),
            articleStatus: "",
            articleTitle: article.articleTitle!.lowercased(),
            accessType: article.journal.accessType
        )
    }
    
    func getMapForContentValuesForAnalytics(article: Article) -> [String: Any] {
        return AnalyticsHelper.MainInstance.createMapForContentUsage(
            contentAccessType: article.journal.accessType,
            contentID: article.articleInfoId,
            bibliographic: AnalyticsHelper.MainInstance.createBibliographicInfo(volume: article.issue?.volume, issue: article.issue?.issueNumber),
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
        let contentValues = getMapForContentValuesForAnalytics(issue: issue)
        AnalyticsHelper.MainInstance.contentDownloadAnalytics(productInfo: productInfo, contentInfo: contentValues)
    }
    
    func getProductInfoForAnalytics(issue: Issue) -> String {
        return AnalyticsHelper.MainInstance.createProductInforForEventAction(
            articleInfoId: issue.issuePii,
            fileFormat: Constants.Content.ValueFormatHTML,
            contentType: "xocs:scope-full",
            bibliographicInfo: AnalyticsHelper.MainInstance.createBibliographicInfo(volume: issue.volume, issue: issue.issueNumber),
            articleStatus: "",
            articleTitle: issue.issueTitle!.lowercased(),
            accessType: issue.journal.accessType
        )
    }
    
    func getMapForContentValuesForAnalytics(issue: Issue) -> [String: Any] {
        return AnalyticsHelper.MainInstance.createMapForContentUsage(
            contentAccessType: issue.journal.accessType,
            contentID: issue.issuePii,
            bibliographic: AnalyticsHelper.MainInstance.createBibliographicInfo(volume: issue.volume, issue: issue.issueNumber),
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
        AnalyticsHelper.MainInstance.contentDownloadAnalytics(productInfo: productInfo, contentInfo: contentValues)
    }
    
    func analyticsScreenViewForPDF(article: Article) {
        var stateContentData: [String: Any] = analyticsGetMapForContentValuesForPDF(article: article)
        stateContentData[AnalyticsConstant.TagPageType] = Constants.Page.Type.cp_ca
        stateContentData[Constants.Events.ContentDownload] = "0"
        stateContentData[Constants.Events.ContentShare] = "0"
        stateContentData[Constants.Events.ContentTurnAway] = "0"
        stateContentData[Constants.Events.ContentView] = "1"
        stateContentData[Constants.Events.ContentLogin] = "0"
        stateContentData[Constants.Events.PDFView] = "1"
        stateContentData[Constants.Events.ContentSaveToList] = "0"
        stateContentData[Constants.Events.ContentUpsell] = "0"
        stateContentData[Constants.Events.ProductInfo] = analyticsProductInfoForPDF(article: article)
        AnalyticsHelper.MainInstance.setArticleDetailsContextInfo(articleDetailsContextInfo: stateContentData)
        AnalyticsHelper.MainInstance.trackState(pageName: Constants.Page.Name.Fulltext, stateContentData: stateContentData)
    }
    
    func analyticsGetMapForContentValuesForPDF(article: Article) -> [String: Any] {
        var contentUsageMap = AnalyticsHelper.MainInstance.createMapForContentUsage(
            contentAccessType: article.journal.accessType,
            contentID: article.articleInfoId,
            bibliographic: AnalyticsHelper.MainInstance.createBibliographicInfo(volume: article.issue?.volume, issue: article.issue?.issueNumber),
            contentFormat: Constants.Content.ValueFormatPDF,
            contentInnovationName: nil,
            contentStatus: nil,
            contentTitle: article.articleTitle,
            contentType: Constants.Content.ValueTypeFull,
            contentViewState: Constants.ScreenType.FullText
        )
        contentUsageMap[Constants.Events.PDFView] = "1"
        return contentUsageMap
    }
    
    func analyticsProductInfoForPDF(article: Article) -> String {
        return AnalyticsHelper.MainInstance.createProductInforForEventAction(
            articleInfoId: article.articleInfoId,
            fileFormat: Constants.Content.ValueFormatPDF,
            contentType: "xocs:scope-full",
            bibliographicInfo: AnalyticsHelper.MainInstance.createBibliographicInfo(volume: article.issue?.volume, issue: article.issue?.issueNumber),
            articleStatus: "",
            articleTitle: article.articleTitle!.lowercased(),
            accessType: article.journal.accessType
        )
    }
    
    func updateNavigationTitle() {
        let font = UIFont.systemFontOfSize(fontSize: 16, weight: SystemFontWeight.Bold)
        let size = NSString(string: screenTitle).size(attributes: [NSFontAttributeName: font])
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        titleLabel.textColor = UIColor.white
        titleLabel.font = font
        titleLabel.text = screenTitle
        titleLabel.accessibilityLabel = screenTitle
        self.navigationItem.titleView = titleLabel
    }
    
    func loadAndPresentURL(url: URL) -> Bool {
        if #available(iOS 9.0, *) {
            let safariController = SFSafariViewController(url: url)
            let navigationController = UINavigationController(rootViewController: safariController)
            navigationController.setNavigationBarHidden(true, animated: false)
            self.present(navigationController, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(url as URL)
        }
        return true
    }
    
    func loadAndPresentURL(string: String) -> Bool {
        guard let url = NSURL(string: string) else {
            return false
        }
        return loadAndPresentURL(url: url as URL)
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
            userDidClickDownloadButtonForOpenAccessArticle(article: article)
        } else {
            userDidClickDownloadButtonForAIPArticle(article: article)
        }
    }
    
    func userDidClickDownloadButtonForAIPArticle(article: Article) {
        guard article.userHasAccess else {
            showAIPAuthenticationAlert(aipArticle: article, pushVC: false)
            return
        }
        download(aipArticle: article, pushVC: false)
    }
    
    func userDidClickDownloadButtonForOpenAccessArticle(article: Article) {
        guard article.isArticleOnlyOpenAccess else {
            log.error("Attempting to download an Open Access article that can't be downloaded individually")
            return
        }
        download(openAccessArticle: article, pushVC: false)
    }
    
    // MARK: CELL CLICK
    
    func userDidRequestFullTextDownload(article: Article, pushVC: Bool) {
        switch article.downloadInfo.fullTextDownloadStatus {
        case .DownloadFailed, .NotDownloaded:
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
    
    func userDidSelectArticle(article: Article) {
        let issue = article.issue ?? nil
        switch article.downloadInfo.fullTextDownloadStatus {
        case .Downloaded, .Downloading:
            pushViewController(article: article, issue: issue)
        default:
            switch article.downloadInfo.abstractDownloadStatus {
            case .Downloaded:
                pushViewController(article: article, issue: issue)
            case .Downloading:
                showAbstractDownloadingAlert()
            default:
                userDidRequestFullTextDownload(article: article, pushVC: true)
            }
        }
    }
    
    func userDidSelectAIPArticles(articles: [Article]) {
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
        Alerts.DownloadOa(article: article) { (push) in
            guard pushVC == true else { return }
            guard push   == true else { return }
            self.pushViewController(article: article, issue: article.issue)
            }.present(from: self)
    }
    
    func download(aipArticle article: Article, pushVC: Bool) {
        Alerts.Download(article: article) { (push) in
            guard pushVC == true else { return }
            guard push   == true else { return }
            self.pushViewController(article: article, issue: nil)
            }.present(from: self)
    }
    
    func download(aipArticles articles: [Article]) {
        Alerts.Download(articles: articles) { }.present(from: self)
    }
    
    func download(issue issue: Issue, startingWithArticle article: Article?, pushVC: Bool) {
        Alerts.Download(issue: issue, startingWith: article) { (push) in
            guard pushVC     == true else    { return }
            guard push       == true else    { return }
            guard let article = article else { return }
            self.pushViewController(article: article, issue: article.issue)
            }.present(from: self)
    }
    
    // MARK: PUSH VIEW CONTROLLER
    
    func pushViewController(article: Article, issue: Issue?) {
        
        let _articles = articlesForPush
        
        var articles: [Article] = []
        var backTitle = "Back"
        
        if let __articles = _articles {
            articles = __articles
        }
        
        if let issue = issue {
            if article.downloadInfo.fullTextDownloadStatus == .Downloading {
                DMManager.sharedInstance.changePriorityForArticle(article: article)
            }
            backTitle = issue.releaseDateAbbrDisplay ?? "Back"
            if _articles == nil {
                articles = DatabaseManager.SharedInstance.getAllArticlesForIssue(issue: issue)
            }
        } else {
            backTitle = "AIPs"
            if _articles == nil {
                articles = DatabaseManager.SharedInstance.getAIPsForJournal(journal: article.journal)
            }
        }
        
        let articlePC = ArticlePagerController(article: article, articleArray: articles)
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
            case .Login:
                var info = LoginViewControllerInfo(journal: article.journal, issue: nil, article: article)
                info.pushVC = pushVC
                self.showLoginViewController(info: info)
            case .Journal:
                guard let featureId = article.journal.subscriptionId else { return }
                self.loginPurchaseFeature(featureId: featureId)
            case .Issue:
                break
            case .Restore:
                self.loginRestorePurchase()
            }
            }.present(from: self)
    }
    
    func showAIPAuthenticationAlert(aipArticles articles: [Article]) {
        guard articles.count > 0 else { return }
        let journal = articles[0].journal
        Alerts.AuthenticateAIPs(journal: articles[0].journal) { (type) in
            switch type {
            case .Login:
                guard let info = LoginViewControllerInfo(articles: articles) else { return }
                self.showLoginViewController(info: info)
            case .Journal:
                guard let featureId = journal?.subscriptionId else { return }
                self.loginPurchaseFeature(featureId: featureId)
            case .Issue:
                break
            case .Restore:
                self.loginRestorePurchase()
            }
            }.present(from: self)
    }
    
    func showMediaAuthAlert(media: Media, forDownload: Bool) {
        
        //  make *SURE* that alert presented when authenticated offers options
        //  to download single OR multiple medias
        
        guard let article = media.article else {
            return
        }
        
        //  Probably just going to make an optional media property on LoginVcInfo here
        var info = LoginViewControllerInfo(journal: article.journal, issue: nil, article: article)
        info.media = media
        info.forMediaDownload = forDownload
        showLoginViewController(info: info)
    }
    
    
    func showIssueAuthenticationAlert(issue issue: Issue, article: Article?, pushVC: Bool) {
        Alerts.Login(issue: issue) { (type) in
            switch type {
            case .Login:
                var info = LoginViewControllerInfo(journal: issue.journal, issue: issue, article: article)
                info.pushVC = pushVC
                self.showLoginViewController(info: info)
            case .Journal:
                guard let featureId = issue.journal.subscriptionId else { return }
                self.loginPurchaseFeature(featureId: featureId)
            case .Issue:
                guard let featureId = issue.productId else { return }
                self.loginPurchaseFeature(featureId: featureId)
            case .Restore:
                self.loginRestorePurchase()
            }
            }.present(from: self)
    }
    
    func showDownloadDialogueForMedia(media: Media) {
        if media.article.fullTextDownloaded {
            Alerts.DownloadMedia(media: media, fullText: true).present(from: self)
        } else {
            Alerts.DownloadMedia(media: media, fullText: false).present(from: self)
        }
    }
    
    // MARK: LOGIN
    
    func showLoginViewController(info: LoginViewControllerInfo) {
        
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
    
    func loginPurchaseFeature(featureId: String) {
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
}

// MARK: - Login Delegate -

extension JBSMViewController: LoginVCDelegate {
    
    func userDidCompleteLogin(article: Article?, issue: Issue?) {
        
        if let _article = article, let _issue = issue {
            download(issue: _issue, startingWithArticle: _article, pushVC: false)
        } else if let _article = article {
            download(aipArticle: _article, pushVC: false)
        } else if let _issue = issue {
            download(issue: _issue, startingWithArticle: nil, pushVC: false)
        }
    }
    
    func userDidCompleteLogin(info: LoginViewControllerInfo) {
        if info.type == .AIPList {
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
    
    func didLoginForMedia(media: Media, forDownload: Bool) {
        let article = media.article
        
        if article?.userHasAccess == true && forDownload == true {
            showDownloadDialogueForMedia(media: media)
        }
        else if article?.userHasAccess == false {
            //  Show login failed
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
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
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
