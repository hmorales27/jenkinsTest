//
//  UsageDetailViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/8/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let CellIdentifier = "UsageJournalTableViewCell"

class UsageJournalViewController: JBSMViewController, UITableViewDelegate, UITableViewDataSource, UsageJournalTableViewCellDelegate {
    
    let headerView = HeadlineView()
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    let textView = UITextView()
    
    let tableViewData = [["Articles & Multimedia*", "Multimedia*"], ["Articles & Multimedia*", "Multimedia*"], ["Individual Issues"], ["Articles & Multimedia*", "Multimedia*"]]
    
    var combinedTotal: Int = 0
    var combinedMultimedia: Int = 0
    
    var issueTotal: Int = 0
    var issueMultimedia: Int = 0
    
    var aipTotal: Int = 0
    var aipMultimedia: Int = 0
    
    let journal: Journal
    
    var shouldShowHeadlineView = true
    
    let OVERALL_DOWNLOADED = "Overall downloaded size of "
    let ISSUES_DOWNLOADED = "Issues downloaded size of "
    
    // MARK: - Initializers -
    
    init(journal: Journal) {
        self.journal = journal
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
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
        setupTableView()
        setupHeaderView()
        setupNavigationBar()
    }
    
    func setupSubviews() {
        view.addSubview(headerView)
        view.addSubview(tableView)
        view.addSubview(textView)
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
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UsageJournalTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setupHeaderView() {
        headerView.update("Usage")
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        if shouldShowHeadlineView {
            title = journal.journalTitleIPhone
        } else {
            title = journal.journalTitle
        }

        
        let dark = shouldShowHeadlineView ? false : true
        navigationItem.leftBarButtonItems = backButtons("Usage", dark: dark)
    }
    
    // MARK: - Update -
    
    func update() {
        updateTableViewData()
        tableView.reloadData()
    }
    
    func updateTableViewData() {
        updateIssueData()
    }
    
    func updateIssueData() {
        
        var issueFullText: Int = 0
        var issueSupplement: Int = 0
        
        var aipFullText: Int = 0
        var aipSupplement: Int = 0
        
        
        for article in DatabaseManager.SharedInstance.getAllArticlesforJournal(journal) {
            
            var fullText: Int = 0
            var supplement: Int = 0
            
            if article.downloadInfo.abstractSupplDownloadStatus == .downloaded {
                supplement += Int(article.downloadInfo.abstractSupplFileSize)
            }
            if article.downloadInfo.fullTextDownloadStatus == .downloaded {
                fullText += Int(article.downloadInfo.fullTextFileSize)
            }
            
            if article.downloadInfo.fullTextSupplDownloadStatus == .downloaded {
                supplement += Int(article.downloadInfo.fullTextSupplFileSize)
            } else {
                for media in article.allMedia {
                    if media.downloadStatus == .downloaded {
                        supplement += Int(media.fileSize)
                    }
                }
            }
            
            if article.issue != .none {
                issueFullText += fullText
                issueSupplement += supplement
            } else {
                aipFullText += fullText
                aipSupplement += supplement
            }
        }
        
        self.combinedTotal = issueFullText + issueSupplement + aipFullText + aipSupplement
        self.combinedMultimedia = issueSupplement + aipSupplement
        
        self.issueTotal = issueFullText + issueSupplement
        self.issueMultimedia = issueSupplement
        
        self.aipTotal = aipFullText + aipSupplement
        self.aipMultimedia = aipSupplement
    }
    
    // MARK: - Table View -
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! UsageJournalTableViewCell
        let section = tableViewData[(indexPath as NSIndexPath).section]
        let row = section[(indexPath as NSIndexPath).row]
        if row != "Individual Issues" {
            cell.selectionStyle = .none
        }
        cell.titleLabel.text = row
        
        cell.delegate = self
        cell.indexPath = indexPath
        
        if (indexPath as NSIndexPath).section == 0 {
            
            if (indexPath as NSIndexPath).row == 0 {
                
                let total = self.combinedTotal
                cell.sizeLabel.text = self.combinedTotal.convertToFileSize()
                
                if total > 0 {
                    cell.deleteButton.isHidden = false
                }
                
                if let titleText = cell.titleLabel.text {
                    
                    let cleanTitle = titleText.replacingOccurrences(of: "*", with: "")
                    
                    cell.accessibilityLabel = OVERALL_DOWNLOADED + cleanTitle + " is \(self.combinedTotal.convertToFileSize())"
                    
                    if total > 0 {
                        cell.deleteButton.accessibilityLabel = "Delete \(cleanTitle) from Overall Section"
                    }
                }
                
            } else if (indexPath as NSIndexPath).row == 1 {
                
                let total = self.combinedMultimedia
                cell.sizeLabel.text = total.convertToFileSize()
                if total > 0 {
                    cell.deleteButton.isHidden = false
                }
                
                if let titleText = cell.titleLabel.text {
                    
                    let cleanTitle = titleText.replacingOccurrences(of: "*", with: "")
                    
                    cell.accessibilityLabel = OVERALL_DOWNLOADED + cleanTitle + "is \(total.convertToFileSize())"
                    
                    if total > 0 {
                        cell.deleteButton.accessibilityLabel = "Delete \(cleanTitle) from Overall Section"
                    }
                }
            }
        } else if (indexPath as NSIndexPath).section == 1 {
            
            if (indexPath as NSIndexPath).row == 0 {
                
                let total = self.issueTotal
                cell.sizeLabel.text = total.convertToFileSize()
                if total > 0 {
                    cell.deleteButton.isHidden = false
                }
                
                if let titleText = cell.titleLabel.text {
                    
                    let cleanTitle =  titleText.replacingOccurrences(of: "*", with: "")
                    
                    cell.accessibilityLabel = ISSUES_DOWNLOADED + cleanTitle + "is \(total.convertToFileSize())"
                    
                    if total > 0 {
                        cell.deleteButton.accessibilityLabel = "Delete \(cleanTitle) from Issues section"
                    }
                }
                
            } else if (indexPath as NSIndexPath).row == 1 {
                
                let total = self.issueMultimedia
                cell.sizeLabel.text = total.convertToFileSize()
                if total > 0 {
                    cell.deleteButton.isHidden = false
                }
                
                if let titleText = cell.titleLabel.text {

                    let cleanTitle =  titleText.replacingOccurrences(of: "*", with: "")
                    
                    cell.accessibilityLabel = ISSUES_DOWNLOADED + cleanTitle + "is \(total.convertToFileSize())"

                    if total > 0 {
                        cell.deleteButton.accessibilityLabel = "Delete \(cleanTitle) from Issues section"
                    }
                }
                
            }
        } else if (indexPath as NSIndexPath).section == 2 {
            
            cell.continueLabel.isHidden = false
            cell.sizeLabel.text = ""
            
            if let titleText = cell.titleLabel.text {

                cell.accessibilityLabel = "\(titleText). Double-tap to go to detail."
            }
            
        } else if (indexPath as NSIndexPath).section == 3 {
            
            if (indexPath as NSIndexPath).row == 0 {
                
                let total = self.aipTotal
                cell.sizeLabel.text = total.convertToFileSize()
                if total > 0 {
                    cell.deleteButton.isHidden = false
                }
                
                if let titleText = cell.titleLabel.text {
                    
                    let cleanTitle =  titleText.replacingOccurrences(of: "*", with: "")
                    
                    cell.accessibilityLabel = "ARTICLES IN PRESS downloaded size of \(cleanTitle) is \(total.convertToFileSize())"
                    
                    if total > 0 {
                        cell.deleteButton.accessibilityLabel = "Delete \(cleanTitle) from Articles in Press section."
                    }
                }
                
            } else if (indexPath as NSIndexPath).row == 1 {
                
                let total = self.aipMultimedia
                cell.sizeLabel.text = total.convertToFileSize()
                if total > 0 {
                    cell.deleteButton.isHidden = false
                }
                
                if let titleText = cell.titleLabel.text {
                    
                    let cleanTitle =  titleText.replacingOccurrences(of: "*", with: "")
                    
                    cell.accessibilityLabel = "ARTICLES IN PRESS downloaded size of \(cleanTitle) is \(total.convertToFileSize())"
                    
                    if total > 0 {
                        cell.deleteButton.accessibilityLabel = "Delete \(cleanTitle) from Articles in Press section."
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = tableViewData[section]
        return section.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "OVERALL"
        } else if section == 1 {
            return "ISSUES"
        } else if section == 2 {
            return ""
        } else if section == 3 {
            return "ARTICLES IN PRESS"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else if section == 1 {
            return nil
        } else if section == 2 {
            return nil
        } else if section == 3 {
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
        
        if section == 3 {

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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = tableViewData[(indexPath as NSIndexPath).section]
        let row = section[(indexPath as NSIndexPath).row]
        if row == "Individual Issues" {
            let usageIssueVC = UsageIssueViewController(journal: journal)
            usageIssueVC.shouldShowHeadlineView = self.shouldShowHeadlineView
            navigationController?.pushViewController(usageIssueVC, animated: true)
        }
    }
    
    func usageJournalTableViewCellDidClickDelete(_ indexPath: IndexPath) {
        deleteItemAtIndex(indexPath)
    }
    
    func deleteItemAtIndex(_ indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 0 {
                let alertVC = Alerts.Delete({ (delete) in
                    if delete == true {
                        ContentKit.SharedInstance.deleteJournal(self.journal, onlyMultimedia: false, completion: { (success) in
                            if success == true {
                                performOnMainThread({
                                    self.updateIssueData()
                                    self.tableView.reloadData()
                                    let alertVC = Alerts.ArticlesDeleted()
                                    self.present(alertVC, animated: true, completion: nil)
                                })
                            }
                        })
                    }
                })
                present(alertVC, animated: true, completion: nil)
            } else if (indexPath as NSIndexPath).row == 1 {
                let alertVC = Alerts.Delete({ (delete) in
                    if delete == true {
                        ContentKit.SharedInstance.deleteJournal(self.journal, onlyMultimedia: true, completion: { (success) in
                            if success == true {
                                performOnMainThread({
                                    self.updateIssueData()
                                    self.tableView.reloadData()
                                    let alertVC = Alerts.ArticlesDeleted()
                                    self.present(alertVC, animated: true, completion: nil)
                                })
                            }
                        })
                    }
                })
                present(alertVC, animated: true, completion: nil)
            }
        } else if (indexPath as NSIndexPath).section == 1 {
            if (indexPath as NSIndexPath).row == 0 {
                let alertVC = Alerts.Delete({ (delete) in
                    if delete == true {
                        ContentKit.SharedInstance.deleteJournalIssues(self.journal, onlyMultimedia: false, completion: { (success) in
                            if success == true {
                                performOnMainThread({
                                    self.updateIssueData()
                                    self.tableView.reloadData()
                                    let alertVC = Alerts.ArticlesDeleted()
                                    self.present(alertVC, animated: true, completion: nil)
                                })
                            }
                        })
                    }
                })
                present(alertVC, animated: true, completion: nil)
            } else if (indexPath as NSIndexPath).row == 1 {
                let alertVC = Alerts.Delete({ (delete) in
                    if delete == true {
                        ContentKit.SharedInstance.deleteJournalIssues(self.journal, onlyMultimedia: true, completion: { (success) in
                            if success == true {
                                performOnMainThread({
                                    self.updateIssueData()
                                    self.tableView.reloadData()
                                    let alertVC = Alerts.ArticlesDeleted()
                                    self.present(alertVC, animated: true, completion: nil)
                                })
                            }
                        })
                    }
                })
                present(alertVC, animated: true, completion: nil)
            }
        } else if (indexPath as NSIndexPath).section == 2 {

        } else if (indexPath as NSIndexPath).section == 3 {
            if (indexPath as NSIndexPath).row == 0 {
                let alertVC = Alerts.Delete({ (delete) in
                    if delete == true {
                        ContentKit.SharedInstance.deleteJournalAIPs(self.journal, onlyMultimedia: false, completion: { (success) in
                            if success == true {
                                performOnMainThread({
                                    self.updateIssueData()
                                    self.tableView.reloadData()
                                    let alertVC = Alerts.ArticlesDeleted()
                                    self.present(alertVC, animated: true, completion: nil)
                                })
                            }
                        })
                    }
                })
                present(alertVC, animated: true, completion: nil)
            } else if (indexPath as NSIndexPath).row == 1 {
                let alertVC = Alerts.Delete({ (delete) in
                    if delete == true {
                        ContentKit.SharedInstance.deleteJournalAIPs(self.journal, onlyMultimedia: true, completion: { (success) in
                            if success == true {
                                performOnMainThread({
                                    self.updateIssueData()
                                    self.tableView.reloadData()
                                    let alertVC = Alerts.ArticlesDeleted()
                                    self.present(alertVC, animated: true, completion: nil)
                                })
                            }
                        })
                    }
                })
                present(alertVC, animated: true, completion: nil)
            }
        }
    }
}
