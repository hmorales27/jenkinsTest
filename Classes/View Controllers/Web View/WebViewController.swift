//
//  WebViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/21/15.
//  Copyright © 2015 Sharkey, Justin (ELS-CON). All rights reserved.
//

import UIKit
import Cartography
import SafariServices
import MessageUI

enum WebViewControllerContentTypes {
    case url
    case request
    case string
}

class WebViewController: SLViewController, UIWebViewDelegate {
    var webView: UIWebView = UIWebView()
    
    var contentType: WebViewControllerContentTypes?
    
    var isDismissable = false
    
    let headerView = HeadlineView()
    var showHeaderView = false
    
    var url: URL?
    var request: Foundation.URLRequest?
    var string: String?
    
    var pageTitle: String?
    
    var baseURL: URL?
    
    override init() {
        super.init()
    }
    
    override init(journal: Journal) {
        super.init(journal: journal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        view.addSubview(headerView)
        view.addSubview(webView)
        
        definesPresentationContext = true
        
        constrain(webView, headerView) { (webView, headerV) -> () in
            
            guard let superview = headerV.superview else {
                return
            }
            
            headerV.top == superview.top
            headerV.right == superview.right
            headerV.left == superview.left
            
            if showHeaderView == true {
                headerV.height == 40
            } else {
                headerV.height == 0
            }
            
            webView.top == headerV.bottom
            webView.left == superview.left
            webView.bottom == superview.bottom
            webView.right == superview.right
        }
        
        if let contentType = self.contentType {
            switch contentType {
            case .url:
                if let url = self.url {
                    webView.loadRequest(Foundation.URLRequest(url: url))
                } else {
                    failToLoadContent(message: "URL is Missing")
                }
            case .request:
                if let request = self.request {
                    webView.loadRequest(request)
                } else {
                    failToLoadContent(message: "Request is Missing")
                }
            case .string:
                if let string = self.string {
                    var replacementString = string.replacingOccurrences(of: "tel:", with: "tel-sub:")
                    replacementString = replacementString.replacingOccurrences(of: "mailto:", with: "mailto-sub:")
                    webView.loadHTMLString(replacementString, baseURL: baseURL)
                } else {
                    failToLoadContent(message: "String is Missign")
                }
            }
        } else {
            failToLoadContent(message: "Content Type Was Not Set")
        }
        
        if showHeaderView == true {
            headerView.titleLabel.text = pageTitle
            title = currentJournal?.publisher.appTitleIPhone
        } else {
            title = pageTitle
        }
        
        setupNavigationBar()
        super.viewDidLoad()
        
        webView.delegate = self
        webView.becomeFirstResponder()
    }
    
    func openPhoneURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            
            let phoneNumber = url.absoluteString.replacingOccurrences(of: "tel:", with: "")
            let alertVC = UIAlertController(title: phoneNumber, message: nil, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Call", style: .default, handler: { (action) in
                UIApplication.shared.openURL(url)
            }))
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            performOnMainThread({
                self.present(alertVC, animated: true, completion: nil)
            })
        } else {
            let alertVC = UIAlertController(title: "Unable to open the Phone App", message: nil, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            performOnMainThread({
                self.present(alertVC, animated: true, completion: nil)
            })
            
        }
    }
    
    func openEmailAddress(_ url: URL) {
        if MFMailComposeViewController.canSendMail() {
            let emailAddress = url.absoluteString.replacingOccurrences(of: "mailto:", with: "")
            let composer = MFMailComposeViewController()
            composer.setToRecipients([emailAddress])
            composer.mailComposeDelegate = self
            performOnMainThread({ 
                self.present(composer, animated: true, completion: nil)
            })
        } else {
            let alertVC = UIAlertController(title: "Unable to send email", message: nil, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            performOnMainThread({
                self.present(alertVC, animated: true, completion: nil)
            })
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        switch navigationType {
        case .linkClicked:
            
            if let url = request.url {
                
                if url.absoluteString.contains("tel-sub:") {
                    let telPhoneString = url.absoluteString.replacingOccurrences(of: "tel-sub", with: "telprompt")
                    if let _url = URL(string: telPhoneString) {
                        if UIApplication.shared.canOpenURL(_url) {
                            UIApplication.shared.openURL(_url)
                        }
                    }
                    return false
                }
                
                if url.absoluteString.contains("mailto-sub:") {
                    let mailPhoneString = url.absoluteString.replacingOccurrences(of: "mailto-sub", with: "mailto")
                    
                    if let _url = URL(string: mailPhoneString) {
                        if UIApplication.shared.canOpenURL(_url) {
                            UIApplication.shared.openURL(_url)
                        }
                    }
                }
                
                
            } else if let urlString = request.url?.absoluteString {
                
                if urlString.contains("mailto:") {
                    openEmailAddress(request.url!)
                    return false
                }
                
                
            }
            if let url = request.url {
                loadAndPresentURL(url: url)
            }
            
            return false
        default:
            return true
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        log.error(error.localizedDescription)
    }
    
    func failToLoadContent(message:String) {
        let av = UIAlertController(title: "Something Went Wrong", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        av.addAction(ok)
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        if isDismissable == true {
            navigationItem.leftBarButtonItem = closeBarButtonItem
        } else {
            if enabled {
                navigationItem.leftBarButtonItem = menuBarButtonItem
            } else {
                navigationItem.leftBarButtonItems = backButtons("Back")
            }
        }
    }
}
