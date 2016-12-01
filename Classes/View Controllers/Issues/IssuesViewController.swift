//
//  IVC.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/24/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Cartography

let reuseIdentifier = "iPhoneIssueCell"

enum IssueFilterType: String {
    case Notes = "Notes"
    case Starred = "Starred"
}



class IssuesViewController: SLViewController, SectionDataViewDelegate, UIPopoverPresentationControllerDelegate {
    
    // MARK: PROPERTIES
    
    weak var popover: UIPopoverPresentationController?
    
    var _collectionView: UICollectionView!
    var segmentControl = UISegmentedControl()
    
    
    //var adView = JBSMAdBannerView()
    let advertisementVC = AdvertisementViewController()
    
    var dataSource: CollectionDataSource!
    
    var firstLaunch = false
    
    //  WHEN IS THIS BEING CALLED??????
    var items: [String] {
        
        var items = ["All Issues"]
        let issues = getIssues()
        
        for issue in issues {
            if issue.openArchive() == true {
                
                items.insert("Open Archive", at: items.startIndex + 1)
                break
            }
        }
        return items
    }
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.headerReferenceSize = CGSize(width: 100, height: 44)
        flowLayout.footerReferenceSize = CGSize(width: 0, height: 0)
        return flowLayout
    }()
    
    override var screenTitle: String {
        return screenTitleJournal
    }
    
    // MARK: INITIALIZERS

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.selectedType = SLTableViewItemType.allIssues
    }
    
    override init(journal: Journal) {
        super.init(journal: journal)
        _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        self.selectedType = SLTableViewItemType.allIssues
        
        AnalyticsHelper.MainInstance.analyticsTagScreen(pageName: Constants.Page.Name.AllIssues, pageType: Constants.Page.Type.pu_pi)
        
        addChildViewController(advertisementVC)
        advertisementVC.didMove(toParentViewController: self)
    }
    
    // MARK: LIFECYCLE
    
    override func viewDidLoad() {

        setup()
        advertisementVC.setup(AdType.iPadPortrait, journal: currentJournal!)

        updateJournalIssues()
        
        switch screenType {
        case .mobile:
            segmentControl.removeSegment(at: 2, animated: true)
            segmentControl.insertSegment(withTitle: "On My iPhone", at: 2, animated: false)
        case .tablet:
            segmentControl.removeSegment(at: 2, animated: true)
            segmentControl.insertSegment(withTitle: "On My iPad", at: 2, animated: false)
        }
        
        toggleDefaultExpandAndCollapse(dataSource.count)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstLaunch == true {
            updateIssueList()
            firstLaunch = false
        } else {
            guard let cells = _collectionView.visibleCells as? [IssueCollectionViewCell] else { return }
            for cell in cells {
                cell.refresh()
            }
        }
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: OVERRIDE
    
    override func updateViewsForScreenChange(_ type: ScreenType) {
        super.updateSLTableViewForScreen(type)
        updateNavigationItemsForScreenType(type)
        updateSLTableViewForScreen(type)
        _collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - Setup -

extension IssuesViewController {
    
    func setup() {
        setupSegmentController()
        setupSubviews()
        setupAutoLayout()
        setupCollectionView()
        setupNavigationBar()
        setupDataSource()
    }
    
    func setupDataSource() {
        dataSource = CollectionDataSource(items: getIssues())
    }
    
    func setupSubviews() {
        view.addSubview(segmentControl)
        view.addSubview(_collectionView)
        view.addSubview(advertisementVC.view)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            segmentControl,
            _collectionView,
            advertisementVC.view!
        ]
        
        constrain(subviews) { (views) in
            
            let segmentC    = views[0]
            let collectionV = views[1]
            let adV         = views[2]
            
            guard let superview = segmentC.superview else {
                return
            }
            
            segmentC.top == superview.top + Config.Padding.Small
            if screenType == .mobile {
                segmentC.left == superview.left + Config.Padding.Small
                segmentC.right == superview.right - Config.Padding.Small
            }
            segmentC.centerX == superview.centerX
            
            collectionV.top == segmentC.bottom + Config.Padding.Small
            collectionV.right == superview.right
            collectionV.left == superview.left
            
            adV.top == collectionV.bottom
            advertisementVC.bottomConstraint = (adV.bottom == superview.bottom)
            adV.right == superview.right
            adV.left == superview.left
        }
    }
    
    func setupCollectionView() {
        _collectionView.register(SectionsData.CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SectionsData.View.Identifier)
        _collectionView.register(IssueCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        _collectionView.backgroundColor = UIColor.veryLightGray()
        _collectionView.delegate = self
        _collectionView.dataSource = self
    }
    
    func setupSegmentController() {
        
        segmentControl = UISegmentedControl.init(items: items)
        
        segmentControl.backgroundColor = UIColor.white
        segmentControl.layer.cornerRadius = 4.0
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentControlDidChange(_:)), for: .valueChanged)
        
        let views = self.segmentControl.subviews
        
        if views.count > 0 {
            let segment = views[0]
            segment.accessibilityIdentifier = "Item One Zillion"
        }
        
        for view in segmentControl.subviews {
            
            let index = segmentControl.subviews.index(of: view)
            view.accessibilityLabel = index == 0 ? "All Issues" : index == 1 && view == segmentControl.subviews.last ? "Open Archive" : ""
        }
    }
    
    // MARK: SEGMENT CONTROL
    
    func segmentControlDidChange(_ segmentControl: UISegmentedControl) {
        setupDisplayForSelectedSegment()
    }
    
    func setupDisplayForSelectedSegment() {
        
        //  **Expand all sections here.**
        
        if segmentControl.subviews.count == 3 {
            
            //  Is this conditional (selectedIndex == 0) triggered when first opening
            //  all issues view from slider menu.
            if segmentControl.selectedSegmentIndex == 0 {
                dataSource.showOnlyDownloadedIssues = false
                dataSource.showOnlyOAIssues = false
                
                let first = dataSource[0]
                first.collapsed = first.collapsed == true ? false : first.collapsed
                
            } else if segmentControl.selectedSegmentIndex == 2 {
                dataSource.showOnlyDownloadedIssues = true
                dataSource.showOnlyOAIssues = false
                
                if dataSource.count == 0 {
                    let alertVC = UIAlertController(title: "Message", message: "Currently there is no issue downloaded", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    performOnMainThread({
                        self.present(alertVC, animated: true, completion: nil)
                    })
                }
            } else if segmentControl.selectedSegmentIndex == 1 {
                dataSource.showOnlyDownloadedIssues = false
                dataSource.showOnlyOAIssues = true
                
                for section in dataSource {
                    
                    section.collapsed = section.collapsed == true ? false : section.collapsed
                }
            }
        }
        else if segmentControl.subviews.count == 2 {
            if segmentControl.selectedSegmentIndex == 0 {
                dataSource.showOnlyDownloadedIssues = false
                dataSource.showOnlyOAIssues = false
            }
            else if segmentControl.selectedSegmentIndex == 1 {
                
                dataSource.showOnlyDownloadedIssues = true
                dataSource.showOnlyOAIssues = false
                
                if dataSource.count == 0 {
                    let alertVC = UIAlertController(title: "Message", message: "Currently there is no issue downloaded", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    performOnMainThread({
                        self.present(alertVC, animated: true, completion: nil)
                    })
                }
            }
        }
        print("dataSource.count == \(dataSource.count)")
        
        
        if dataSource.count > 0 {
            toggleDefaultExpandAndCollapse(dataSource.count)

            
        }
        else if dataSource.count == 0 {
            _collectionView.reloadData()
        }
    }
}

// MARK: - Update -

extension IssuesViewController {
    
    /*
     * Updates the Data Source & Reloads Table View
    */
 
    
    func updateIssueList() {
        performOnMainThread {
            self.updateDataSource()
            self._collectionView.reloadData()
        }
    }
    
    /*
     * Updates the Data Source
    */
    
    func updateDataSource() {
        dataSource.update(items: self.getIssues())
    }
    
    /*
     * Gets all the Issues for the Journal
    */
    
    func getIssues() -> [Issue] {
        guard let journal = currentJournal else { return [] }
        return DatabaseManager.SharedInstance.getAllIssuesForJournal(journal)
    }
}



// MARK: - Collection View Delegate & DataSource -

extension IssuesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = dataSource[(indexPath as NSIndexPath).section]
        let headerView = _collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SectionsData.View.Identifier, for: indexPath) as! SectionsData.CollectionHeaderView
        headerView.view.delegate = self
        headerView.view.update(section.title, section: (indexPath as NSIndexPath).section, color: nil, collapsed: section.collapsed)
        return headerView
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! IssueCollectionViewCell
        if let issue = dataSource[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].issue {
            cell.setupIssue(issue)
            cell.viewController = self
            cell.coverImageView.setScreenType(self.screenType)
            cell.notesButton.delegate = self
            cell.starredButton.delegate = self
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat = 8
        let width: CGFloat = self.view.frame.width
        var numberOfCellsPerRow: CGFloat = 0
        
        if width <= 507 {
            numberOfCellsPerRow = 1
        } else if width <= 768 {
            numberOfCellsPerRow = 2
        } else {
            numberOfCellsPerRow = 3
        }
        
        let rowPadding: CGFloat = padding * (1 + numberOfCellsPerRow)
        let allowedWith: CGFloat = width - rowPadding
        let cellWidth: CGFloat = (allowedWith / numberOfCellsPerRow)
        
        var height: CGFloat
        if screenType == .mobile {
            height = 150
        } else {
            height = 200
        }
        return CGSize(width: cellWidth, height: height + (Config.Padding.Default * 2) + 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //  **log .getAllArticles() result
        guard let issue = dataSource[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].issue else { return }
        guard NETWORK_AVAILABLE else {
            let articles = DatabaseManager.SharedInstance.getAllArticlesForIssue(issue)
            if articles.count == 0 {
                let alertVC = Alerts.NoNetwork()
                performOnMainThread({ 
                    self.present(alertVC, animated: true, completion: nil)
                })
            }
            else if articles.count > 0 {
                pushVcForIssue(issue, filter: nil)
            }
            return
        }
        pushVcForIssue(issue, filter: nil)
    }
    
    //  MARK: Navigation
    
    func pushVcForIssue(_ issue: Issue, filter: IssueFilterType?) {
        
        let articlesVC = StoryboardHelper.Articles()
        articlesVC.issue = issue
        articlesVC.currentJournal = issue.journal
        articlesVC.shouldShowBackButton = true
        
        CATransaction.begin()
        self.overlord?.pushViewController(articlesVC, animated: true)
        CATransaction.setCompletionBlock { 
            
            guard let headerView = articlesVC.headerView else { return }
            guard let filter = filter else { return }
            
            switch filter {
            case .Notes:
                headerView.updateFilterAndNotesButton(headerView.noteButton)
            case .Starred:
                headerView.updateFilterAndStarButton(headerView.starredButton)
            }
        }
        CATransaction.commit()
    }
}




// MARK: - Miscelanious -

extension IssuesViewController {
    
    func updateJournalIssues() {
        performOnBackgroundThread {
            guard NETWORKING_ENABLED else { return }
            guard let journal = self.currentJournal else { return }
            ContentKit.SharedInstance.updateIssues(journal: journal, completion: { (success) in
                guard success == true else { return }
                performOnMainThread({
                    self.updateIssueList()
                })
            })
        }
    }
    
    // MARK: NAVIGATION BAR
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        updateNavigationTitle()
        updateNavigationItemsForScreenType(screenType)
    }
    
    func updateNavigationItemsForScreenType(_ type: ScreenType) {
        DispatchQueue.main.async {
            self.popover?.presentedViewController.dismiss(animated: true, completion: nil)
            self.navigationItem.leftBarButtonItem = self.menuBarButtonItem
            switch type {
            case .mobile:
                self.navigationItem.rightBarButtonItems = nil
            case .tablet:
                self.navigationItem.rightBarButtonItems = self.rightBarButtonItems
            }
        }
    }
    
    // MARK: LAYOUT
    
    // MARK: SECTION HEADER
    
    //  Need to iterate through dataSource, for everything that is
    //  collapsed set it to 'not' collapsed on selecting different segments
    //  before 
    func sectionViewDidToggleCollapseForIndex(_ index: Int) {
        dataSource[index].collapsed = !dataSource[index].collapsed
        _collectionView.reloadSections(IndexSet(integer: index))
    }
    
    
    func toggleDefaultExpandAndCollapse(_ sectionCount: Int) {

        var lastIndex = 0
        var expandNextYear = false

        for section in dataSource {
            var collapsed = true
            
            if lastIndex == 0 {
                collapsed = false
                
                expandNextYear = section.activeItems.count < 6 ? true : expandNextYear
            }
            else if lastIndex == 1 && expandNextYear == true {
                
                collapsed = false
            }            
            section.collapsed = collapsed
            lastIndex += 1
        }
        _collectionView.reloadData()
    }
    
    
    func sectionViewDidToggleCollapseAll(_ collapse: Bool) {
        
    }
    
    
    // MARK: MODAL PRESENTATION
    
    @objc(adaptivePresentationStyleForPresentationController:) func adaptivePresentationStyle (for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}


extension IssuesViewController: IssueNotesDelegate {

    func notesButtonWasClicked(_ button: IssueNotesButton) {
        
        guard let cell = button.superview?.superview as? IssueCollectionViewCell else {
            
            return
        }
        guard let indexPath = _collectionView.indexPath(for: cell), let issue = dataSource[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].issue else {
            
            return
        }
        
        pushVcForIssue(issue, filter: .Notes)
    }
}


extension IssuesViewController: IssueStarDelegate {
    
    func starButtonWasClicked(_ button: IssueStarredButton) {
        
        guard let cell = button.superview?.superview as? IssueCollectionViewCell else {
            
            return
        }
        guard let indexPath = _collectionView.indexPath(for: cell), let issue = dataSource[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].issue else {
            
            return
        }
        
        pushVcForIssue(issue, filter: .Starred)
    }
}
