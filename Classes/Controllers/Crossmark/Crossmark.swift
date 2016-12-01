//
//  Crossmark.swift
//  JBSM
//
//  Created by Curtis, Michael (ELS-PHI) on 11/8/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

protocol Crossmark {

    func pushCrossmarkVC(sender: JBSMViewController, issn: String, articlePii: String)
}
extension Crossmark {
     func pushCrossmarkVC(sender: JBSMViewController, issn: String, articlePii: String) {
        let crossMarkViewController = JBSMViewController()
        let navViewController = UINavigationController(rootViewController: crossMarkViewController)
        navViewController.modalPresentationStyle = .formSheet
        let webView: UIWebView = UIWebView()
        guard let request = Networking.CrossmarkServiceRequest(issn: issn, articlePii: articlePii) else {
            return
        }

       
        webView.loadRequest(request)
        
        crossMarkViewController.navigationItem.leftBarButtonItem = crossMarkViewController.closeBarButtonItem
        crossMarkViewController.view.addSubViewWithMatchingConstraints(subView: webView)
        sender.present(navViewController, animated: true)
        webView.reload()
    }
}

