//
//  JournalInfoViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/15/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography
import SafariServices
import GoogleMobileAds

class JournalInfoViewController: SLViewController, UIWebViewDelegate {
    
    let webView = UIWebView()
    let html: String
    var titleString: String = ""
    
    let headerView = UIView()
    let headerLabel = UILabel()
    
    let advertisementVC = AdvertisementViewController()
    
    // MARK: - Initializers -
    
    init(html: String, title: String, journal: Journal) {
        self.html = html
        self.titleString = title
        super.init()
        self.currentJournal = journal
        self.enabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        
        setupSubviews()
        setupAutoLayout()
        setupNavigationBar()
        setupWebView()

        switch screenType {
        case .tablet:
            title = currentJournal?.journalTitle
            advertisementVC.setup(AdType.iPadPortrait, journal: self.currentJournal!)
        case .mobile:
            title = currentJournal?.journalTitleIPhone
            advertisementVC.setup(AdType.iPhonePortrait, journal: self.currentJournal!)
        }
        advertisementVC.view.backgroundColor = UIColor.white
        
        headerLabel.text = titleString
        headerLabel.textColor = UIColor.white
        headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
        headerView.backgroundColor = UIColor.gray
        
        super.viewDidLoad()
    }
    
    // MARK: - Setup -
    
    func setupSubviews() {
        view.addSubview(webView)
        view.addSubview(headerView)
        headerView.addSubview(headerLabel)
        
        addChildViewController(advertisementVC)
        advertisementVC.didMove(toParentViewController: self)
        view.addSubview(advertisementVC.view)
    }
    
    func setupHeaderView() {
        
    }
    
    func setupWebView() {
        webView.backgroundColor = UIColor.white
        webView.loadHTMLString(self.html, baseURL: nil)
        webView.delegate = self
    }
    
    func setupAutoLayout() {
        constrain(webView, headerView, headerLabel, advertisementVC.view!) { (webView, headerView, headerLabel, advertisementView) -> () in
            guard let superview = webView.superview else {
                return
            }
            
            headerView.left == superview.left
            headerView.top == superview.top
            headerView.right == superview.right
            
            headerLabel.left == headerView.left + 8
            headerLabel.top == headerView.top + 8
            headerLabel.right == headerView.right - 8
            headerLabel.bottom == headerView.bottom - 8
            
            webView.top == headerView.bottom
            webView.right == superview.right
            webView.left == superview.left
            
            advertisementView.top == webView.bottom
            advertisementView.right == superview.right
            advertisementVC.bottomConstraint = (advertisementView.bottom == superview.bottom)
            advertisementView.left == superview.left
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        updateNavigationBar(screenType)
    }
    
    func updateNavigationBar(_ screenType: ScreenType) {
        switch screenType {
        case .mobile:
            navigationItem.rightBarButtonItem = nil
        case .tablet:
            navigationItem.rightBarButtonItems = rightBarButtonItems
        }
        navigationItem.leftBarButtonItem = menuBarButtonItem
    }
    
    override func slideMenuDidClose() {
        super.slideMenuDidClose()
        webView.scrollView.isScrollEnabled = true
    }
    
    // MARK: - Web View -
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        switch navigationType {
        case .linkClicked:
            loadAndPresentURL(url: request.url!)
            return false
        default:
            return true
        }
    }
    
    override func updateViewsForScreenChange(_ type: ScreenType) {
        updateNavigationBar(type)
    }
}

// MARK: - Navigation Bar -

extension JournalInfoViewController {
    
    
    
}

// MARK: - Screen Size Change -

extension JournalInfoViewController {
    
    
    
}
