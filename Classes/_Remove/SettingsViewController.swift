//
//  SettingsViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 11/16/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let cellIdentifier = "SettingsTableViewCell"

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tableViewDataSource = SettingsTableViewData()
    var publisher: Publisher!
    var journal: Journal?
    
    // MARK: - Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        setupBarButtonItems()
        publisher = DatabaseManager.SharedInstance.getAppPublisher()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - UITableViewDelegate -
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = tableViewDataSource.sections[indexPath.section].items[indexPath.row]
        if item == Announcements {
            loadAnnouncements()
        } else if item == Search {
            loadSearch()
        } else if item == Support {
            loadSupport()
        } else if item == Feedback {
            loadFeedback()
        } else if item == TermsAndConditions {
            loadTermsAndConditions()
        } else if item == FAQs {
            loadFAQs()
        } else if item == Usage {
            loadUsage()
        } else if item == PushNotifications {
            loadPushNotifications()
        } else if item == Login {
            loadLogin()
        } else if item == Downloads {
            loadDownloads()
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Selections -
    
    func loadAnnouncements() {
        let announcementVC = AnnouncementsViewController()
        navigationController?.pushViewController(announcementVC, animated: true)
    }
    
    func loadSearch() {
        /*let information = SearchInformation()
        information.currentJournal = currentJournal
        
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)*/
    }
    
    func loadSupport() {
        let webViewController = WebViewController()
        webViewController.pageTitle = "Support"
        if let supportHTML = publisher.support {
            webViewController.string = supportHTML
            webViewController.contentType = WebViewControllerContentTypes.String
        } else {
            webViewController.url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("support", ofType: "html")!)
            webViewController.contentType = WebViewControllerContentTypes.URL
        }
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func loadFeedback() {
        let feedbackVC = FeedbackViewController()
        navigationController?.pushViewController(feedbackVC, animated: true)
    }
    
    func loadTermsAndConditions() {
        let supportPath = NSBundle.mainBundle().pathForResource("terms", ofType: "html")
        let webViewController = WebViewController()
        webViewController.url = NSURL(fileURLWithPath: supportPath!)
        webViewController.contentType = WebViewControllerContentTypes.URL
        webViewController.pageTitle = "Terms & Conditions"
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func loadFAQs() {
        let supportPath = NSBundle.mainBundle().pathForResource("faq", ofType: "html")
        let webViewController = WebViewController()
        webViewController.url = NSURL(fileURLWithPath: supportPath!)
        webViewController.contentType = WebViewControllerContentTypes.URL
        webViewController.pageTitle = "FAQs"
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func loadUsage() {
        let usageVC = UsageViewController()
        navigationController?.pushViewController(usageVC, animated: true)
    }
    
    func loadPushNotifications() {
        
    }
    
    func loadLogin() {
        let ad = UIApplication.sharedApplication().delegate as! AppDelegate
        if let journal = ad.currentJournal {
            if let loginVC = LoginViewController(journal: journal) {
                navigationController?.pushViewController(loginVC, animated: true)
            } else {
                log.error("Unable to create Login View Controller")
            }
        }
    }
    
    func loadDownloads() {
        /*let downloadsVC = DLSectionsViewController()
        navigationController?.pushViewController(downloadsVC, animated: true)*/
    }
    
    // MARK: - UITableViewDelegate -
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableViewDataSource.sections[section].title == nil {
            return 0
        }
        return 34
    }
    
    // MARk: - UITableViewDataSource -
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = tableViewDataSource.sections[indexPath.section].items[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! SettingsTableViewCell
        cell.textLabel?.text = row
        if row == Downloads {
            /*if DLManager.sharedInstance.sections.count > 0 {
                cell.textLabel?.text = "\(Downloads) (\(DLManager.sharedInstance.sections.count))"
            } else {
                cell.textLabel?.text = "Downloads"
            }*/
            
        }
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 34))
        view.backgroundColor = AppConfiguration.NavigationBarColor
        
        let label = UILabel()
        label.text = tableViewDataSource.sections[section].title
        label.font = AppConfiguration.DefaultTitleFont
        label.textColor = UIColor.whiteColor()
        view.addSubview(label)
        
        constrain(label) { (label) -> () in
            label.top == label.superview!.top
            label.left == label.superview!.left + 16
            label.bottom == label.superview!.bottom
            label.right == label.superview!.right
        }
        return view
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableViewDataSource.sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSource.sections[section].items.count
    }
    
    // MARK: - Other -
    
    func setupBarButtonItems() {
        let closeBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .Plain, target: self, action: #selector(closeButtonClicked(_:)))
        self.navigationItem.leftBarButtonItems = [closeBarButtonItem]
    }
    
    func closeButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSections(sections: Int) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }
}

// MARK: - Table View Data -

private let Announcements = "Announcements"
private let Search = "Search"

private let SectionTwo = "INFO"
private let Support = "Support"
private let Feedback = "Feedback"
private let TermsAndConditions = "Terms & Conditions"
private let FAQs = "FAQs"
private let HowToUseTheApp = "How To Use the App"

private let SectionThree = "SETTINGS"
private let Usage = "Usage"
private let PushNotifications = "Push Notifications"
private let Downloads = "Downloads"
private let Logout = "Logout"
private let Login = "Login"

class SettingsTableViewData {
    var sections:[SettingsTableViewSection] = []
    
    init() {
        let sectionOne = SettingsTableViewSection(title: nil, items: [Announcements, Search])
        let sectionTwo = SettingsTableViewSection(title: SectionTwo, items: [Support, Feedback, TermsAndConditions, FAQs, HowToUseTheApp])
        let ad = UIApplication.sharedApplication().delegate as! AppDelegate
        var sectionThree: SettingsTableViewSection
        if let journal = ad.currentJournal {
            sectionThree = SettingsTableViewSection(title: SectionThree, items: [Downloads, Usage, PushNotifications, Login])
        } else {
            sectionThree = SettingsTableViewSection(title: SectionThree, items: [Downloads, Usage, PushNotifications])
        }
        
        sections = [sectionOne, sectionTwo, sectionThree]
    }
}

class SettingsTableViewSection {
    var title: String?
    var items:[String] = []
    
    init (title:String?, items:[String]) {
        self.title = title
        self.items = items
    }
}
