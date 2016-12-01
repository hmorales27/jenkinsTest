//
//  SettingsVC.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/13/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let CellIdentifier = "SettingsTableViewCell"

class SettingsVC: JBSMViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    var tableViewData: [String] = []
    
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        analyticsScreenName = Constants.Page.Name.Settings
        analyticsScreenType = Constants.Page.Type.ap_my
        super.viewDidAppear(animated)
        update()
    }
    
    // MARK: - Setup -
    
    func setup() {
        setupView()
        setupSubviews()
        setupAutoLayout()
        setupTableView()
        setupNavigationBar()
    }
    
    func setupView() {
        view.backgroundColor = UIColor.lightGray()
    }
    
    func setupSubviews() {
        view.addSubview(tableView)
    }
    
    func setupAutoLayout() {
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
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        tableView.layer.cornerRadius = 4
    }
    
    override func setupNavigationBar() {
        title = "Settings"
    }
    
    // MARK: - Update -
    
    func update() {
        updateTableViewData()
    }
    
    func updateTableViewData() {
        var tvc = ["Usage", "Push Notifications"]
        if currentJournal != .none {
            if currentJournal?.isAuthenticated == true {
                tvc.append("Logout")
            } else {
                tvc.append("Login")
            }
        }
        tableViewData = tvc
        tableView.reloadData()
    }
    
    // MARK: - Table View -
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = tableViewData[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = tableViewData[(indexPath as NSIndexPath).row]
        if row == "Usage" {
            let usageVC = UsageViewController()
            usageVC.enabled = false
            usageVC.shouldShowHeadlineView = false
            navigationController?.pushViewController(usageVC, animated: true)
        } else if row == "Push Notifications" {
            let pushVC = PushNotesVC()
            navigationController?.pushViewController(pushVC, animated: true)
        } else if row == "Login" {

            if NETWORK_AVAILABLE == false {
                
                let alertVC = Alerts.NoNetwork()
                performOnMainThread({
                    self.present(alertVC, animated: true, completion: nil)
                })
            }
            
            else if NETWORK_AVAILABLE == true {
            
                if let journal = currentJournal {
                    
                    performOnMainThread({
                        let alert = Alerts.pleaseWait()
                        self.present(alert, animated: true, completion: {
                            
                            let loginVC = LoginViewController(journal: journal)
                            loginVC.isDismissable = true
                            let navigationVC = UINavigationController(rootViewController: loginVC)
                            navigationVC.modalPresentationStyle = .formSheet
                            
                            self.dismiss(animated: true, completion: {
                                
                                self.present(navigationVC, animated: true, completion: nil)
                            })
                        })
                    })
                }
            }
        } else if row == "Logout" {            
            
            let journals = DatabaseManager.SharedInstance.getAllJournals()
            
            for journal in journals {
            
                guard let authentication = journal.authentication else { return }
                DatabaseManager.SharedInstance.performChangesAndSave({
                    DatabaseManager.SharedInstance.moc?.delete(authentication)
                    DatabaseManager.SharedInstance.moc?.refresh(journal, mergeChanges: true)
                    self.updateTableViewData()
                    let alertVC = UIAlertController(title: "Message", message: "You have successfully logged out.", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertVC, animated: true, completion: nil)
                })
            }
        }
    }
}
