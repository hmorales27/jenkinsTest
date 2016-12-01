//
//  AnnouncementViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/2/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class AnnouncementViewController: JBSMViewController {
    
    let webView = UIWebView()
    let announcement: Announcement
    
    init(announcement: Announcement) {
        self.announcement = announcement
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setup()
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DatabaseManager.SharedInstance.performChangesAndSave {
            if self.announcement.opened == false {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Announcement.Updated), object: nil)
            }
            self.announcement.opened = true
            self.announcement.userRead = true
        }
    }
    
    func setup() {
        title = announcement.announcementTitle
        if screenType == .mobile {
            navigationItem.titleView?.accessibilityLabel = title
        }
        setupWebView()
        setupAutoLayout()
    }
    
    func setupWebView() {
        view.addSubview(webView)
        guard let html = announcement.announcementText else {
            log.error("Unable to loaed HTML")
            navigationController?.popViewController(animated: true)
            return
        }
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func setupAutoLayout() {
        
        constrain(webView) { (webView) -> () in
            guard let superview = webView.superview else {
                return
            }
            
            webView.top == superview.top
            webView.right == superview.right
            webView.bottom == superview.bottom
            webView.left == superview.left
        }
    }
    
}
