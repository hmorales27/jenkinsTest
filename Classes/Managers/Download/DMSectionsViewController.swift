//
//  DMSectionsViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 4/7/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class DMSectionsViewController: SLViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    var tableViewData:[DMSection] = []
    
    // MARK: - Initializers -
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTableViewData()
        setupNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTableViewData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    // MARK: - Setup -
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        
        setupNavigationBar()
        setupTableView()
    }
    
    func setupSubviews() {
        view.addSubview(tableView)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            tableView
        ]
        
        constrain(subviews) { (views) in
            
            let tableV = views[0]
            
            guard let superview = tableV.superview else {
                return
            }
            
            tableV.top == superview.top
            tableV.right == superview.right
            tableV.bottom == superview.bottom
            tableV.left == superview.left
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DMSectionTableViewCell.self, forCellReuseIdentifier: DMSectionTableViewCell.Identifier)
        tableView.estimatedRowHeight = 66.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
    }
    
    override func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_issue_downloadstarted(_:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.DownloadStarted), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_issue_updatecount(_:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.UpdateCount), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_issue_downloadcompleted(_:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.DownloadComplete), object: nil)
    }
    
    override func setupNavigationBar() {
        title = "Downloads"
        
        if enabled == true { }
    }
    
    // MARK: - Notifications -
    
    override func notification_download_issue_downloadstarted(_ notification: Foundation.Notification) {
        updateTableViewData()
    }
    
    func notification_download_issue_updatecount(_ notification: Foundation.Notification) {
        updateTableViewData()
    }
    
    func notification_download_issue_downloadcompleted(_ notification: Foundation.Notification) {
        updateTableViewData()
    }
    
    
    // MARK: - Data -
    
    func updateTableViewData() {
        performOnMainThread { 
            self.tableViewData = DMManager.sharedInstance.sectionsWithFullText
            guard DMManager.sharedInstance.sectionsWithFullText.count > 0 else {
                let ad = UIApplication.shared.delegate as! AppDelegate
                let window = ad.window!
                let screenType = ScreenType.TypeForSize(window.frame.size)
                switch screenType {
                case .mobile:
                    _ = self.navigationController?.popViewController(animated: true)
                case .tablet:
                    self.dismiss(animated: true, completion: nil)
                }
                return
            }
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Table View Delegate -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DMSectionTableViewCell.Identifier) as! DMSectionTableViewCell
        cell.selectionStyle = .none
        if tableViewData.count > 0 {
            let section = tableViewData[(indexPath as NSIndexPath).row]
            cell.update(section: section)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableViewData.count > 0 {
            let section = tableViewData[(indexPath as NSIndexPath).row]
            let itemViewController = DMItemViewController(section: section)
            navigationController?.pushViewController(itemViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
}
