//
//  NotesViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 4/10/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class NotesViewController: SLViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()
    let headlineView = HeadlineView()
    
    let advertisementVC = AdvertisementViewController()
    
    var tableViewData: [Note] = []
    var authorExpandedIndexPaths: [IndexPath] = []
    
    var authorCollapsed: [Bool] = []
    
    // MARK: - Initializer -
    
    override init(journal: Journal) {
        super.init(journal: journal)
        self.selectedType = SLTableViewItemType.notes
        addChildViewController(advertisementVC)
        advertisementVC.didMove(toParentViewController: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        analyticsScreenName = Constants.Page.Name.Notes
        analyticsScreenType = Constants.Page.Type.np_gp
        setup()
        super.viewDidLoad()
        advertisementVC.setup(AdType.iPadPortrait, journal: currentJournal!)
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
        setupHeadlineView()
    }
    
    func setupSubviews() {
        view.addSubview(headlineView)
        view.addSubview(tableView)
        view.addSubview(advertisementVC.view)
    }
    
    func setupAutoLayout() {
        
        guard let advertisementView = advertisementVC.view else { return }
        
        let subviews = [
            tableView,
            headlineView,
            advertisementView
        ]
        
        constrain(subviews) { (views) in
            
            let tableV = views[0]
            let headlineV = views[1]
            let adV = views[2]
            
            guard let superview = tableV.superview else {
                return
            }
            
            headlineV.top == superview.top
            headlineV.right == superview.right
            headlineV.left == superview.left
            
            tableV.top == headlineV.bottom
            tableV.right == superview.right
            tableV.left == superview.left
            
            adV.top == tableV.bottom
            adV.right == superview.right
            advertisementVC.bottomConstraint = (adV.bottom == superview.bottom)
            adV.left == superview.left
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NotesTableViewCell.self, forCellReuseIdentifier: NotesTableViewCell.Identifier)
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
        tableView.estimatedRowHeight = 66.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor.clear
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        guard let journal = currentJournal else {
            return
        }
        switch screenType {
        case .mobile:
            title = journal.journalTitleIPhone
        case .tablet:
            title = journal.journalTitle
        }
        
        
        performOnMainThread {
            self.navigationItem.leftBarButtonItem = self.menuBarButtonItem
            switch self.screenType {
            case .mobile:
                self.navigationItem.rightBarButtonItems = nil
            case .tablet:
                self.navigationItem.rightBarButtonItems = self.rightBarButtonItems
            }
        }
    }
    
    func setupHeadlineView() {
        headlineView.update("Notes")
    }
    
    // MARK: - Update -
    
    func update() {
        DispatchQueue.main.async {
            guard let journal = self.currentJournal else {
                return
            }
            self.tableViewData = DatabaseManager.SharedInstance.getNotes(journal: journal)
            if self.tableViewData.count == 0 {
                
                if self.screenType == .tablet {
                    let backgroundView = UIView()
                    let imageView = UIImageView(image: UIImage(named: "EmptyNotesTablet"))
                    backgroundView.addSubview(imageView)
                    constrain(imageView, block: { (imageV) in
                        guard let superview = imageV.superview else {
                            return
                        }
                        imageV.centerY == superview.centerY
                        imageV.centerX == superview.centerX
                        imageV.width == 540
                        imageV.height == 273
                    })
                    self.tableView.backgroundView = backgroundView
                } else {
                    let backgroundView = UIView()
                    let imageView = UIImageView(image: UIImage(named: "EmptyNotesMobile"))
                    backgroundView.addSubview(imageView)
                    constrain(imageView, block: { (imageV) in
                        guard let superview = imageV.superview else {
                            return
                        }
                        imageV.centerY == superview.centerY
                        imageV.centerX == superview.centerX
                        imageV.width == 320
                        imageV.height == 384
                    })
                    self.tableView.backgroundView = backgroundView
                }
            } else {
                self.tableView.backgroundView = nil
            }
            self.tableView.reloadData()
        }
    }
    
    func toggleAuthorList(_ indexPath: IndexPath) {
        for _ in authorCollapsed.count..<(tableViewData.count + 1){
            authorCollapsed.append(true)
        }
        authorCollapsed[(indexPath as NSIndexPath).row] = !authorCollapsed[(indexPath as NSIndexPath).row]
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    
    
    // MARK: - Table View -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        while authorCollapsed.count < tableViewData.count {
            authorCollapsed.append(true)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: NotesTableViewCell.Identifier) as! NotesTableViewCell
        cell.indexPath = indexPath
        cell.notesVC = self
        let note = tableViewData[(indexPath as NSIndexPath).row]
        if !authorCollapsed[(indexPath as NSIndexPath).row] {
            cell.articleAuthorsLabel.numberOfLines = 0
            cell.authorsPlusButton.setTitle("-", for: UIControlState())
        }else {
            cell.articleAuthorsLabel.numberOfLines = 2
            cell.authorsPlusButton.setTitle("+", for: UIControlState())
        }
        cell.update(note: note)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let article = tableViewData[(indexPath as NSIndexPath).row].article
        let allArticles = DatabaseManager.SharedInstance.getArticles(journal: article!.journal, withNotes: true)
        let articlePC = ArticlePagerController(article: article!, articleArray: allArticles)
        articlePC.backTitleString = "Notes"
        articlePC.passedInNote = tableViewData[(indexPath as NSIndexPath).row]
        articlePC.currentJournal = self.currentJournal
        navigationController?.pushViewController(articlePC, animated: true)
    }
}
