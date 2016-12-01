//
//  ArticlesFullListVC.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 11/7/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import GoogleMobileAds


//  Need header, potentially some logic for table view, general event-handling code.

class ArticlesFullListVC: SLViewController {
    
    var firstLaunch = true
    
//    weak var headerView: ArticlesHeaderView!

    weak var activityView: UIActivityIndicatorView?
    
    let advertisementVC = AdvertisementViewController()

    /* Views */
    var collapseButton: UIBarButtonItem?

    /* Data Source */
    var dataSource: CollectionDataSource!
    
    
    // MARK: - Initializers -
    
    override init(journal: Journal) {
        super.init(journal: journal)
        self.currentJournal = journal
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /* Setup */
        setup()
        
        /* Loading */
        loadAdvertisements()
        
        /* Data Source */
        
        setupDataSource()
        if dataSource.count == 0 {
            activityView?.startAnimating()
        } else {
            activityView?.isHidden = true
            activityView?.stopAnimating()
        }
        
        addChildViewController(advertisementVC)
        advertisementVC.didMove(toParentViewController: self)
        view.addSubview(advertisementVC.view)
        advertisementVC.view.translatesAutoresizingMaskIntoConstraints = false        
    }

    
    @discardableResult func getArticlesFromDatabase() -> [Article] {

        return []
    }
    
    
    //  MARK: - Data source -
    
    func setupDataSource() {
        dataSource = CollectionDataSource(items: getArticlesFromDatabase())
//        dataSource.dataSourceDelegate = self
    }
    
    
    func updateDataSource() {
        let articles = getArticlesFromDatabase()
        if articles.count > 0 && activityView != nil {
            activityView?.stopAnimating()
        }
        dataSource.update(items: articles)
        performOnMainThread {
//            self.reloadTableView()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstLaunch == true {
            updateDataFromBackend()
            firstLaunch = false
        } else {
//            reloadTableView()
        }
        
        advertisementVC.setup(AdType.iPadPortrait, journal: currentJournal!)
        setupNotifications()
    }
    
    
    // MARK: Load
    
    func loadAdvertisements() {
        let request = GADRequest()
        if Strings.IsTestAds { request.testDevices = [kGADSimulatorID] }
        //adView?.loadRequest(request)
    }
    
    func updateDataFromBackend() {}
    
    
    // MARK: - Setup -
    
    func setup() {
        if NETWORK_AVAILABLE == false {
            
            let alertVC = Alerts.NoNetwork()
            performOnMainThread({
                self.present(alertVC, animated: true, completion: nil)
            })
        }
        setupView()
//        setupTableView()
        setupNavigationBar()
        updateActivityView(status: .load)
    }
    
    func setupView() {
        view.backgroundColor = UIColor.white
    }
    
    func updateActivityView(status: ViewDisplayStatus) {
        switch status {
        case .load:
            activityView?.isHidden = true
            activityView?.hidesWhenStopped = true
        case .show:
            activityView?.isHidden = false
            activityView?.startAnimating()
        case .hide:
            activityView?.stopAnimating()
        default:
            break
        }
    }
    
    func setupTableViewData() {
        updateTableViewDataSource()
        if dataSource.allItems.count > 0 {
            updateActivityView(status: .show)
        } else {
            updateActivityView(status: .hide)
        }
    }
    

    func updateHeaderView() {}
    
