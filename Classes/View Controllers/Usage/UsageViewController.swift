//
//  UsageViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/8/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let CellIdentifier = "UsageTableViewCell"

class UsageViewController: SLViewController, UITableViewDelegate, UITableViewDataSource {
    
    let headlineView = HeadlineView()
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    var tableViewData: [Journal] = []
    
    var shouldShowHeadlineView = true
    
    override init() {
        super.init()
    }
    
    override init(journal: Journal) {
        super.init(journal: journal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        analyticsScreenName = Constants.Page.Name.SettingsUsage
        analyticsScreenType = Constants.Page.Type.ap_my
        setup()
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        update()
        super.viewDidAppear(animated)
    }
    
    // MARK: - Setup -
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupTableView()
        setupNavigationBar()
        setupHeadlineView()
    }
    
    func setupSubviews() {
        view.addSubview(headlineView)
        view.addSubview(tableView)
    }
    
    func setupAutoLayout() {
        constrain(headlineView, tableView) { (headlineView, tableView) -> () in
            guard let superview = headlineView.superview else {
                return
            }
            
            headlineView.left == superview.left
            headlineView.top == superview.top
            headlineView.right == superview.right
            
            tableView.left == superview.left
            tableView.top == headlineView.bottom
            tableView.right == superview.right
            tableView.bottom == superview.bottom
        }
        
        if shouldShowHeadlineView == false {
            self.headlineView.layoutConstraints.height?.constant = 0
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
        
        tableView.register(UsageTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
    }
    
    // MARK: - Update -
    
    func update() {
        updateTableViewData()
    }
    
    func updateTableViewData() {
        performOnMainThread { 
            self.tableViewData = DatabaseManager.SharedInstance.getAllJournals()
            self.tableView.reloadData()
        }
    }
    
    func setupHeadlineView() {
        headlineView.update("Usage")
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        if shouldShowHeadlineView == true {
            title = DatabaseManager.SharedInstance.getAppPublisher()?.appTitleIPhone!
        } else {
            title = "Usage"
        }
        
        if enabled == true {
            navigationItem.leftBarButtonItem = menuBarButtonItem
        } else {
            navigationItem.leftBarButtonItems = backButtons("Settings", dark: true)
        }
    }
    
    // MARK: - Table View -
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! UsageTableViewCell
        let journal = tableViewData[(indexPath as NSIndexPath).row]
        cell.update(journal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let journal = tableViewData[(indexPath as NSIndexPath).row]
        let usageDetailVC = UsageJournalViewController(journal: journal)
        usageDetailVC.shouldShowHeadlineView = self.shouldShowHeadlineView
        navigationController?.pushViewController(usageDetailVC, animated: true)
    }
}
