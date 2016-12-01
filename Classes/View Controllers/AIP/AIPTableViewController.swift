//
//  AIPTableViewController.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/1/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit

protocol AIPTableViewDelegate: class {
    func aipTableViewDidUpdateEditedSelection(_ indexPath: [NSIndexPath])
    func aipTableViewDidSelectArticle(article: Article, push: Bool)
    func aipTableViewArticleWasDeleted()
}

private let IN_PRESS_TEXT = "In Press Corrected Proof | Available Online "

class AIPTableViewController: UITableViewController, CollectionDataSourceDelegate {
    
    //var tableViewData: SectionsData?
    
    var dataSource: CollectionDataSource!
    
    let selected = "Selected, double-tap to deselect. "
    let deselected = "Not selected, double-tap to select. "
    
    fileprivate var selectedIndex: Int?
    
    var allAIPs: [Article] {
        return dataSource.allArticles
    }
    
    var selectedAIPs: [Article] {
        var selectedAIPs = [Article]()
        
        guard let selectedPaths = tableView.indexPathsForSelectedRows else {
            
            return []
        }
        
        for indexPath in selectedPaths {
            selectedAIPs.append(allAIPs[(indexPath as NSIndexPath).row])
        }
        return selectedAIPs
    }
    
    weak var delegate: AIPTableViewDelegate?
    
    // MARK: - Initializer -
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupTableView()
        dataSource = CollectionDataSource()
        dataSource.dataSourceDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    fileprivate func setupTableView() {
        tableView.register(AIPTableViewCell.self, forCellReuseIdentifier: AIPTableViewCell.Identifier)
        tableView.estimatedRowHeight = 66.0
        tableView.rowHeight = UITableViewAutomaticDimension
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
    }
    
    func updateDataSource(articles: [Article]) {
        
        dataSource.update(items: articles)
        
        performOnMainThread { 
            self.tableView.reloadData()
        }
    }

    // MARK: - Delegate & Data Source -
    
    func itemForIndexPath(_ indexPath: IndexPath) -> Article? {
        return dataSource[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].article
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionData = dataSource[section]
        let sectionView = SectionsData.TableHeaderView()
        sectionView.view.update(sectionData.title, section: section, collapsed: sectionData.collapsed)
        sectionView.view.viewDelegate = self
        return sectionView
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AIPTableViewCell.Identifier) as! AIPTableViewCell
        let item = dataSource[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]

