//
//  InfoViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/13/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let CellIdentifier = "SettingsTableViewCell"

private enum InfoItem: String {
    case Settings = "Settings"
    case Feedback = "Feedback"
    case TermsConditions = "Terms & Conditions"
    case FAQ = "FAQs"
    case HowToUseTheApp = "How To Use The App"
    
    func accessibilityLabel() -> String {
        return ""
    }
}

class InfoViewController: JBSMViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    var tableViewData: [String] = []
    
    weak var viewController: UIViewController?
    
    let popoverWidth = 340.0
    let popoverHeight = 380.0
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        analyticsScreenName = Constants.Page.Name.Info
        analyticsScreenType = Constants.Page.Type.np_gp
        
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.preferredContentSize = CGSize(width: 400, height: (44 * 5))
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    }
    
    override func setupNavigationBar() {
        title = "Info"
    }
    
    // MARK: - Update -
    
    func update() {
        updateTableViewData()
    }
    
    func updateTableViewData() {
        tableViewData = ["Support", "Feedback", "Terms & Conditions", "FAQs", "How to use the App"]
        tableView.reloadData()
    }
    
    // MARK: - Table View -
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let item = tableViewData[(indexPath as NSIndexPath).row]
        
        cell.textLabel?.text = item
        
        if item == "FAQs" {
            cell.accessibilityLabel = "F A Q's"
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = tableViewData[(indexPath as NSIndexPath).row]
        if row == "Support" {
            loadSupport()
        } else if row == "Feedback" {
            loadFeedback()
        } else if row == "Terms & Conditions" {
            loadTermsAndConditions()
        } else if row == "FAQs" {
            loadFAQ()
        } else if row == "How to use the App" {
            loadHowToUseTheApp()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func loadFeedback() {
        performOnMainThread { 
            let feedbackVC = FeedbackViewController()
            self.navigationController?.pushViewController(feedbackVC, animated: true)
        }
    }
    
    func loadSupport() {
        let webViewController = WebViewController()
        webViewController.analyticsScreenName = Constants.Page.Name.InfoSupport
        webViewController.analyticsScreenType = Constants.Page.Type.np_gp
        webViewController.enabled = false
        webViewController.string = Strings.SUPPORT_HTML
        webViewController.contentType = WebViewControllerContentTypes.string
        webViewController.pageTitle = "Support"
        webViewController.analyticsScreenName = Constants.Page.Name.InfoSupport
        webViewController.analyticsScreenType = Constants.Page.Type.np_gp
        let bundlePath = Bundle.main.bundlePath
        webViewController.baseURL = URL(fileURLWithPath: bundlePath)
        navigationController?.preferredContentSize = CGSize(width: popoverWidth, height: popoverHeight)
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func loadTermsAndConditions() {
        if let publisher = DatabaseManager.SharedInstance.getAppPublisher() {
            if let toc = publisher.terms {
                let webViewController = WebViewController()
                webViewController.enabled = false
                webViewController.string = toc
                webViewController.contentType = WebViewControllerContentTypes.string
                webViewController.pageTitle = "Terms & Conditions"
                webViewController.analyticsScreenName = Constants.Page.Name.InfoTC
                webViewController.analyticsScreenType = Constants.Page.Type.np_gp
                navigationController?.preferredContentSize = CGSize(width: popoverWidth, height: popoverHeight)
                navigationController?.pushViewController(webViewController, animated: true)
            }
        }
    }
    
    func loadFAQ() {
        if let publisher = DatabaseManager.SharedInstance.getAppPublisher() {
            if let faq = publisher.faq {
                let webViewController = WebViewController()
                webViewController.analyticsScreenName = Constants.Page.Name.InfoFAQ
                webViewController.analyticsScreenType = Constants.Page.Type.np_gp
                webViewController.enabled = false
                webViewController.string = faq
                webViewController.contentType = WebViewControllerContentTypes.string
                webViewController.pageTitle = "FAQs"
                webViewController.analyticsScreenName = Constants.Page.Name.InfoFAQ
                webViewController.analyticsScreenType = Constants.Page.Type.np_gp
                navigationController?.preferredContentSize = CGSize(width: popoverWidth, height: popoverHeight)
                navigationController?.pushViewController(webViewController, animated: true)
            }
        }
    }
    
    func loadHowToUseTheApp() {
        dismiss(animated: true) {
            performOnMainThread({ 
                let howToUseVC = HowToUseTheAppController()
                let navigationVC = UINavigationController(rootViewController: howToUseVC)
                navigationVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
                self.viewController?.present(navigationVC, animated: true, completion: nil)
            })
        }
        
    }
}
