//
//  SearchViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/2/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class SearchInformation {
    
    var currentJournal: Journal?
    var currentIssue: Issue?
    
    var preText: String?
}

private let BarBackgroundColor = UIColor.lightGray()

enum SearchType: String {
    case AllJournals = "All Journals"
    case ThisJournal = "This Journal"
    case ThisIssue = "This Issue"
}

class SearchViewController: SLViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AuthorPlusButtonDelegate {
    
    let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    let searchBar = UISearchBar()
    let xAccessibilityView = UIView()
    let segmentControl: UISegmentedControl
    let resultsLabel = UILabel()
    
    var tableViewData:[Article] = []
    
    var authorExpandedIndexPaths: [IndexPath] = []
    
    var searchInformation: SearchInformation

    var searchText: String = ""
    
    var dismissable = false
    
    var newSearch = true
    
    var keyboardFrame = CGRect.zero
    
    var popoverWidth: CGFloat = 0.0
    var viewHeight: CGFloat = 0.0

    var type        : SearchType   = .AllJournals
    var searchTypes : [SearchType] = []
    
    struct SearchTypeHolder {
        
        var typesArray: [SearchType] = []
        var stringsArray: [String] = []
        private var enabledArray: [Bool] = []
        
        mutating func addType(type: SearchType) {
            typesArray.append(type)
            stringsArray.append(type.rawValue)
            enabledArray.append(true)
        }
        
        mutating func addType(type: SearchType, enabled: Bool) {
            typesArray.append(type)
            stringsArray.append(type.rawValue)
            enabledArray.append(enabled)
        }

        func typeAtIndex(index: Int) -> SearchType {
            return typesArray[index]
        }
        
        func stringAtIndex(index: Int) -> String {
            return stringsArray[index]
        }
        
        func itemEnabledAtIndex(index: Int) -> Bool {
            return enabledArray[index]
        }
        
        mutating func updateEnabledForIndex(index: Int, enabled: Bool) {
            enabledArray[index] = enabled
        }
        
        var lowestEnabledTypeIndex: Int {
            var i = 0
            for item in enabledArray {
                if item == true {
                    return i
                }
                i += 1
            }
            return 0
        }
    }
    