    override func setupNotifications() {
        super.setupNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(notification_readinglist_showdialogue(_:)), name: NSNotification.Name.ShowReadingListDialogue, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_readinglist_removedialogue(_:)), name: NSNotification.Name.HideReadingListDialogue, object: nil)
    }
    
    func notification_readinglist_showdialogue(_ notification: Foundation.Notification) {
        
        performOnMainThread {
            let alertVC = Alerts.AddToReadingList { (goToReadingList) in
//                let bookmarkVC = BookmarksViewController(journal: self.issue.journal)
//                self.navigationController?.popToRootViewControllerAndLoadViewController(bookmarkVC)
            }
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func notification_readinglist_removedialogue(_ notification: Foundation.Notification) {
        
        let alert = Alerts.RemovedFromReadingList()
        performOnMainThread {
            
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Data -
    
    func downloadAbstracts() {
        guard NETWORKING_ENABLED else { return }
//        DMManager.sharedInstance.downloadAbstracts(issue: issue)
    }
    
    func updateTableViewDataSource() {
        let articles = getArticlesFromDatabase()
        if articles.count == 0 {
            if dataSource.count > 0 {
                log.error("Something Went Wrong. There are no articles in the Database but the CollectionDataSource has sections.")
            }
            return
        }
        updateDataSource()
        updateHeaderView()
    }
    
    func reloadTableView() {
        if self.dataSource.activeSections.count == 0 {
//            self.headerView.starredButton.setActive(false)
            self.dataSource.showOnlyStarredArticles = false
            self.dataSource.showOnlyArticlesWithNotes = false
        }
        performOnMainThread({
//            self.tableView.reloadData()
        })
    }

    // MARK: - Other -
    
    func articleForIndexPath(_ indexPath: IndexPath) -> Article? {
        guard let article = dataSource[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].article else { return nil }
        return article
    }
    
    // MARK: - Notifications -
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        updateNavigationTitle()
        updateNavigationItemsForScreenType(screenType)
    }
    
    override func updateNavigationTitle() {
        guard let journal = currentJournal else { return }
        
        switch screenType {
        case .mobile:
            navigationItem.title = journal.journalTitleIPhone
        case .tablet:
            navigationItem.title = journal.journalTitle
        }
        navigationItem.accessibilityTraits = UIAccessibilityTraitNone
    }

    
    func updateNavigationItemsForScreenType(_ type: ScreenType) {
        DispatchQueue.main.async {
//            if self.shouldShowBackButton == true {
//                self.navigationItem.leftBarButtonItems = self.backButtons("All Issues", dark: false)
//            } else {
                self.navigationItem.leftBarButtonItem = self.menuBarButtonItem
//            }
            switch type {
            case .mobile:
                if self is ArticlesViewController {
                    let collapseBBI = UIBarButtonItem(title: "Collapse All", style: .plain, target: self, action: #selector(self.collapseAllBarButtonItemClicked(_:)))
                    collapseBBI.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: .Medium)], for: .normal)
                    self.navigationItem.rightBarButtonItem = collapseBBI
                }
            case .tablet:
                self.navigationItem.rightBarButtonItems = self.rightBarButtonItems
            }
        }
    }
    
    
    func collapseAllBarButtonItemClicked(_ sender: UIBarButtonItem) {
        if sender.title == "Collapse All" {
            dataSource.collapseAll()
            sender.title = "Expand All"
        } else {
            dataSource.expandAll()
            sender.title = "Collapse All"
        }
//        tableView.reloadData()
    }
    
    // MARK: - Layout -
    
    override func updateViewsForScreenChange(_ type: ScreenType) {
        super.updateViewsForScreenChange(type)
        updateNavigationItemsForScreenType(type)
        updateSLTableViewForScreen(type)
    }

    
    // MARK: - Advertisements -
    
    func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        log.warning("Failed To Recieve Ad: \(error.localizedDescription)")
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        log.info("Publication View Controller - Did Recieve Ad")
    }
}



private let EXPAND_ALL = "Expand All"
private let COLLAPSE_ALL = "Collapse All"

// MARK: - Collection Section View Delegate -

extension ArticlesViewController: CollectionSectionViewDelegate {
    
    func sectionViewDidCollapseAll() {
        dataSource.collapseAll()
    }
    func sectionViewDidExpandAll() {
        dataSource.expandAll()
    }
    func sectionViewDidCollapseAtIndex(_ index: Int) {
        dataSource.collapse(atIndex: index)
    }
    func sectionViewDidExpandAtIndex(_ index: Int) {
        dataSource.expand(atIndex: index)
    }
}

extension ArticlesViewController : ArticleTableViewCellDelegate {
    
    func showCannotDeleteArticle() {
        let alert = Alerts.cannotDelete()
        
        performOnMainThread {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

