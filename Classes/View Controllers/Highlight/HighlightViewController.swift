/*
    HighlightVC
 */

import UIKit
import SafariServices
import Cartography

public class HighlightViewController: SLViewController, HighlightSectionViewDelegate, HighlightHeaderViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties -
    
    let headerView = HighlightHeaderView()
    let brandImageView = JournalBrandImageView()
    let sectionView = HighlightSectionView()
    
    let tableViewContainer = JBSMView()
    let tableView = UITableView()
    
    var topArticlesVC: TopArticlesTableVC?
    let advertisementVC = AdvertisementViewController()
    
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

    public var tableViewData: [Article] = []
    var authorCollapsed: [Bool] = []
    var shouldUseNewUi = USE_NEW_UI

    
    override var screenTitle: String {
        get {
            return screenTitleJournal
        }
    }
    
    // MARK: - Overrides -
    
    // MARK: - Initializers -
    
    public override init(journal: Journal) {
        
        super.init(journal: journal)
        
        addChildViewController(advertisementVC)
        advertisementVC.didMove(toParentViewController: self)
        
        if let authentication = journal.authentication {
            AnalyticsHelper.MainInstance.updateLoginInDefaultConfiguration("login", uniqueUserId: String(NSString(string: authentication.userId!).aes256Encrypt(withKey: Strings.EncryptionKey)))
        }
        
        self.selectedType = SLTableViewItemType.highlight
        
        guard let issue = journal.firstIssue else { return }
        
        currentIssue = issue
        
        topArticlesVC = TopArticlesTableVC.init(journal: journal)
        topArticlesVC?.delegate = self
        
        if let _topArticlesVC = topArticlesVC {
            addChildViewController(_topArticlesVC)
            _topArticlesVC.didMove(toParentViewController: self)
        }
        
        var bundleConfig: [String: Any] = [:]
        bundleConfig[AnalyticsConstant.TagJournalInfo] = AnalyticsHelper.MainInstance.createJournalInfo(
            societyname: journal.journalTitle!,
            speciality: nil,
            section: nil,
            journalISSN: journal.issn,
            issueNo: issue.issueNumber,
            volumeNo: issue.volume
            ).lowercased()
        AnalyticsHelper.MainInstance.updateDefaultConfiguration(bundleConfig)
 
        var stateContentData: [String: Any] = [:]
        stateContentData[AnalyticsConstant.TagPageType] = Constants.Page.Type.np_gp
        AnalyticsHelper.MainInstance.trackState(Constants.Page.Name.Preview, stateContentData: stateContentData)

//        if ScreenshotStrings.RunningSnapshots {
//            DMManager.sharedInstance.downloadIssue(issue, withSupplement: false, startingWith: nil)
//        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle -
    
    override public func viewDidLoad() {
        setup()
        super.viewDidLoad()
        
        view.backgroundColor = Config.Colors.SingleJournalBackgroundColor
        tableView.separatorColor = shouldUseNewUi ? Config.Colors.SingleJournalBackgroundColor : UIColor.clear
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let journal = currentJournal else { return }

        ContentKit.SharedInstance.updateTopArticles(journal: journal, completion: { (success) in

            guard success == true else { return }
            performOnMainThread({
                self.updateSLTableViewForScreen(self.screenType)
            })
        })
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        update()
        
        guard let journal = currentJournal else { return }
        if journal.publisher.allJournals.count == 1 {
            switch DatabaseManager.SharedInstance.checkForMemoryWarning() {
            case .fiveGB:
                let alertVC = UIAlertController(title: "Over 5 GB of journal content has been downloaded and is being stored on your device.", message: "You can manage your usage by deleting content you no longer need within the setting -> Usage menu.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alertVC, animated: true, completion: nil)
            case .oneGB:
                let alertVC = UIAlertController(title: "Over 1 GB of journal content has been downloaded and is being stored on your device.", message: "You can manage your usage by deleting content you no longer need within the setting -> Usage menu.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alertVC, animated: true, completion: nil)
            default:
                break
            }
        }
    }
    
    // MARK: - Setup -
    
    func setup() {
        
        if NETWORK_AVAILABLE == false {
            let alertVC = Alerts.NoNetwork()
            performOnMainThread({
                self.present(alertVC, animated: true, completion: nil)
            })
        }
        
        activityView.hidesWhenStopped = true
        activityView.startAnimating()
        
        guard let journal = currentJournal else { return  }
        ContentKit.SharedInstance.updateCSSForJournal(journal)
        
        advertisementVC.setup(.iPadPortrait, journal: currentJournal!)
        headerView.setup(screenType: screenType)
        setupSubviews()
        setupAutoLayout()
        setupHeaderView()
        
        setupNavigationBar()
        setupBrandImageView()
        setupSectionView()
        setupTableView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notification_readinglist_showdialogue(_:)), name: NSNotification.Name.ShowReadingListDialogue, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notification_readinglist_removedialogue(_:)), name: NSNotification.Name.HideReadingListDialogue, object: nil)
        
        if let issue = journal.firstIssue {
            headerView.update(issue: issue)
        }
        
        performOnMainThread {
            self.sectionView.gradientLayer.frame = self.sectionView.frame
            
            self.tableViewContainer.layer.masksToBounds = true

            self.topArticlesVC?.view!.isHidden = true
            
            self.tableViewContainer.backgroundColor = UIColor.clear
        }
    }

    func setupSubviews() {
        view.addSubview(brandImageView)
        view.addSubview(headerView)
        
        view.addSubview(tableViewContainer)
        tableViewContainer.addSubview(tableView)
        
        if let topArticlesView = topArticlesVC?.view {
            tableViewContainer.addSubview(topArticlesView)
        }

        view.addSubview(activityView)
        view.addSubview(sectionView)
        view.addSubview(advertisementVC.view)
    }
    
    func setupAutoLayout() {
        
        var subviews = [
            headerView,
            brandImageView,
            tableView,
            sectionView,
            advertisementVC.view!,
            activityView,
            tableViewContainer
        ]
        
        if let _topArticlesVC = topArticlesVC {
            
            subviews.append(_topArticlesVC.view!)
        }
        
        constrain(subviews) { (views) in
            
            let headerV = views[0]
            let brandIV = views[1]
            let tableV = views[2]
            let separatorV = views[3]
            let adV = views[4]
            let activityV = views[5]
            let contain = views[6]
            let topArtV = views[7]
            
            guard let superview = headerV.superview else {
                return
            }
            
            brandIV.top == superview.top
            brandIV.right == superview.right
            brandIV.left == superview.left
            
            headerV.top == brandIV.bottom
            headerV.right == superview.right
            headerV.left == superview.left
            
            separatorV.top == headerV.bottom
            separatorV.right == superview.right
            separatorV.left == superview.left

            tableV.top == separatorV.bottom
            
            if shouldUseNewUi {
                separatorV.height == 80
                
                tableV.left == superview.left + Config.Padding.Default
                tableV.right == superview.right - Config.Padding.Default

            } else {
                separatorV.height == 44
                
                tableV.left == superview.left
                tableV.right == superview.right
            }
            
            contain.left == superview.left
            contain.right == superview.right
            contain.top == separatorV.bottom
            contain.bottom == tableV.bottom
            
            topArtV.left == contain.left + Config.Padding.Default
            topArtV.right == contain.right - Config.Padding.Default
            topArtV.top == contain.top
            topArtV.bottom == contain.bottom
            
            activityV.centerY == tableV.centerY
            activityV.centerX == tableV.centerX
            
            adV.top == tableV.bottom
            adV.right == superview.right
            advertisementVC.bottomConstraint = (adV.bottom == superview.bottom)
            adV.left == superview.left
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        updateNavigationTitle()
        updateNavigationItemsForScreenType(type: screenType)
    }
    
    func updateNavigationItemsForScreenType(type: ScreenType) {
        performOnMainThread {
            self.navigationItem.leftBarButtonItem = self.menuBarButtonItem
            switch type {
            case .mobile:
                self.navigationItem.rightBarButtonItems = nil
            case .tablet:
                self.navigationItem.rightBarButtonItems = self.rightBarButtonItems
            }
        }
    }
    
    func setupBrandImageView() {
        guard let journal = currentJournal else {
            return
        }
        if screenType != .mobile {
            brandImageView.update(journal)
        }
    }
    
    func setupHeaderView() {
        headerView.delegate = self
    }
    
    func setupSectionView() {
        sectionView.delegate = self
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
        tableView.register(HighlightTableViewCell.self, forCellReuseIdentifier: HighlightTableViewCell.CellIdentifier)
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.Identifier)
        tableView.estimatedRowHeight = 66.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if shouldUseNewUi {
            tableView.backgroundColor = UIColor.groupTableViewBackground
            tableView.showsVerticalScrollIndicator = false
            
            tableView.layer.masksToBounds = false
        }
    }
    
    // MARK: - Update -
    
    override func updateViewsForScreenChange(_ type: ScreenType) {
        super.updateViewsForScreenChange(type)
        updateNavigationItemsForScreenType(type: type)
        updateSLTableViewForScreen(type)
    }
    
    func update() {
        
        var displayType: HighlightDisplayType?
        
        let latestLabel = sectionView.latestIssueLabel
        let topArticleLabel = sectionView.topArticleLabel
        
        let labels = [latestLabel, topArticleLabel]
        
        for label in labels {
            if label.selected {
                
                displayType = label == latestLabel ? .LatestIssue :
                              label == topArticleLabel ? .TopArticles : nil
            }
        }
        
        guard let _displayType = displayType else { return }
        
        if displayType == .LatestIssue {
            
            performOnMainThread {
                self.topArticlesVC?.view.isHidden = true
                self.tableView.isHidden = false
            }
            
        } else if displayType == .TopArticles {
            
            performOnMainThread {
                self.tableView.isHidden = true
                self.topArticlesVC?.view.isHidden = false
            }
        }
        
        updateTableviewData(displayType: _displayType)
    }
    
    private func updateTableviewData(displayType: HighlightDisplayType) {
        
        if displayType == .TopArticles {
            topArticlesVC?.loadTableViewData()
        }
        
        guard let issue = currentJournal?.firstIssue else { return }
        
        
        if NETWORK_AVAILABLE == true {
            
            if tableViewData.count > 0 {
                activityView.stopAnimating()
            }
            
            guard NETWORKING_ENABLED else { return }
                
                if displayType == .LatestIssue {
                    
                    ContentKit.SharedInstance.updateArticles(issue: issue, completion: { (success) in
                        guard success == true else { return }
                        performOnMainThread({
                            self.loadTableViewData(issue: issue)
                        })
                    })
                } else if displayType == .TopArticles {
                    
                    performOnMainThread({
                        self.topArticlesVC?.loadTableViewData()
                    })
                }
        } else {
            activityView.stopAnimating()
            
            guard let _topVC = topArticlesVC else { return }
            
            if tableViewData.count == 0 || _topVC.tableViewData.count == 0 {
                
                let alertVC = Alerts.NoNetwork()
                performOnMainThread({
                    self.present(alertVC, animated: true, completion: nil)
                })
            }
        }
    }
    
    func updateAbstracts() {
        guard NETWORKING_ENABLED else { return }
        guard let issue = currentJournal?.firstIssue else { return }
        DMManager.sharedInstance.downloadAbstracts(issue: issue)
    }
    
    func toggleAuthorList(indexPath: IndexPath) {
        for _ in authorCollapsed.count..<(tableViewData.count + 1){
            authorCollapsed.append(true)
        }
        authorCollapsed[(indexPath as NSIndexPath).row] = !authorCollapsed[(indexPath as NSIndexPath).row]
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    // MARK: - Load -
    
    public func loadTableViewData(issue: Issue) {
        
        let response = DatabaseManager.SharedInstance.getFeaturedArticlesForIssue(issue)
        
        if response.count == 0 {
            tableView.isHidden = true
        } else {
            activityView.stopAnimating()

            if tableViewData != response {
                tableViewData = response
            }

            tableView.reloadData()
        }
        updateAbstracts()
    }
    
    public func loadTableViewData(topArticles: [Article]) {
        
        if topArticles.count == 0 {
            tableView.isHidden = true
        } else {
            activityView.stopAnimating()
            if tableViewData != topArticles {
                
                tableViewData = topArticles
            }
            tableView.reloadData()
        }
        
        //  ***TODO: Call appropriate updateAbstracts() implementation to handle topArticles abstracts.
    }
    
    
    func pushArticle(article: Article) {
        let articlePC = ArticlePagerController(article: article, articleArray: tableViewData)
        articlePC.backTitleString = "Latest Issue"
        navigationController?.pushViewController(articlePC, animated: true)
    }
    
    // MARK: - Header View Delegate -
    
    func headerViewLinkWasClicked(_ url: URL) {
        loadAndPresentURL(url: url)
    }
    
    // MARK: - Section View Delegate -
    
    func highlightSectionViewDidSelectViewAll() {
        slTableViewNavigateWithType(.latestIssue)
    }
    
    func displayTypeWasSelected(displayType: HighlightDisplayType) {
                
        if displayType == .LatestIssue {
            
            performOnMainThread {
                self.topArticlesVC?.view.isHidden = true
                self.tableView.isHidden = false
            }
        
        } else if displayType == .TopArticles {
            
            performOnMainThread {
                self.tableView.isHidden = true
                self.topArticlesVC?.view.isHidden = false
            }
        }
        
        updateTableviewData(displayType: displayType)
    }
    
    // MARK: - Table View Delegate -
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        while authorCollapsed.count < tableViewData.count {
            authorCollapsed.append(true)
        }
        
        let index = shouldUseNewUi ? indexPath.section : indexPath.row
        
        if index < tableViewData.count {
            let article = articleForIndexPath(indexPath: indexPath)
            let _cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.Identifier) as! ArticleTableViewCell
            
            _cell.update(article)
            _cell.subTypeView.isHidden = true
            _cell.subTypeView.layoutConstraints.height?.constant = 0
            _cell.highlightVC = self
            _cell.indexPath = indexPath
            if !authorCollapsed[(indexPath as NSIndexPath).row] {
                _cell.authorsLabel.numberOfLines = 0
                _cell.authorsPlusButton.setTitle("-", for: UIControlState())
                _cell.authorsPlusButton.accessibilityLabel = "Collapse Author Name Button"
            }
            else {
                _cell.authorsLabel.numberOfLines = 2
                _cell.authorsPlusButton.setTitle("+", for: UIControlState())
                _cell.authorsPlusButton.accessibilityLabel = "Expand Author Name Button"
            }
            
            print("_cell == \(_cell)")
            
            return _cell
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Continue..."
            cell.textLabel?.accessibilityLabel = "Continue button"
            cell.textLabel?.textAlignment = NSTextAlignment.center
            
            cell.contentView.backgroundColor = shouldUseNewUi ? view.backgroundColor : UIColor.white
            
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if shouldUseNewUi {
           return 1
            
        } else {
           return tableViewData.count + 1
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let index = shouldUseNewUi ? indexPath.section : indexPath.row
        
        guard index < tableViewData.count else {
            highlightSectionViewDidSelectViewAll()
            return
        }
        
        let article = articleForIndexPath(indexPath: indexPath)
        
        didSelectArticleFromArticles(article, articles: articlesForPush)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        if shouldUseNewUi {
            return tableViewData.count + 1
        
        } else {
            return 1
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if shouldUseNewUi {
            return 5
            
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    func notification_readinglist_showdialogue(_ notification: Foundation.Notification) {
        let alertVC = Alerts.AddToReadingList { (goToReadingList) in
            guard let journal = self.currentJournal else { return }
            let bookmarkVC = BookmarksViewController(journal: journal)
            performOnMainThread({
                self.navigationController?.popToRootViewControllerAndLoadViewController(bookmarkVC)
            })
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
    
    func articleForIndexPath(indexPath: IndexPath) -> Article {
        
        return shouldUseNewUi ? tableViewData[indexPath.section] : tableViewData[indexPath.row]
    }
    
    override var articlesForPush: [Article]? {
        guard let issue = currentJournal?.firstIssue else { return nil }
        return DatabaseManager.SharedInstance.getFeaturedArticlesForIssue(issue)
    }
}


extension HighlightViewController: TopArticleTableVcDelegate {
    
    func didSelectArticleAt(indexPath: IndexPath) {
        //  TODO: Setup and present top Article in pager, in sequence with other top articles.
        
        guard let article = topArticlesVC?.articleForIndexPath(indexPath: indexPath),
            let topArticles = topArticlesVC?.tableViewData else { return }
        
        
        didSelectArticleFromArticles(article, articles: topArticles)
    }
    
    func didSelectViewAllTopArticles() {
        slTableViewNavigateWithType(.topArticles)
    }
}


