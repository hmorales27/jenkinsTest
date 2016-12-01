//
//  UsageIssueViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/8/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let CellIdentifier = "UsageIssueTableViewCell"

class UsageIssueViewController: JBSMViewController, UITableViewDelegate, UITableViewDataSource, UsageIssueTableViewCellDelegate {
    
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    let headerView = HeadlineView()
    
    let journal: Journal
    var tableViewData: [TableViewSection] = []
    
    var shouldShowHeadlineView = true
    
    init(journal: Journal) {
        self.journal = journal
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        update()
    }
    
    // MARK: - Setup -
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupHeaderView()
        setupTableView()
        setupNavigationBar()
    }
    
    func setupSubviews() {
        view.addSubview(headerView)
        view.addSubview(tableView)
    }
    
    func setupAutoLayout() {
        constrain(headerView, tableView) { (headerView, tableView) -> () in
            guard let superview = headerView.superview else {
                return
            }
            
            headerView.left == superview.left
            headerView.top == superview.top
            headerView.right == superview.right
            
            tableView.left == superview.left
            tableView.top == headerView.bottom
            tableView.right == superview.right
            tableView.bottom == superview.bottom
        }
        
        if shouldShowHeadlineView == false {
            headerView.layoutConstraints.height?.constant = 0
        }
    }
    
    func setupHeaderView() {
        headerView.update("Issue Usage")
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor.clear
        tableView.register(UsageIssueTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        let dark = shouldShowHeadlineView ? false : true
        navigationItem.leftBarButtonItems = backButtons("Issue Usage", dark: dark)
    }
    
    // MARK: - Update
    
    func update() {
        updateTableViewData()
    }
    
    func updateTableViewData() {
        tableViewData = DatabaseManager.SharedInstance.getAllIssuesBySectionForJournal(journal)
        
        // Huge Hack ... Need More Development Time When ReWriting An Entire App
        
        if showNoIssueDownloaded() == true {
            tableViewData = []
            
            let view = UIView()
            let noIssueLabel = UILabel()
            noIssueLabel.text = "No Issues have been Downloaded"
            noIssueLabel.textAlignment = NSTextAlignment.center
            noIssueLabel.font = UIFont.systemFontOfSize(16, weight: .Bold)
            view.addSubview(noIssueLabel)
            
            constrain(noIssueLabel, block: { (noIssueL) in
                guard let superview = noIssueL.superview else {
                    return
                }
                
                noIssueL.centerY == superview.centerY
                noIssueL.centerX == superview.centerX
                noIssueL.width == superview.width - (Config.Padding.Double * 2)
            })
            
            tableView.backgroundView = view
            tableView.separatorColor = UIColor.clear
        } else {
            tableView.backgroundView = nil
            tableView.separatorColor = Config.Colors.TableViewSeparatorColor
        }
        
        
        tableView.reloadData()
    }
    
    func showNoIssueDownloaded() -> Bool {
        let sectionCount = tableViewData.count
        for i in 1...sectionCount {
            let section = tableViewData[i - 1]
            for item in section.items {
                for article in item.allArticles {
                    if article.downloadInfo.fullTextDownloadStatus == .downloaded {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    // MARK: - Table View -
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! UsageIssueTableViewCell
        cell.selectionStyle = .none
        let section = tableViewData[(indexPath as NSIndexPath).section]
        let issue = section.items[(indexPath as NSIndexPath).row]
        cell.update(issue)
        cell.viewController = self
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData[section].items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = tableViewData[section]
        return section.title
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        if section == tableView.numberOfSections - 1 {
            
            let textView = UsageTextView()
            let string = textView.usageViewText
            
            guard let attributedText = UsageTextView.formattedStringForString(string) else {
                
                return nil
            }
            
            textView.attributedText = attributedText
            textView.frameInContainingView(view)
            textView.backgroundColor = UIColor.clear
            textView.isScrollEnabled = false
            textView.isSelectable = false
            textView.isEditable = false
            
            textView.textContainerInset = UIEdgeInsetsMake(12, 12, 0, 10)
            
            return textView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            
            let textView = UsageTextView()
            let text = textView.usageViewText
            
            let encoded = text.data(using: String.Encoding.utf8)
            let attributedOptions : [String: AnyObject] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
                NSCharacterEncodingDocumentAttribute: String.Encoding.utf8 as AnyObject
            ]
            
            guard let data = encoded else {
                
                return 0
            }
            do {
                let attributed = try NSAttributedString.init(data: data, options: attributedOptions, documentAttributes: nil)
                textView.attributedText = attributed
                
            } catch {
                log.warning("error setting up textView on UsageJournalVC.")
                return 0
            }
            
            textView.frameInContainingView(view)
            textView.textContainerInset = UIEdgeInsetsMake(12, 12, 0, 10)
            
            /*
             First object of sharedApplication.windows should always return 'main' window.
             This is necessary to get actual device screen type, since screenType on this
             controller always returns 'Mobile.
             */
            
            guard let firstWindow = UIApplication.shared.windows.first else {
                
                return 0
            }
            
            let isIpad = firstWindow.bounds.size.width < 768 ? false : true
            let bufferValue = isIpad == true ? 280 : 335
            
            return textView.bounds.height + CGFloat(bufferValue)
        }
        return 0
    }
    
    func usageIssueTableViewCellDidClickDelete(_ indexPath: IndexPath) {
        let issue = tableViewData[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        
        performOnMainThread { 
            let alertVC = UIAlertController(title: "Are you sure you want to delete?", message: "Deleting will remove this content from your device", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Delete article with multimedia", style: .default, handler: { (action) in
                ContentKit.SharedInstance.deleteIssue(issue, onlyMultimedia: false, completion: { (success) in
                    performOnMainThread({
                        self.updateTableViewData()
                        let alertVC = Alerts.ArticlesDeleted()
                        self.present(alertVC, animated: true, completion: nil)
                    })
                })
            }))
            alertVC.addAction(UIAlertAction(title: "Delete multimedia only", style: .default, handler: { (action) in
                ContentKit.SharedInstance.deleteIssue(issue, onlyMultimedia: true, completion: { (success) in
                    performOnMainThread({
                        self.updateTableViewData()
                        let alertVC = Alerts.ArticlesDeleted()
                        self.present(alertVC, animated: true, completion: nil)
                    })
                })
            }))
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
        
    }
    
}