        if let article = dataSource[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].article {
            cell.titleTextLabel.text = article.cleanArticleTitle
            cell.setAuthorLabel(article.author)
            cell.setArticleInfo(article)
            if let dateOfRelease = article.dateOfRelease {
                cell.aipLabel.text = IN_PRESS_TEXT + DateFormatter(dateFormat: "dd MMM, YYYY").string(from: dateOfRelease)
            }

            if item.expandAuthorList == true {
                
                cell.authorTextLabel.numberOfLines = 0
                cell.authorsPlusButton.setTitle("-", for: UIControlState())
            } else {
                cell.authorTextLabel.numberOfLines = 2
                cell.authorsPlusButton.setTitle("+", for: UIControlState())
            }

            if article.openAccess.oaIdentifier != 0 {
                cell.openAccessLabel.text = article.openAccess.oaStatusDisplay
                cell.openAccessLabel.isHidden = false
            } else {
                cell.openAccessLabel.isHidden = true
            }
            
            cell.tableViewController = self
            cell.delegate = self
            
            cell.indexPath = indexPath
            
            cell.update(article)
            
            if var label = cell.accessibilityLabel {
                
                if tableView.isEditing == false {
                    
                    label = label.replacingOccurrences(of: selected, with: "")
                    label = label.replacingOccurrences(of: deselected, with: "")
                    
                    return cell
                }
            
            } else if cell.accessibilityLabel == nil {
                
                if let text = cell.titleTextLabel.text, let aipText = cell.aipLabel.text {
                    
                    cell.accessibilityLabel = "Article: " + text + aipText.replacingOccurrences(of: "|", with: "")
                }
            }
            
            if tableView.isEditing == true {
                if let text = cell.titleTextLabel.text, let aipText = cell.aipLabel.text {
                    
                    cell.accessibilityLabel = deselected + "Article: " + text + aipText.replacingOccurrences(of: "|", with: "")
                }
            }
        }
        return cell
    }
    
    func articleForIndexPath(_ indexPath: IndexPath) -> Article? {
        return dataSource[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].article
    }

    func toggleAuthorList(indexPath: IndexPath) {
        
        let item = dataSource[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        if item.expandAuthorList == true {
            item.expandAuthorList = false
        } else {
            item.expandAuthorList = true
        }
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let article = articleForIndexPath(indexPath) else { return }
        
        if tableView.isEditing == false {
            
            tableView.deselectRow(at: indexPath, animated: true)
            delegate?.aipTableViewDidSelectArticle(article: article, push: true)
            
        } else {
            
            switch article.downloadInfo.fullTextDownloadStatus {
            case .downloaded, .downloading:
                tableView.deselectRow(at: indexPath, animated: true)
                return
            default:
                break
            }
            
            let item = dataSource[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
            item.selectedAIP = true
            
            if let indexPaths = tableView.indexPathsForSelectedRows {
                delegate?.aipTableViewDidUpdateEditedSelection(indexPaths as [NSIndexPath])
            } else {
                delegate?.aipTableViewDidUpdateEditedSelection([])
            }
            
            guard let cell = tableView.cellForRow(at: indexPath) else {
                
                return
            }
            
            if var label = cell.accessibilityLabel {
                if label.contains(deselected) == true {
                    
                    label = label.replacingOccurrences(of: deselected, with: selected)
                    cell.accessibilityLabel = label
                    
                } else if label.contains(deselected) == false {
                
                    cell.accessibilityLabel = "Selected, " + label
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if isEditing == true {
            
            let item = dataSource[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
            item.selectedAIP = false
            
            if let indexPaths = tableView.indexPathsForSelectedRows {
                delegate?.aipTableViewDidUpdateEditedSelection(indexPaths as [NSIndexPath])
            } else {
                delegate?.aipTableViewDidUpdateEditedSelection([])
            }
            
            guard let cell = tableView.cellForRow(at: indexPath) else {
                
                return
            }
            
            if let label = cell.accessibilityLabel {
             
                cell.accessibilityLabel = label.replacingOccurrences(of: selected, with: deselected)
            }
        }
    }
        
    func collectionDataSourceAllSectionsCollapsed() {
        performOnMainThread {
            self.tableView.reloadData()
        }
    }
    func collectionDataSourceCollapseSection(_ section: CollectionSection, atIndex index: Int) {
        performOnMainThread {
            self.tableView.reloadSections(IndexSet(integer: index), with: .none)
        }
    }
    func collectionDataSourceAllSectionsExpanded() {
        performOnMainThread {
            self.tableView.reloadData()
            var sectionInt = 0
            for section in self.dataSource {
                var row = 0
                for item in section {
                    if item.selectedAIP {
                        let indexPath = IndexPath(item: row, section: sectionInt)
                        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    }
                    row += 1
                }
                sectionInt += 1
            }
        }
    }
    func collectionDataSourceExpandSection(_ section: CollectionSection, atIndex index: Int) {
        performOnMainThread {
            self.tableView.reloadData()
            self.tableView.reloadSections(NSIndexSet(index: index) as IndexSet, with: .none)
            var row = 0
            for item in self.dataSource[index] {
                if item.selectedAIP {
                    let indexPath = IndexPath(item: row, section: index)
                    self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
                row += 1
            }
        }
    }
    
    func collectionDataSourceNeedsTableViewRefresh() {
        
    }

}

extension AIPTableViewController: CollectionSectionViewDelegate {
    
    func sectionViewDidCollapseAll() {
        dataSource.collapseAll()
    }
    func sectionViewDidExpandAll() {
        dataSource.expandAll()
    }
    func sectionViewDidCollapseAtIndex(_ index: Int) {
        dataSource.collapse(atIndex: index)
    }
    func sectionViewDidExpandAtIndex(_ index: Int) {
        dataSource.expand(atIndex: index)
    }
}

// MARK: - Analytics -

extension AIPTableViewController {
    
    func sendContentDownloadAnalytics(article: Article) {
        let productInfo: String = getProductInfoForAnalytics(article: article)
        let contentValues: [String: AnyObject] = getMapForContentValuesForAnalytics(article: article)
        AnalyticsHelper.MainInstance.contentDownloadAnalytics(productInfo, contentInfo: contentValues)
    }
    
    func sendContentDownloadAnalytics(issue: Issue) {
        let productInfo: String = getProductInfoForAnalytics(issue: issue)
        let contentValues: [String: AnyObject] = getMapForContentValuesForAnalytics(issue: issue)
        AnalyticsHelper.MainInstance.contentDownloadAnalytics(productInfo, contentInfo: contentValues)
    }
    
    
    func getProductInfoForAnalytics(article: Article) -> String {
        return AnalyticsHelper.MainInstance.createProductInforForEventAction(
            article.articleInfoId,
            fileFormat: Constants.Content.ValueFormatHTML,
            contentType: "xocs:scope-full",
            bibliographicInfo: AnalyticsHelper.MainInstance.createBibliographicInfo(article.issue?.volume, issue: article.issue?.issueNumber),
            articleStatus: "",
            articleTitle: article.articleTitle!.lowercased(),
            accessType: article.journal.accessType
        )
    }
    
    func getMapForContentValuesForAnalytics(article: Article) -> [String: AnyObject] {
        return AnalyticsHelper.MainInstance.createMapForContentUsage(
            article.journal.accessType,
            contentID: article.articleInfoId,
            bibliographic: AnalyticsHelper.MainInstance.createBibliographicInfo(article.issue?.volume, issue: article.issue?.issueNumber),
            contentFormat: Constants.Content.ValueFormatHTML,
            contentInnovationName: nil,
            contentStatus: nil,
            contentTitle: article.articleTitle!.lowercased(),
            contentType: "xocs:scope-full",
            contentViewState: nil
        )
    }
    
    func getProductInfoForAnalytics(issue: Issue) -> String {
        return AnalyticsHelper.MainInstance.createProductInforForEventAction(
            issue.issuePii,
            fileFormat: Constants.Content.ValueFormatHTML,
            contentType: "xocs:scope-full",
            bibliographicInfo: AnalyticsHelper.MainInstance.createBibliographicInfo(issue.volume, issue: issue.issueNumber),
            articleStatus: "",
            articleTitle: issue.issueTitle!.lowercased(),
            accessType: issue.journal.accessType
        )
    }
    
    func getMapForContentValuesForAnalytics(issue: Issue) -> [String: AnyObject] {
        return AnalyticsHelper.MainInstance.createMapForContentUsage(
            issue.journal.accessType,
            contentID: issue.issuePii,
            bibliographic: AnalyticsHelper.MainInstance.createBibliographicInfo(issue.volume, issue: issue.issueNumber),
            contentFormat: Constants.Content.ValueFormatHTML,
            contentInnovationName: nil,
            contentStatus: nil,
            contentTitle: issue.issueTitle!.lowercased(),
            contentType: "xocs:scope-full",
            contentViewState: nil
        )
    }
    
    func selectArticles(_ count: Int) {
        var sectionCount = 0
        var completedCount = 0
        var items: [IndexPath] = []

        while completedCount < count {
            
            for section in dataSource.activeSections {
                
                var itemCount = 0
                for _item in section.activeItems {
                    
                    if completedCount < count {
                        
                        if let article = _item.article {
                            
                            let indexPath = IndexPath(item: itemCount, section: sectionCount)
                            
                            switch article.fullTextDownloadStatus {
                            case .downloaded:
                                self.tableView.deselectRow(at: indexPath, animated: true)
                            default:
                                _item.selectedAIP = true
                                items.append(indexPath)
                                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
                                
                                if let cell = tableView.cellForRow(at: indexPath) {
                                    
                                    if let label = cell.accessibilityLabel {
                                        
                                        cell.accessibilityLabel = label.replacingOccurrences(of: deselected, with: selected)
                                    }
                                }
                            }
                            
                            itemCount += 1
                            completedCount += 1
                        }
                    }
                }
                sectionCount += 1
            }
            completedCount = count
        }
        delegate?.aipTableViewDidUpdateEditedSelection(items as [NSIndexPath])
    }
}

extension AIPTableViewController : AIPCellDelegate {
    
    func articleWasDeleted()  {
        
        //  Update header's article count label
        delegate?.aipTableViewArticleWasDeleted()
    }
    
    
    func showCannotDeleteArticle() {
        
        let alert = Alerts.cannotDelete()
        
        performOnMainThread { 
            self.present(alert, animated: true, completion: nil)
        }
    }
}
