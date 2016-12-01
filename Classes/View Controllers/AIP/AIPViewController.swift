//
//  AIPViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/20/15.
//  Copyright © 2015 Sharkey, Justin (ELS-CON). All rights reserved.
//

import UIKit
import GoogleMobileAds
import Cartography

class AIPVC: SLViewController, AIPHeaderDelegate, GADBannerViewDelegate {
    
    // MARK: VIEW CONTROLLERS
    
    let headerVC = AIPHeaderViewController()
    let tableVC = AIPTableViewController()
    
    let advertisementVC = AdvertisementViewController()
    
    let activityView = UIActivityIndicatorView()
    
    var editingMode = false
    
    // MARK: - Initializer -
    
    override init(journal: Journal) {
        super.init(journal: journal)
        self.selectedType = SLTableViewItemType.articlesInPress
        
        addChildViewController(advertisementVC)
        advertisementVC.didMove(toParentViewController: self)
        
        addChildViewController(headerVC)
        headerVC.didMove(toParentViewController: self)
        headerVC.delegate = self
        
        addChildViewController(tableVC)
        tableVC.didMove(toParentViewController: self)
        tableVC.delegate = self
        
        activityView.activityIndicatorViewStyle = .gray
        activityView.startAnimating()
        activityView.hidesWhenStopped = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        analyticsScreenName = Constants.Page.Name.AIP
        analyticsScreenType = Constants.Page.Type.np_gp
        setup()
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let journal = currentJournal else { return }
        advertisementVC.setup(AdType.iPadPortrait, journal: journal)
        headerVC.update(journal: journal)
        updateAIPs()
        setupNotifications()
    }
    
    // MARK: - Setup -
    
    func setup() {
        if NETWORK_AVAILABLE == false {
            
            let alertVC = Alerts.NoNetwork()
            performOnMainThread({
                self.present(alertVC, animated: true, completion: nil)
            })
        }
        setupSubviews()
        setupAutoLayout()
        
        
        tableVC.tableView.separatorColor = UIColor.clear
        
        headerVC.aipVC = self
    }
    
    func setupSubviews() {
        view.addSubview(headerVC.view)
        view.addSubview(tableVC.view)
        view.addSubview(advertisementVC.view)
        tableVC.tableView.addSubview(activityView)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            headerVC.view!,
            tableVC.view!,
            advertisementVC.view!,
            activityView
        ]
        
