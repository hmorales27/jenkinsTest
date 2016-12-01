//
//  TopArticlesTableVC.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 11/4/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation


protocol TopArticleTableVcDelegate: class {
    func didSelectArticleAt(indexPath: IndexPath)
    func didSelectViewAllTopArticles()
}


class TopArticlesTableVC: UITableViewController {
    
    var currentJournal: Journal?
    
    public var tableViewData: [Article] = []
    var authorCollapsed: [Bool] = []
    var shouldUseNewUi = USE_NEW_UI
    
    var delegate: TopArticleTableVcDelegate?
    internal var tracked = false
    internal var analyticsInstance = AnalyticsHelper.MainInstance
    
    //  MARK: - Setup -
    
    init(journal: Journal) {
        super.init(nibName: nil, bundle: nil)
        self.currentJournal = journal
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.Identifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        tableView.backgroundColor = Config.Colors.SingleJournalBackgroundColor
        tableView.separatorColor = Config.Colors.SingleJournalBackgroundColor
        
        tableView.estimatedRowHeight = 66.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.showsVerticalScrollIndicator = false
        
        let layers = [view.layer, tableView.layer]
        
        for layer in layers {
            layer.masksToBounds = false
        }
    }
    
    
    //  MARK: - Updating - 
    
    func loadTableViewData() {
        guard let journal = currentJournal else {
            return
        }
        let topArticles = journal.allTopArticles
        if topArticles.count == 0 {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
            if tableViewData != topArticles {
                tableViewData = topArticles
            }
            tableView.reloadData()
        }
        trackTopArticlesView()
    }
    
    // MARK: - Table View Delegate -
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        while authorCollapsed.count < tableViewData.count {
            authorCollapsed.append(true)
        }
        
        let index = shouldUseNewUi ? indexPath.section : indexPath.row
        
        if index < tableViewData.count || parent == nil {
            let _cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.Identifier) as! ArticleTableViewCell
            
            guard let article = articleForIndexPath(indexPath: indexPath) else { return _cell }
            
            _cell.update(article)
            _cell.subTypeView.isHidden = true
            _cell.subTypeView.layoutConstraints.height?.constant = 0
            _cell.indexPath = indexPath
            _cell.parentJbsmViewController = parent as? JBSMViewController
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
            return _cell
            
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Continue..."
            cell.textLabel?.accessibilityLabel = "Continue button"
            cell.textLabel?.textAlignment = NSTextAlignment.center
            
            cell.contentView.backgroundColor = shouldUseNewUi ? view.backgroundColor : UIColor.white
            
            cell.backgroundColor = Config.Colors.SingleJournalBackgroundColor
            
            return cell
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if shouldUseNewUi {
            return 1
        }
        
        guard let _parent = parent else {
            return tableViewData.count
        }
        
        let rowCount =  _parent is TopArticlesMasterVC ? tableViewData.count : tableViewData.count
        
        return rowCount
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let index = shouldUseNewUi ? indexPath.section : indexPath.row
        
        guard index < tableViewData.count // && parent == nil
            else {
            
            delegate?.didSelectViewAllTopArticles()
            return
        }
        
        delegate?.didSelectArticleAt(indexPath: indexPath)
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let _parent = parent, shouldUseNewUi else {

                return 1
        }
        
        let sectionCount = _parent is TopArticlesMasterVC ? tableViewData.count : tableViewData.count
        
        return sectionCount
    }
    
    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if shouldUseNewUi {
            return 5
            
        } else {
            return 0
        }
    }
    
    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    //  MARK: - Utility -
    
    func articleForIndexPath(indexPath: IndexPath) -> Article? {
        let index = shouldUseNewUi ? indexPath.section : indexPath.row
        
        guard index < tableViewData.count else { return nil }
        
        return shouldUseNewUi ? tableViewData[indexPath.section] : tableViewData[indexPath.row]
    }
    
    //MARK: - Analytics
    
    func trackTopArticlesView() {
        if !tracked {
            let stateContentData = [AnalyticsConstant.TagPageType : Constants.Page.Type.np_gp]
            let pageName = Constants.Page.Name.topArticles
            analyticsInstance.trackState(pageName, stateContentData: stateContentData)
            tracked = true
        }
    }
}
