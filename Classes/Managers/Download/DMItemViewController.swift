//
//  DMItemViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 4/8/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class DMItemViewController: JBSMViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    var tableViewData:[DMTableViewItem] = []
    
    weak var section: DMSection?
    
    weak var sectionVC: DMSectionsViewController?
    
    // MARK: - Initializers -
    
    init(section: DMSection) {
        super.init(nibName: nil, bundle: nil)
        self.section = section
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let issue = section?.issue {
            
            var issueLabelText = ""
            
            if let dateText = issue.releaseDateDisplay {
                issueLabelText += dateText
            }
            if let volumeText = issue.volume {
                issueLabelText += " | Volume \(volumeText)"
            }
            if let numberText = issue.issueNumber {
                issueLabelText += " | Issue \(numberText)"
            }
            
            title = issueLabelText
        }
        update()
    }
    
    // MARK: - Setup -
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupTableView()
        setupNotifications()
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
        tableView.register(DMItemTableViewCell.self, forCellReuseIdentifier: DMItemTableViewCell.Identifier)
        tableView.estimatedRowHeight = 66.0
        tableView.rowHeight = UITableViewAutomaticDimension
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_issue_updatecount(_:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.UpdateCount), object: nil)
    }
    
    func notification_download_issue_updatecount(_ notification: Foundation.Notification) {
        updateTableViewData()
    }
    
    // MARK: - Update -
    
    func update() {
        updateTableViewData()
    }
    
    func updateTableViewData() {
        performOnMainThread { 
            guard let section = self.section else {
                _ = self.navigationController?.popViewController(animated: true)
                return
            }
            self.tableViewData = section.tableViewItems
            guard section.tableViewItems.count > 0 else {
                _ = self.navigationController?.popViewController(animated: true)
                return
            }
            self.tableView.reloadData()
            
        }
    }
    
    // MARK: - Table View -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DMItemTableViewCell.Identifier) as! DMItemTableViewCell
        let item = tableViewData[(indexPath as NSIndexPath).row]
        cell.update(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
}