    var typeHolder = SearchTypeHolder()
    
    
    
    
    init(information: SearchInformation) {

        /* 
         *  Initial Properties 
         */
        self.searchInformation = information
        let journals = DatabaseManager.SharedInstance.getAllJournals()

        // This Issue
        let currentIssueEnabled = searchInformation.currentIssue != .none ? true : false
        typeHolder.addType(type: .ThisIssue, enabled: currentIssueEnabled)

        // This Journal
        let currentJournalEnabled = searchInformation.currentJournal != .none ? true : false
        typeHolder.addType(type: .ThisJournal, enabled: currentJournalEnabled)
        
        // All Journals
        if journals.count > 1 {
            typeHolder.addType(type: .AllJournals, enabled: true)
        }
        
        /* 
         *  Segment Control
         */
        
        segmentControl = UISegmentedControl(items: typeHolder.stringsArray)
        segmentControl.selectedSegmentIndex = typeHolder.lowestEnabledTypeIndex
        
        type = typeHolder.typeAtIndex(index: segmentControl.selectedSegmentIndex)
        
        var index = 0
        for view in segmentControl.subviews {
            guard let _index = segmentControl.subviews.index(of: view) else {
                continue
            }
            
            if typeHolder.itemEnabledAtIndex(index: index) {
                view.isAccessibilityElement = true
                view.accessibilityLabel = "Search articles from " + typeHolder.stringAtIndex(index: index)
            } else {
                view.isAccessibilityElement = false
                view.accessibilityElementsHidden = true
                segmentControl.setEnabled(false, forSegmentAt: index)
                for subview in view.subviews {
                    subview.isAccessibilityElement = false
                }
            }
            
            index += 1
        }
        
        
        /*for view in segmentControl.subviews {
            guard let index = segmentControl.subviews.indexOf(view) else {
                continue
            }
            
            let item = typeHolder.stringAtIndex(index)
            
            if disabledItems.contains(item) == true {
                
                view.isAccessibilityElement = false
                view.accessibilityElementsHidden = true
                
                for subview in view.subviews {
                   subview.isAccessibilityElement = false
                }
                
            } else if disabledItems.contains(item) {
                view.isAccessibilityElement = true
                view.accessibilityLabel = "Search articles from " + items[index]
            }
        }*/

        if let journal = information.currentJournal {
            super.init(journal: journal)
        } else {
            super.init()
            enabled = false
        }
        searchBar.placeholder = "Search"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for _view in (searchBar.value(forKey: "_searchField")! as AnyObject).subviews {
            _view.accessibilityLabel = _view is UIButton ? "Clear search query" : _view.accessibilityLabel
        }
        
        self.reloadData()
        
        //analyticsTagScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
    
    override func analyticsTagScreen() {
        AnalyticsHelper.MainInstance.searchAnalyticsTagScreen(0, criteria: searchText, currentResults: tableViewData.count, totalResults: tableViewData.count, isNewSearch: newSearch)
        if newSearch == true {
            newSearch = false
        }
    }
    
    func setup() {
        view.backgroundColor = BarBackgroundColor
        setupSegmentControl()
        setupTableView()
        setupSearchBar()
        view.addSubview(resultsLabel)
        setupAutoLayout()
        
        if let preText = searchInformation.preText {
            searchBar.text = preText
            searchText = preText
            reloadData()
            analyticsTagScreen()
        }
        if view.frame.width == 320 {
            resultsLabel.font = UIFont.systemFontOfSize(10, weight: SystemFontWeight.Bold)
            segmentControl.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(8, weight: SystemFontWeight.Bold)], for: UIControlState())
        } else {
            resultsLabel.font = UIFont.systemFontOfSize(12, weight: SystemFontWeight.Bold)
            segmentControl.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(12, weight: SystemFontWeight.Bold)], for: UIControlState())
        }
        
        viewHeight = view.frame.size.height
        
        NotificationCenter.default.addObserver(self, selector: #selector(notification_keyboard_did_change(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_keyboard_did_change(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorColor = UIColor.clear
        
        view.addSubview(tableView)
        
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
        
        tableView.estimatedRowHeight = 66.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.layer.cornerRadius = 4
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: Strings.CellIdentifier.SearchCell)
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.barTintColor = AppConfiguration.NavigationBarColor
        searchBar.layer.borderColor = AppConfiguration.NavigationBarColor.cgColor
        searchBar.layer.borderWidth = 1
        
        view.addSubview(searchBar)
    }
    
    //  Setting up view which overlays button that clears text from search bar.
    func setupxAccesibilityView() {
                
        /*  
            Setting as accessibilityElement allows use of voiceOver config,
            turing off userInteraction allows passing through of touches to cancel button. 
        */
        xAccessibilityView.isUserInteractionEnabled = false
        xAccessibilityView.isAccessibilityElement = true
        xAccessibilityView.accessibilityLabel = "Clear search query"
        view.addSubview(xAccessibilityView)
    }
    
    
    func setupSegmentControl() {
        segmentControl.addTarget(self, action: #selector(segmentControlValueDidChange(sender:)), for: UIControlEvents.valueChanged)
        segmentControl.backgroundColor = UIColor.white
        segmentControl.layer.cornerRadius = 4
        segmentControl.tintColor = AppConfiguration.NavigationBarColor
        view.addSubview(segmentControl)
    }
    
    func setupAutoLayout() {
        view.addConstraint(
            NSLayoutConstraint(item: searchBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: Config.Padding.Default))
        
        constrain(tableView, segmentControl, searchBar, resultsLabel, xAccessibilityView) { (tableView, segmentControl, searchBar, resultsL, xaView) -> () in
            guard let superview = tableView.superview else {
                return
            }
            
            searchBar.top == superview.top
            searchBar.right == superview.right
            searchBar.bottom == segmentControl.top - Config.Padding.Default
            searchBar.left == superview.left
            
            resultsL.left == superview.left + Config.Padding.Default
            resultsL.centerY == segmentControl.centerY
            
            segmentControl.right == superview.right - Config.Padding.Default
            segmentControl.bottom == tableView.top - Config.Padding.Default
            segmentControl.left == resultsL.right + Config.Padding.Default
            
            tableView.right == superview.right
            tableView.bottom == superview.bottom
            tableView.left == superview.left
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        if dismissable == true {
            self.navigationItem.leftBarButtonItem = closeBarButtonItem
            title = "Search"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.CellIdentifier.SearchCell)! as! ArticleTableViewCell
        let article = tableViewData[(indexPath as NSIndexPath).row]
        
        cell.updateOnSearchVc(article, searchType: type)
        cell.subTypeView.layoutConstraints.height?.constant = 0
        cell.subTypeView.isHidden = true
        cell.indexPath = indexPath
        cell.authorPlusButtonDelegate = self
        if authorExpandedIndexPaths.contains(indexPath) {
            cell.authorsLabel.numberOfLines = 0
            cell.authorsPlusButton.setTitle("-", for: UIControlState())
        } else {
            cell.authorsLabel.numberOfLines = 2
            cell.authorsPlusButton.setTitle("+", for: UIControlState())
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText == "" {
            xAccessibilityView.isAccessibilityElement = false
        }
        else {
            xAccessibilityView.isAccessibilityElement = true
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let _text = searchBar.text {
            self.searchText = _text
        } else {
            self.searchText = ""
        }
        updateTableViewData()
    }
    
    private let emptyPresenterHeight: CGFloat = 90
    
    func updatePresenterFrame() {
        guard let presenter = navigationController?.presentingViewController else {
            return
        }
        let presenterFrame = presenter.view.frame
        let presenterSize = presenterFrame.size
        
        popoverWidth = presenterSize.width * 0.75
        
        var height: CGFloat = 0
        if tableViewData.count == 0 {
            height = emptyPresenterHeight
        } else {
            var popoverHeight = presenterSize.height - Config.Padding.Default
            if keyboardFrame.minY < presenterFrame.maxY {
                popoverHeight = popoverHeight - keyboardFrame.height
            }
            height = popoverHeight
        }
        performOnMainThread { 
            self.preferredContentSize = CGSize(width: self.popoverWidth, height: height)
            self.navigationController?.preferredContentSize = self.preferredContentSize
        }
        
        
    }
    
    func reloadData() {
        if let _text = searchBar.text {
            searchText = _text
        }
        
        var searchType = ""
        
        switch type {
        case .AllJournals:
            tableViewData = DatabaseManager.SharedInstance.getArticles(searchText)
            searchType = "All Journals"
        case .ThisJournal:
            tableViewData = DatabaseManager.SharedInstance.getArticles(searchText, inJournal: searchInformation.currentJournal!)
            searchType = "This Journal"
        case .ThisIssue:
            tableViewData = DatabaseManager.SharedInstance.getArticles(searchText, inIssue: searchInformation.currentIssue!)
            searchType = "This Issue"
        }
        resultsLabel.text = "\(tableViewData.count) Articles"
        
        if let resultText = resultsLabel.text {
            
            let accessibility = resultText + " found from " + searchType

            resultsLabel.accessibilityLabel = accessibility
        }
        tableView.reloadData()
    }
    
    
    func updateTableViewData() {
        reloadData()
        analyticsTagScreen()
        updatePresenterFrame()
    }

    func notification_keyboard_did_change(_ notification: NSNotification) {
        
        if notification.name == NSNotification.Name.UIKeyboardWillChangeFrame {
            if let userInfo = notification.userInfo {
                if let _keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
                    let presenter = navigationController?.presentingViewController {
                    
                    keyboardFrame = _keyboardFrame
                    
                    let presenterFrame = presenter.view.frame
                    let presenterSize = presenterFrame.size

                    
                    popoverWidth = presenterSize.width * 0.75
                    
                    let visiblePaths = tableView.indexPathsForVisibleRows
                    
                    guard let lastVisiblePath = visiblePaths?.last else {
                        
                        return
                    }
                    
                    var popoverHeight = presenterSize.height - Config.Padding.Default
                    
                    if _keyboardFrame.minY < presenterFrame.maxY {
                        popoverHeight = popoverHeight - _keyboardFrame.height
                    }
                    
                    preferredContentSize = CGSize(width: popoverWidth, height: presenterSize.height)
                    
                    tableView.reloadData()
                    
                    guard tableView.cellForRow(at: lastVisiblePath) != nil else {
                        
                        return
                    }
                    
                    if popoverHeight < tableView.frame.maxY {
                        
                        popoverHeight = tableView.frame.maxY
                    }
                    
                    preferredContentSize = CGSize(width: popoverWidth, height: popoverHeight)
                    
                    navigationController?.preferredContentSize = preferredContentSize
                }
            }
        }
    }
    

    func segmentControlValueDidChange(sender: UISegmentedControl) {
        
        type = typeHolder.typeAtIndex(index: sender.selectedSegmentIndex)
        
        performOnMainThread {
            self.updateTableViewData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AnalyticsHelper.MainInstance.searchAnalyticsTagAction(AnalyticsHelper.SearchAction.resultClick, criteria: searchText.lowercased(), clickPosition: indexPath.row + 1)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let article = tableViewData[indexPath.row]
        let articleVC = ArticlePagerController(article: article, articleArray: tableViewData, dismissable: true)
        let navigationVC = UINavigationController(rootViewController: articleVC)
        present(navigationVC, animated: true, completion: nil)
    }
    
    func authorPlusButtonWasClickedforIndexPath(_ indexPath: IndexPath) {
        if let index = authorExpandedIndexPaths.index(of: indexPath as IndexPath) {
            authorExpandedIndexPaths.remove(at: index)
        } else {
            authorExpandedIndexPaths.append(indexPath as IndexPath)
        }
        tableView.reloadRows(at: [indexPath as IndexPath], with: .none)
    }
}
