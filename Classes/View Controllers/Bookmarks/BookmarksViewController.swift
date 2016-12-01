//
//  BookmarksViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/5/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography
import GoogleMobileAds
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


private let CellIdentifier = "ArticleTableViewCell"

class BookmarksViewController: SLViewController, UITableViewDelegate, UITableViewDataSource {
    
    let headlineView = HeadlineView()
    let tableView = UITableView()
    var editButton = EditButton()
    
    let ipadCancelButton = JBSMButton()
    let iPadDeleteButton = JBSMButton()
    
    var editBarButton = EditBarButton()
    let cancelBarButton = CancelBarButton()
    
    let headlineEditView = HeadlineEditView()
    
    let advertisementVC = AdvertisementViewController()
    
    var selectedIndexPaths: [IndexPath]?
    var tableViewData: [Article] = []
    var authorExpandedIndexPaths: [IndexPath] = []
    
    var constraintGroup = ConstraintGroup()
    var firstRun: Bool = true
    
    var bookmarkedArticles: [Article] {
        guard let journal = currentJournal else { return [] }
        return DatabaseManager.SharedInstance.getAllBookmarksForJournal(journal)
    }
    
    // MARK: - Initializers -
    
    override init() {
        super.init()
        
        addChildViewController(advertisementVC)
        advertisementVC.didMove(toParentViewController: self)
    }
    