        constrain(subviews) { (views) in
            
            let headerV = views[0]
            let tableV  = views[1]
            let adV     = views[2]
            let activityV = views[3]
            
            guard let superview = headerV.superview else {
                return
            }
            
            headerV.top   == superview.top
            headerV.right == superview.right
            headerV.left  == superview.left
            
            tableV.top    == headerV.bottom
            tableV.right  == superview.right
            tableV.left   == superview.left
            
            activityV.centerX == tableV.centerX
            activityV.centerY == tableV.centerY
            
            //adV.centerX == adBackgroundV.centerX
            adV.top == tableV.bottom
            adV.right == superview.right
            adV.left == superview.left
            advertisementVC.bottomConstraint = (adV.bottom == superview.bottom)
        }
    }
    
    override func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(notification_readinglist_showdialogue(_:)), name: NSNotification.Name.ShowReadingListDialogue, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_readinglist_removedialogue(_:)), name: NSNotification.Name.HideReadingListDialogue, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_aip_completed(_:)), name: NSNotification.Name(rawValue: Notification.Download.AIP.Completed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_aip_started(_:)), name: NSNotification.Name(rawValue: Notification.Download.AIP.Started), object: nil)
    }
    
    // MARK: - Data -
    
    func updateAIPs() {
        guard let journal = currentJournal else {
            return
        }
        updateTableViewData()
        if InternetHelper.sharedInstance.available == true {
            ContentKit.SharedInstance.updateAIPs(journal: journal, completion: { (success) in
                guard success else {
                    return
                }
                self.updateTableViewData()
            })
        } else {
            activityView.stopAnimating()
            if tableVC.allAIPs.count == 0 {
                performOnMainThread({
                    let alertVC = Alerts.NoNetwork()
                    self.present(alertVC, animated: true, completion: nil)
                })
            }
        }
    }
    
    func updateTableViewData() {
        guard let journal = currentJournal else {
            return
        }

        
        let articles = DatabaseManager.SharedInstance.getAips(journal: journal)
        
        if articles.count > 0 {
            activityView.stopAnimating()
        } else {
            activityView.startAnimating()
        }
        tableVC.updateDataSource(articles: articles)
        DMManager.sharedInstance.downloadAIPAbstracts(journal: journal)
        performOnMainThread({
            self.headerVC.update(journal: journal)
            self.tableVC.tableView.reloadData()
        })
    }
    
    // MARK: - Layout -
    
    override func updateViewsForScreenChange(_ type: ScreenType) {
        super.updateViewsForScreenChange(type)
        updateNavigationItemsForScreenType(type: type)
        updateSLTableViewForScreen(type)
    }
    
    override func setupNavigationBar() {
        //super.setupNavigationBar()
        updateNavigationTitle()
        updateNavigationItemsForScreenType(type: screenType)
    }
    
    override func newUpdateNavigationBar() {
        updateNavigationTitle()
        updateNavigationItemsForScreenType(type: screenType)
    }
    
    override func updateNavigationTitle() {
        if editingMode == false {
            switch screenType {
            case .mobile:
                navigationItem.title = currentJournal?.journalTitleIPhone
            case .tablet:
                navigationItem.title = currentJournal?.journalTitle
            }
            
        } else {
            navigationItem.title = "Download Articles"
        }
    }
    
    private var rightItemsCount = 0
    private var leftItemsCount = 0
    
    //  See when this is called for AIP downloads on iPad
    func updateNavigationItemsForScreenType(type: ScreenType) {
        
        var leftButtons: [UIBarButtonItem]?
        var rightButtons: [UIBarButtonItem]?
        
        if self.editingMode == false {
            if leftItemsCount == 0 {
                leftButtons = [menuBarButtonItem]
                leftItemsCount = 1
            }
            
            switch type {
            case .mobile:
                if navigationItem.rightBarButtonItems?.count != 0 {
                    rightButtons = []
                }
            case .tablet:
                
                let newButtons = rightBarButtonItems
                if rightItemsCount != newButtons.count {
                    rightButtons = newButtons
                    rightItemsCount = newButtons.count
                }
                if self.navigationItem.rightBarButtonItems?.count == 5 {
                    if rightItemsCount == 5 {
                        performOnMainThread({
                            self.navigationItem.rightBarButtonItems?.remove(at: 4)
                            let downloadButton = self.getDownloadBarButtonItem()
                            self.navigationItem.rightBarButtonItems?.append(downloadButton)
                            
                        })
                    }
                }
            }
        } else {
            if leftItemsCount == 1 {
                leftButtons = []
                leftItemsCount = 0
            }
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelEditingButtonClicked(_:)))
            rightButtons = [cancelButton]
            rightItemsCount = 1
        }
        
        performOnMainThread({
            if let _left = leftButtons {
                self.navigationItem.setLeftBarButtonItems(_left, animated: true)
            }
            if let _right = rightButtons {
                self.navigationItem.setRightBarButtonItems(_right, animated: true)
            }
        })
    }
    
    func cancelEditingButtonClicked(_ sender: UIBarButtonItem) {
        headerVC.updateForEditing(editing: false)
        setupForEditing(false)
    }
    
    // MARK: - Notifications -
    
    func notification_readinglist_showdialogue(_ notification: Foundation.Notification) {
        guard let journal = currentJournal else {
            return
        }

        let alertVC = Alerts.AddToReadingList { (goToReadingList) in
            let bookmarkVC = BookmarksViewController(journal: journal)
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
    
    func notification_download_aip_completed(_ notification: Foundation.Notification) {
        guard let journal = currentJournal else { return }
        performOnMainThread { 
            self.headerVC.update(journal: journal)
        }
    }
    
    func notification_download_aip_started(_ notification: Foundation.Notification) {
        
        guard let journal = currentJournal else {
            return
        }
        performOnMainThread {
            self.headerVC.update(journal: journal)
            
            self.slTableViewReloadSection(0)
        }
    }
    
    func aipHeaderDidClickDownloadMultipleArticles() {
        setupForEditing(true)
    }
    
    func setupForEditing(_ editing: Bool) {
        if editing == true {
            self.tableVC.tableView.allowsMultipleSelectionDuringEditing = true
            self.tableVC.setEditing(true, animated: true)
            self.tableVC.tableView.reloadData()
            editingMode = true
            setupNavigationBar()
            
        } else {
            self.tableVC.tableView.allowsMultipleSelectionDuringEditing = false
            self.tableVC.setEditing(false, animated: false)
            self.tableVC.tableView.reloadData()
            editingMode = false
            setupNavigationBar()
        }
    }
    
    func aipHeaderEditDeselectAll() {
        tableVC.tableView.reloadData()
    }
    
    func aipHeaderSelectFirstArticles(_ count: Int) {
        // Update Table View With Selected
    }
    
    func aipHeaderDownloadSelected(_ indexPaths: [IndexPath]) {
        var articles: [Article] = []
        for indexPath in indexPaths {
            if let article = tableVC.itemForIndexPath(indexPath) {
                articles.append(article)
            }
        }
        downloadArticles(articles)
    }
    
    func aipHeaderSelectAllShouldHide(_ selectedCount: Int) -> Bool {
        return tableVC.allAIPs.count == selectedCount ? true : false
    }
    
    func aipHeaderDownloadArticles(_ articles: [Article]) {
        userDidSelectAIPArticles(articles)
    }
    
    func downloadArticles(_ articles: [Article]) {
        headerVC.updateForEditing(editing: false)
        setupForEditing(false)
        userDidSelectAIPArticles(articles)
    }
}

extension AIPVC: AIPTableViewDelegate {
    
    internal func aipTableViewDidUpdateEditedSelection(_ indexPath: [NSIndexPath]) {
        headerVC.updateEditLabels(indexPath as [NSIndexPath])
    }
    
    func aipTableViewDidSelectArticle(article: Article, push: Bool) {
        guard NETWORK_AVAILABLE || article.downloadInfo.fullTextDownloadStatus == .downloaded else {
            Alerts.NoNetwork().present(from: self)
            return
        }
        
        if push == true {
            didSelectArticleFromArticles(article, articles: articlesForPush)
        } else {
            userDidClickDownloadButtonForAIPArticle(article)
        }
    }
    
    func aipTableViewArticleWasDeleted() {
        guard let journal = currentJournal else { return }
        
        headerVC.updateAIPCountLabel(journal)
    }
}
