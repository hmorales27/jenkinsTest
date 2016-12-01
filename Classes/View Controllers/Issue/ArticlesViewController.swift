/*
 
    Created by Sharkey, Justin (ELS-CON) on 10/17/15.
    Copyright © 2015 Sharkey, Justin (ELS-CON). All rights reserved.
 
*/

import UIKit
import GoogleMobileAds
import Cartography

private let DefaultSectionTitle = "All Articles"

class ArticlesViewController: ArticlesFullListVC, SectionDataViewDelegate, IssueDownloadButtonDelegate, SectionDataCollapseButtonDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    /* Outlets */
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerView: ArticlesHeaderView!
    
    /* Views */
    var downloadButton: UIBarButtonItem?
    
    
    /* Properties */
    
    var shouldShowBackButton = false
    
    var issue: Issue {
        get { return currentIssue! }
        set(issue) { currentIssue = issue }
    }
    
    // MARK: - Initializers -
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.selectedType = SLTableViewItemType.latestIssue
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if shouldShowBackButton {
            enabled = false
        }
        
        /* Analytics */
        analyticsScreenName = Constants.Page.Name.Issue
        analyticsScreenType = Constants.Page.Type.pu_ci

        
        /* Header View */
        headerView.setup(screenType: screenType)
        headerView.issueVC = self
        headerView.showDownloadOrDeleteButton()
        if screenType == .mobile {
            headerView.collapseButton.isHidden = true
        }
        
        constrain(advertisementVC.view, tableView) { (adV, tableV) in
            
            guard let superV = adV.superview else {
                return
            }
            
            adV.top == tableV.bottom
            adV.right == superV.right
            advertisementVC.bottomConstraint = (adV.bottom == superV.bottom)
            adV.left == superV.left
        }
        
        constrain(headerView) { (headerV) in
            guard let superview = headerV.superview else { return }
            headerView.topConstraint = (headerV.top == superview.top)
        }
    }
    
    override func getArticlesFromDatabase() -> [Article] {
        super.getArticlesFromDatabase()
        
        guard let issue = currentIssue else { return [] }
        return DatabaseManager.SharedInstance.getAllArticlesForIssue(issue, key: "sequence")
    }
    
    override func updateDataSource() {
        super.updateDataSource()
        
        performOnMainThread { 
            self.reloadTableView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstLaunch == true {
            updateDataFromBackend()
            firstLaunch = false
        } else {
            reloadTableView()
        }
        
        advertisementVC.setup(AdType.iPadPortrait, journal: currentJournal!)
        setupNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateHeaderView()
    }
    
    // MARK: Load
    
    override func loadAdvertisements() {

        super.loadAdvertisements()
        
        //adView?.loadRequest(request)
    }
    
    override func updateDataFromBackend() {
        
        super.updateDataFromBackend()

        guard NETWORKING_ENABLED else { return }
        ContentKit.SharedInstance.updateArticles(issue: issue) { (success) in
            self.downloadAbstracts()
            self.updateTableViewDataSource()
        }
    }
    
    override func analyticsTagScreen() {
        
        let journal = issue.journal
        
        var contentData: [String: AnyObject] = [:]

        if let issueId = issue.issueId {
            contentData[Constants.Content.ID] = AnalyticsHelper.MainInstance.contentIdInfo(issueId.stringValue) as AnyObject?
        }
        
        if let volume = issue.volume, let issueNo = issue.issueNumber {
            contentData[Constants.Content.BibliographicInfo] = AnalyticsHelper.MainInstance.createBibliographicInfo(volume, issue: issueNo) as AnyObject?
            contentData[AnalyticsConstant.TagJournalInfo] = AnalyticsHelper.MainInstance.createJournalInfo(
                societyname: (journal?.journalTitle!)!,
                speciality: nil,
                section: nil,
                journalISSN: journal?.issn,
                issueNo: issueNo,
                volumeNo: volume
            ).lowercased() as AnyObject?
        }
        contentData[AnalyticsConstant.TagPageType] = Constants.Page.Type.pu_ci as AnyObject?
        AnalyticsHelper.MainInstance.trackState(analyticsScreenName!, stateContentData: contentData)
    }
    
    // MARK: - Setup -
    
    override func setup() {
        super.setup()
        
        setupHeaderView()
        setupTableView()
    }

    
    func setupHeaderView() {
        headerView.downloadButton.delegate = self
        headerView.update(issue, issueVC: self)
//        headerView.update(self.screenType)
        if screenType == .mobile {
            headerView.collapseButton.isHidden = true
        }
    }
    
    func setupTableView() {
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor.clear
        tableView.register(SectionsData.TableHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionsData.View.Identifier)
    }
    
    //  Check what method is calling this when the filter buttons don't show up.
    override func updateHeaderView() {
        super.updateHeaderView()
        
        let items = self.getArticlesFromDatabase()
        var noteCount = 0
        var starredCount = 0
        
        for article in items {
            if article.itemIsBookmarked == true { starredCount += 1 }
            if article.itemHasNotes == true { noteCount += 1 }
        }
        
        performOnMainThread {
            self.headerView.showDownloadOrDeleteButton()
            self.headerView.updateNotesButton(noteCount)
            self.headerView.updateStarredButton(starredCount)
        }
    }

    override func notification_readinglist_showdialogue(_ notification: Foundation.Notification) {
        super.notification_readinglist_showdialogue(notification)
        
        performOnMainThread {
            let alertVC = Alerts.AddToReadingList { (goToReadingList) in
                let bookmarkVC = BookmarksViewController(journal: self.issue.journal)
                self.navigationController?.popToRootViewControllerAndLoadViewController(bookmarkVC)
            }
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Data -
    
    override func downloadAbstracts() {
        super.downloadAbstracts()
        
        guard NETWORKING_ENABLED else { return }
        DMManager.sharedInstance.downloadAbstracts(issue: issue)
    }

    
    override func reloadTableView() {
        super.reloadTableView()
        
        if self.dataSource.activeSections.count == 0 {
            self.headerView.starredButton.setActive(false)
        }
        performOnMainThread({
            self.tableView.reloadData()
        })
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        updateNavigationTitle()
        updateNavigationItemsForScreenType(screenType)
    }
    
    override func updateNavigationItemsForScreenType(_ type: ScreenType) {
        super.updateNavigationItemsForScreenType(type)
        
        DispatchQueue.main.async {
            if self.shouldShowBackButton == true {
                self.navigationItem.leftBarButtonItems = self.backButtons("All Issues", dark: false)
            } else {
                self.navigationItem.leftBarButtonItem = self.menuBarButtonItem
            }
        }
    }
    
    override func collapseAllBarButtonItemClicked(_ sender: UIBarButtonItem) {

        super.collapseAllBarButtonItemClicked(sender)
        
        tableView.reloadData()
    }
    
    
    // MARK: - Layout -
    
    override func updateViewsForScreenChange(_ type: ScreenType) {
        super.updateViewsForScreenChange(type)
        updateNavigationItemsForScreenType(type)
        updateSLTableViewForScreen(type)
    }

    
    // MARK: - Table View -
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        guard NETWORK_AVAILABLE else {
            Alerts.NoNetwork().present(from: self)
            return
        }
        guard let article = dataSource[indexPath.section][indexPath.row].article else {
            return
        }
        
        didSelectArticleFromArticles(article, articles: articlesForPush)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionsData.View.Identifier) as! SectionsData.TableHeaderView!
        sectionView?.view.viewDelegate = self
        let section = dataSource[section]
        if let sectionIndex = section.sectionIndex {
            sectionView?.view.update(section.title, section: sectionIndex, color: section.color, collapsed: section.collapsed)
        }
        return sectionView
    }
    
    func sectionViewDidToggleCollapseForIndex(_ index: Int) {
        dataSource.collapse(atIndex: index)
    }
    
    func sectionViewDidToggleCollapseAll(_ collapse: Bool) {
        if collapse == true {
            dataSource.collapseAll()
        } else {
            dataSource.expandAll()
        }
    }
    
    func sectionDataDidToggleCollapse(_ collapse: Bool) {
        if collapse == true {
            dataSource.collapseAll()
        } else {
            dataSource.expandAll()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let _section = dataSource[section]
        if _section.title == "" {
            return 0
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.CellIdentifier.ArticleTableViewCell) as! ArticleTableViewCell
        let item = dataSource[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        var lastArticle: Article?
        if (indexPath as NSIndexPath).row > 0 {
            lastArticle = dataSource[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row - 1].article
        }
        
        cell.issueVC = self
        cell.delegate = self
        cell.indexPath = indexPath
        
        if let article = item.article {
            cell.update(article, previousArticle: lastArticle)
        }
        
        if item.expandAuthorList == true {
            cell.authorsLabel.numberOfLines = 0
            cell.authorsPlusButton.setTitle("-", for: UIControlState())
            cell.authorsPlusButton.accessibilityLabel = "Collapse Author Name Button"
        } else {
            cell.authorsLabel.numberOfLines = 2
            cell.authorsPlusButton.setTitle("+", for: UIControlState())
            cell.authorsPlusButton.accessibilityLabel = "Expand Author Name Button"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerView.updateOffsetY(scrollView.contentOffset.y)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func toggleAuthorList(indexPath: IndexPath) {
        
        let item = dataSource[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        if item.expandAuthorList == true {
            item.expandAuthorList = false
        } else {
            item.expandAuthorList = true
        }
        performOnMainThread { 
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [indexPath], with: .none)
            self.tableView.endUpdates()
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        guard let article = dataSource[indexPath.section][indexPath.row].article else {
            return
        }
        
        didSelectArticleFromArticles(article, articles: articlesForPush)
    }
    
    //  MARK: Action
    
    func issueDownloadButtonClicked(_ button: UIButton) {
        guard let issue = currentIssue else { return }
        userDidClickDownload(forIssue: issue)
    }
    
    func issueDeletebuttonClicked(_ button: UIButton) {
        
    }
}

// MARK: - Alerts -

extension ArticlesViewController {

    func sectionDataCollapseButtonDidToggle(collapse: Bool) {
        if collapse == true {
            dataSource.collapseAll()
        } else {
            dataSource.expandAll()
        }
    }
}

// MARK: - Collection Data Source Delegate -

extension ArticlesViewController: CollectionDataSourceDelegate {

    func collectionDataSourceAllSectionsCollapsed() {
        
        performOnMainThread {
            self.tableView.reloadData()
            self.updateRightBarButtonItem(true)
        }
    }
    func collectionDataSourceCollapseSection(_ section: CollectionSection, atIndex index: Int) {
        performOnMainThread {
            self.tableView.reloadSections(IndexSet(integer: index), with: .none)
            if self.dataSource.allSectionsCollapsed == true {
                self.updateRightBarButtonItem(true)
            }
        }
    }
    func collectionDataSourceAllSectionsExpanded() {
        performOnMainThread { 
            self.tableView.reloadData()
            self.updateRightBarButtonItem(false)
        }
    }
    func collectionDataSourceExpandSection(_ section: CollectionSection, atIndex index: Int) {
        performOnMainThread {
            self.tableView.reloadSections(IndexSet(integer: index), with: .none)
            if self.dataSource.allSectionsExpanded == true {
                self.updateRightBarButtonItem(false)
            }
        }
    }
    
    func collectionDataSourceNeedsTableViewRefresh() {
        if self.dataSource.count == 0 {
            self.dataSource.showOnlyStarredArticles = false
            self.headerView.starredButton.selected = false
            self.dataSource.showOnlyArticlesWithNotes = false
            self.headerView.noteButton.selected = false
        }
        performOnMainThread {
            self.tableView.reloadData()
        }
    }
    
    func updateRightBarButtonItem(_ collapsed: Bool) {
        if screenType == .mobile {
            guard let rightItem = navigationItem.rightBarButtonItem else { return }
            rightItem.title = collapsed ? EXPAND_ALL : COLLAPSE_ALL
        } else {
            headerView.collapseButton.updateState(collapsed: collapsed)
        }
    }
}

private let EXPAND_ALL = "Expand All"
private let COLLAPSE_ALL = "Collapse All"
//
//// MARK: - Collection Section View Delegate -
//
//extension ArticlesViewController: CollectionSectionViewDelegate {
//    
//    func sectionViewDidCollapseAll() {
//        dataSource.collapseAll()
//    }
//    func sectionViewDidExpandAll() {
//        dataSource.expandAll()
//    }
//    func sectionViewDidCollapseAtIndex(_ index: Int) {
//        dataSource.collapse(atIndex: index)
//    }
//    func sectionViewDidExpandAtIndex(_ index: Int) {
//        dataSource.expand(atIndex: index)
//    }
//}

//extension ArticlesViewController : ArticleTableViewCellDelegate {
//    
//    func showCannotDeleteArticle() {
//        let alert = Alerts.cannotDelete()
//        
//        performOnMainThread { 
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//}
