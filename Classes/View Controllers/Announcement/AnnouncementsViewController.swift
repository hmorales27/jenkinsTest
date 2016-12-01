//
//  Announcements.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/2/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let CellIdentifier = "AnnouncementCell"
private let NavigationTitle = "Announcements"


protocol AnnouncementControllerDelegate: class {
    
    func announcementsDidUpdate()
}

class AnnouncementsViewController: SLViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties -
    
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    fileprivate var tableViewData:[Announcement] = []
    
    var shouldShowMenuButton = false
    weak var delegate: AnnouncementControllerDelegate?
    

    
    // MARK: - Initializer -
    
    override init() {
        super.init()
    }
    
    override init(journal: Journal) {
        super.init(journal: journal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        setup()
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        update()
    }
    
    // MARK: - Setup -
    
    func setup() {
        setupSubviews()
        setupTableView()
        setupAutoLayout()
        setupNavigationBar()
    }
    
    fileprivate func setupSubviews() {
        view.addSubview(tableView)
    }
    
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        tableView.alwaysBounceVertical = false
    }
    
    fileprivate func setupAutoLayout() {
        constrain(tableView) { (tableView) -> () in
            guard let superview = tableView.superview else {
                return
            }
            
            tableView.top == superview.top
            tableView.right == superview.right
            tableView.bottom == superview.bottom
            tableView.left == superview.left
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        updateNavigationTitle()
        updateNavigationItemsForScreenType(screenType)
    }
    
    override func updateNavigationTitle() {
        if let _journal = currentJournal {
            navigationItem.title = _journal.journalTitle
            navigationItem.accessibilityLabel = _journal.journalTitle
            navigationItem.accessibilityTraits = UIAccessibilityTraitNone
        }
    }
    
    func updateNavigationItemsForScreenType(_ type: ScreenType) {
        DispatchQueue.main.async {
            if self.shouldShowMenuButton == true {
                self.navigationItem.leftBarButtonItem = self.menuBarButtonItem
            } else {
                self.title = "Announcements"
            }
        }
    }
    
    
    // MARK: - Update -
    
    func update() {
        updateTableViewData()
        //  Check if is iPad, and call rightBarButton items?
    }
    
    fileprivate func updateTableViewData() {
        tableViewData = DatabaseManager.SharedInstance.getAllAnnouncements()
        tableView.reloadData()
    }
    
    
    // MARK: - Table View -
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)!
        let announcement = tableViewData[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = announcement.announcementTitle
        cell.textLabel?.textColor = UIColor.blue
        if announcement.userRead == true {
            cell.textLabel?.font = UIFont.systemFontOfSize(16, weight: .Regular)
        } else {
            cell.textLabel?.font = UIFont.systemFontOfSize(16, weight: .Bold)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let announcement = tableViewData[(indexPath as NSIndexPath).row]
        let announcementVC = AnnouncementViewController(announcement: announcement)
        navigationController?.pushViewController(announcementVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            let announcement = tableViewData[(indexPath as NSIndexPath).row]
            DatabaseManager.SharedInstance.performChangesAndSave({ 
                announcement.userDeleted = true
                self.update()
                tableView.reloadData()
                self.delegate?.announcementsDidUpdate()
            })
        }
    }
}
