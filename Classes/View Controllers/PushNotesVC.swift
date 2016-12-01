//
//  PushNotesVC.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 6/27/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography


class PushNotesVC: JBSMViewController, UITableViewDataSource, UITableViewDelegate {
    
    fileprivate let tableView = UITableView()
    
    /*  Will most likely make this an array containing dictionaries.
        Each cell will set key (ex. "Alerts") to its textLabel,
        value ("Active"/"Inactive") to its detailTextLabel.
    */
    fileprivate var tableViewData = [[String: Bool]]()
    fileprivate let tableDataKeys = ["Alerts","Automatic Download"]
    fileprivate let dataCount = 2
    
    //  MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(updateTableView(_:)),
                                                 name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewDidAppear(animated)
        
        if self.navigationController!.viewControllers.contains(self) == false {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    
    //  MARK: Setup
    
    fileprivate func setup() {
        setupSubviews()
        updateTableViewData()
        setupTableView()
        setupAutolayout()

        navigationItem.title = screenTitleApp

        view.backgroundColor = UIColor.groupTableViewBackground
        tableView.backgroundColor = UIColor.clear
    }
    
    fileprivate func setupSubviews() {
        view.addSubview(tableView)
    }
    
    fileprivate func updateTableViewData() {

        var pushSetting = false
        
        if let settings = UIApplication.shared.currentUserNotificationSettings {
            if settings.types.contains(.alert) {
            
                pushSetting = true
            }
        }
        
        if tableViewData.count > 0 {
            tableViewData.removeAll()
        }
        
        //  Check this runs twice
        for index in 0...(dataCount - 1) {
            let key = tableDataKeys[index]
            
            var dictionary = [String: Bool]()
            dictionary[key] = key == "Alerts" || key == "Automatic Download" ? pushSetting :
                                                                                      false;
            tableViewData.insert(dictionary, at: index)
        }
    }
    
    //  TODO: Get rid of extra rows in tableView
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
        tableView.register(PushNotesTableCell.self, forCellReuseIdentifier: PushNotesTableCell.cellID)
        tableView.alwaysBounceVertical = false
    }
    
    fileprivate func setupAutolayout() {
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
    
    func updateTableView(_ notification: Foundation.Notification) {
        updateTableViewData()
        tableView.reloadData()
    }
    
    fileprivate func footerView() -> UITextView {
        
        let textView = UITextView.init(frame: CGRect(x: 0, y: 15, width: 0, height: 0))
        textView.text = "Notifications can be controlled from your device's Settings Application."

        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.gray
        textView.font = UIFont.systemFont(ofSize: 13)
        textView.sizeToFit()
        textView.textContainerInset = UIEdgeInsets(top: Config.Padding.Default, left: Config.Padding.Default,
                                                                              bottom: 0, right: 0)
        textView.isEditable = false
        textView.isSelectable = false

        return textView
    }
    
    
    //  MARK: TableView 
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PushNotesTableCell.cellID) as! PushNotesTableCell
        let index = (indexPath as NSIndexPath).row
        
        let cellDictionary = tableViewData[index] as [String: Bool]!

        cell.textLabel?.text = cellDictionary?.keys.first
        
        //  Need to add/configure this label manually
        cell.statusLabel.text = cellDictionary?.values.first == true ? "Active" : "Disabled"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataCount
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 0)
        if screenType == .mobile {
            let header = UILabel.init(frame: frame)
            header.text = "   Push Notifications"
            header.backgroundColor = UIColor.gray
            header.textColor = UIColor.white
            header.font = UIFont.boldSystemFont(ofSize: 21)
            return header
            
        } else {
            let header = UIView.init(frame: frame)
            header.backgroundColor = UIColor.groupTableViewBackground
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if screenType == .mobile {
            return 42
        } else {
            return 32
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        let dummyFooter = footerView()

        return footerView().frame.height + dummyFooter.frame.origin.y
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return footerView()
    }
}