    override init(journal: Journal) {
        super.init(journal: journal)
        self.selectedType = SLTableViewItemType.readingList
        
        addChildViewController(advertisementVC)
        advertisementVC.didMove(toParentViewController: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        setup()
        advertisementVC.setup(AdType.iPadPortrait, journal: currentJournal!)
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTableView()
        sendAnalytics()
    }
    
    func sendAnalytics() {
        var contentData: [AnyHashable: Any] = [:]
        contentData[AnalyticsConstant.TagPageType] = Constants.Page.Type.ap_my
        if tableViewData.count > 0 {
            AnalyticsHelper.MainInstance.trackState(Constants.Page.Name.ReadingList, stateContentData: contentData)
        } else {
            AnalyticsHelper.MainInstance.trackState(Constants.Page.Name.ReadingEmpty, stateContentData: contentData)
        }
    }
    
    func getBookmarkedArticles() -> [Article] {
        guard let journal = currentJournal else { return [] }
        return DatabaseManager.SharedInstance.getAllBookmarksForJournal(journal)
    }
    
    func checkForArticledownloads() {
        for article in getBookmarkedArticles() {
            switch article.downloadInfo.fullTextDownloadStatus {
            case .notDownloaded, .downloadFailed:
                if article.userHasAccess {
                    downloadArticle(article)
                }
            default:
                break
            }
        }
    }
    
    func downloadArticle(_ article: Article) {
        DMManager.sharedInstance.download(article: article, withSupplement: false)
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
        setupNavigationBar()
        setupHeadlineView()
        setupHeadlineEditView()
        
        setupTableView()
        setupEditButton()
        
        if screenType == .mobile {
            setupEditBarButton()
            setupCancelBarButton()
        }
        else if screenType == .tablet {
            
            setupCancelForIpad()
            setupDeleteForIpad()
        }
    }
    
    func setupSubviews() {
        view.addSubview(tableView)
        view.addSubview(headlineView)
        view.addSubview(headlineEditView)
        view.addSubview(advertisementVC.view)
        
        if screenType == .tablet {
            self.headlineView.addSubview(editButton)
            self.headlineView.addSubview(ipadCancelButton)
            self.headlineView.addSubview(iPadDeleteButton)
        }
    }
    
    func setupAutoLayout() {
        self.edgesForExtendedLayout = UIRectEdge()
        
        let subviews = [
            headlineView,
            headlineEditView,
            tableView,
            advertisementVC.view!
        ]
        
        constrain(subviews) { (views) in
            let headlineView = views[0]
            let _headlineEditView = views[1]
            let tableView = views[2]
            let adV = views[3]
            
            guard let superview = headlineView.superview else { return }
            
            headlineView.left == superview.left
            headlineView.top == superview.top
            headlineView.right == superview.right
            
            _headlineEditView.top == headlineView.bottom
            _headlineEditView.left == superview.left
            _headlineEditView.right == superview.right
            
            headlineEditView.layoutConstraints.height = (_headlineEditView.height == 0)
            
            tableView.left == superview.left
            tableView.top == _headlineEditView.bottom
            tableView.right == superview.right
            
            adV.left == superview.left
            adV.top == tableView.bottom
            adV.right == superview.right
            advertisementVC.bottomConstraint = (adV.bottom == superview.bottom)
        }
                
        if screenType == .tablet {
            constrain(editButton, ipadCancelButton, iPadDeleteButton, headlineView) { (editB, cancelB, deleteB, headlineView) -> () in
                
                editB.right == headlineView.right - Config.Padding.Double
                editB.centerY == headlineView.centerY
                
                if screenType == .tablet {
                    
                    deleteB.right == editB.right
                    deleteB.centerY == headlineView.centerY
                    deleteB.width == 70
                    deleteB.height == 44
                    
                    cancelB.width == 70
                    cancelB.height == 44
                    cancelB.right == deleteB.left - Config.Padding.Default
                    cancelB.centerY == headlineView.centerY
                }
            }
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        updateNavigationTitle()
        updateNavigationItemsForScreenType(screenType)
    }
    
    func setupHeadlineView() {
        headlineView.update("Reading List")
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
        tableView.estimatedRowHeight = 66.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(BookmarkTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        tableView.separatorColor = UIColor.clear
        
//        tableView.allowsSelectionDuringEditing = false
        tableView.isAccessibilityElement = false
    }
    
    func setupEditButton() {
        
        if screenType == .tablet {
            
            performOnMainThread({ 
                self.editButton.addTarget(self, action: #selector(self.editButtonWasTapped(_:)), for: UIControlEvents.touchUpInside)
                
                self.editButton.isHidden = self.tableViewData.count > 0 ? false : true
            })
        }
    }
    
    func setupCancelForIpad() {
        
        ipadCancelButton.setTitle("Cancel", for: UIControlState())
        ipadCancelButton.addTarget(self, action: #selector(cancelButtonWasClicked(_:)), for: UIControlEvents.touchUpInside)
        ipadCancelButton.isHidden = true
    }
    
    func setupDeleteForIpad() {
        
        iPadDeleteButton.setTitle("Delete", for: UIControlState())
        iPadDeleteButton.accessibilityLabel = "Delete all articles"
        
        iPadDeleteButton.addTarget(self, action: #selector(deleteButtonWasClicked(_:)), for: UIControlEvents.touchUpInside)
        iPadDeleteButton.isHidden = true
    }
    
    
    func setupEditBarButton() {
        
        editBarButton.delegate = self
    }
    
    func setupCancelBarButton() {
        
        cancelBarButton.delegate = self
    }
    
    func setupHeadlineEditView() {
        
        headlineEditView.showing = false
        headlineEditView.delegate = self
    }
    
    func editButtonAsBarItem() -> [UIBarButtonItem] {

        editBarButton = EditBarButton()
        setupEditBarButton()
        editBarButton.accessibilityLabel = "Edit"
        return [editBarButton]
    }
    
    // MARK: - Layout -
    
    override func updateViewsForScreenChange(_ type: ScreenType) {
        super.updateViewsForScreenChange(type)
        updateNavigationItemsForScreenType(type)
        updateSLTableViewForScreen(type)
    }
    
    //  MARK: - Action -
    
    func editButtonWasTapped(_ sender: AnyObject) {
        
        setupForEditing(true)
    }

    func cancelButtonWasClicked(_ sender: AnyObject) {
        
        setupForEditing(false)
        self.didUpdateEditedSelection([])
    }
    
    func deleteButtonWasClicked(_ sender: AnyObject) {
        
        if self.selectedIndexPaths == nil || self.selectedIndexPaths?.count < 1 {
            
            let alert = Alerts.NoneSelected()
            
            performOnMainThread({
                self.present(alert, animated: true, completion: nil)
            })
            return
        }
        else {
            
            guard let indexPaths = self.selectedIndexPaths else {
                
                return
            }
            
            DatabaseManager.SharedInstance.performChangesAndSave({ () -> () in
                
                if indexPaths.count > 0 {
                    for indexPath in indexPaths {
                        
                        let article = self.tableViewData[(indexPath as NSIndexPath).row]
                        article.starred = false
                        self.tableView.deselectRow(at: indexPath, animated: true)
                    }
                    self.updateTableView()
                    self.didUpdateEditedSelection(self.tableView.indexPathsForSelectedRows)
                    
                    if self.tableViewData.count < 1 {
                        
                        self.setupForEditing(false)
                    }
                }
            })
        }
    }
    
    
    // MARK: - Update -
    
    override func updateNavigationTitle() {
        guard let journal = currentJournal else {
            return
        }
        if screenType == .mobile {
            navigationItem.title = journal.journalTitleIPhone
            navigationItem.accessibilityLabel = journal.journalTitleIPhone
            navigationItem.accessibilityTraits = UIAccessibilityTraitNone
        } else {
            navigationItem.title = journal.journalTitle
            navigationItem.accessibilityLabel = journal.journalTitle
            navigationItem.accessibilityTraits = UIAccessibilityTraitNone
        }
    }
    
    func updateNavigationItemsForScreenType(_ type: ScreenType) {
        DispatchQueue.main.async {
            
            if self.tableView.isEditing == false {
                self.navigationItem.leftBarButtonItem = self.menuBarButtonItem
            }
            switch type {
            case .mobile:
                
                if self.tableViewData.count > 0 {
                    self.navigationItem.rightBarButtonItems = self.editButtonAsBarItem()
                }
                else if self.tableViewData.count < 1 {
                    self.navigationItem.rightBarButtonItems = nil
                }
                
            case .tablet:
                self.navigationItem.rightBarButtonItems = self.rightBarButtonItems
            }
        }
    }
    
    func updateTableView() {
        
        // Weak References & Copies
        self.tableViewData = getBookmarkedArticles()
        checkForArticledownloads()
        let tableViewData = self.tableViewData
        weak var tableView = self.tableView
        
        performOnBackgroundThread {
            var backgroundView: UIView?
            backgroundView = tableViewData.count == 0 ? BookmarksTableViewEmptyBackgroundView() : nil
            performOnMainThread({ 
                tableView?.backgroundView = backgroundView
                tableView?.reloadData()
            })
        }
    }
    
    func setupForEditing(_ isEditing: Bool) {
        
        performOnMainThread { 
            
            if isEditing == true {
                self.tableView.allowsMultipleSelectionDuringEditing = true
                self.tableView.setEditing(true, animated: true)
                
                if self.screenType == .mobile {
                    self.navigationItem.leftBarButtonItems = [self.cancelBarButton]
                }
                else if self.screenType == .tablet {
                    self.editButton.isHidden = true
                    self.ipadCancelButton.isHidden = false
                    self.iPadDeleteButton.isHidden = false
                }
            }
            else {
                self.tableView.allowsMultipleSelectionDuringEditing = false
                self.tableView.setEditing(false, animated: true)
                self.editBarButton.button.isSelected = false
                self.updateNavigationItemsForScreenType(self.screenType)
                
                if self.screenType == .tablet {
                    self.editButton.isHidden = self.tableViewData.count > 0 ? false : true
                    self.ipadCancelButton.isHidden = true
                    self.iPadDeleteButton.isHidden = true
                }
            }
            self.headlineEditView.showing = isEditing
            
            self.updateTableView()
        }
    }
    
    func didUpdateEditedSelection(_ indexPaths: [IndexPath]?) {
        
        selectedIndexPaths = indexPaths
        if self.selectedIndexPaths?.count == self.tableViewData.count {
            
            self.headlineEditView.selectButton?.isSelected = true
        }
        else {
            
            self.headlineEditView.selectButton?.isSelected = false
        }
    }
    
    func toggleAuthorList(_ indexPath: IndexPath) {
        
        if let index = authorExpandedIndexPaths.index(of: indexPath) {
            authorExpandedIndexPaths.remove(at: index)
        } else {
            authorExpandedIndexPaths.append(indexPath)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    
    // MARK: - Table View -
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! BookmarkTableViewCell
        cell.indexPath = indexPath
        cell.bookmarksVC = self
        cell.update(tableViewData[(indexPath as NSIndexPath).row])
        if authorExpandedIndexPaths.contains(indexPath) {
            cell.authorLabel.numberOfLines = 0
            cell.authorsPlusButton.setTitle("-", for: UIControlState())
        } else {
            cell.authorLabel.numberOfLines = 2
            cell.authorsPlusButton.setTitle("+", for: UIControlState())
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let article = tableViewData[(indexPath as NSIndexPath).row]

        if tableView.isEditing == false {
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            let articlePagerVC = ArticlePagerController(article: article, articleArray: tableViewData)
            articlePagerVC.backTitleString = "Bookmarks"
            articlePagerVC.currentJournal = self.currentJournal
            articlePagerVC.cameFromReadingList = true
            navigationController?.pushViewController(articlePagerVC, animated: true)
        
        } else {
            if let indexPaths = tableView.indexPathsForSelectedRows {
                self.didUpdateEditedSelection(indexPaths)
                
            } else {
                self.didUpdateEditedSelection([])
            }
            
            if let cell = tableView.cellForRow(at: indexPath) as? BookmarkTableViewCell {
                
                cell.accessibilityLabel = cell.accessibilityLabelForArticle(article)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        //  If this check doesn't work try check on tableView.editing instead
        if tableView.isEditing == true {

            if let indexPaths = tableView.indexPathsForSelectedRows {
                self.didUpdateEditedSelection(indexPaths)
            }
            else {
                self.didUpdateEditedSelection([])
            }
            
            if let cell = self.tableView.cellForRow(at: indexPath) as? BookmarkTableViewCell {
                
                cell.accessibilityLabel = cell.accessibilityLabelForArticle(self.tableViewData[(indexPath as NSIndexPath).row])
            }
        }
    }
}


class BookmarksTableViewEmptyBackgroundView: UIView {
    
    let imageView = UIImageView(image: UIImage(named: "EmptyReadingListMobile")!)
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubview(imageView)

        isAccessibilityElement = true
        accessibilityLabel = "Reading list is empty. Tap the star icon when viewing the full text of any article to add it to your Reading List. Articles in your reading list are always available offline."
        
        constrain(imageView, block: { (imageV) in
            guard let superview = imageV.superview else {
                return
            }
            imageV.centerY == superview.centerY
            imageV.centerX == superview.centerX
            imageV.width == 320
            imageV.height == 384
        })
    }
}


extension BookmarksViewController: HLEditViewDelegate {
    
    func selectAllButtonWasClicked(_ sender: JBSMButton) {
        
        performOnMainThread { 
            
            for index in 0...self.tableViewData.count - 1 {
                let indexPath = IndexPath(row: index, section: 0)
                
                if sender.isSelected {
                    self.tableView.selectRow(at: indexPath, animated: true,
                        scrollPosition: UITableViewScrollPosition.none)
                }
                else {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
                
                if let cell = self.tableView.cellForRow(at: indexPath) as? BookmarkTableViewCell {
                    
                    cell.accessibilityLabel = cell.accessibilityLabelForArticle(self.tableViewData[(indexPath as NSIndexPath).row])
                }
            }
            
            if let indexPaths = self.tableView.indexPathsForSelectedRows {

                self.didUpdateEditedSelection(indexPaths)
            } else {

                self.didUpdateEditedSelection([])
            }
        }
        }
}


extension BookmarksViewController : EditBarButtonDelegate, CancelBarButtonDelegate {
    
    func barButtonWasClicked(_ sender: JBSMButton) {

        if sender.isSelected == false {
            setupForEditing(true)
            performOnMainThread {
                sender.isSelected = !sender.isSelected
                sender.accessibilityLabel = "Delete selected articles"
            }
        }
        else if sender.isSelected == true {
        
            self.deleteButtonWasClicked(sender)
            sender.accessibilityLabel = "Edit"
        }
    }
    
    func cancelBarButtonClicked(_ sender: JBSMButton) {
        
        cancelButtonWasClicked(sender)
        
        navigationItem.rightBarButtonItem?.accessibilityLabel = "Edit"
        
        editBarButton.accessibilityLabel = "Edit"
    }
}
