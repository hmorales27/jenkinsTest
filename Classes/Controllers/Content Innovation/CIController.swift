//
//  CIController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 1/22/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography
import WebKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


private let CellIdentifier = "CICollectionViewCell"

protocol CIControllerDelegate: class {
    func numberOfContentInnovations() -> Int
    func configureContentInnovationCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath)
    func contentInnovationWidgetForIndexPath(_ indexPath: IndexPath) -> CIWidget?
    func shouldClearContentInnovation()
    func contentInnovationTitle() -> String
    func contentInnovationAccessibilityLabel() -> String
    func contentInnovationWidgetForInt(_ int: Int) -> CIWidget?
}

class CIController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: CIControllerDelegate?
    
    var productInfo: String = ""
    
    fileprivate var url: URL?
    fileprivate var directLink = false
    
    let navigationBar = UINavigationBar()
    
    let webView = UIWebView()
    let tableView = UITableView()
    let loadingIndicator = UIActivityIndicatorView()
    
    var webViewLeftConstraint: NSLayoutConstraint?
    var webViewRightConstraint: NSLayoutConstraint?
    var webViewWidth: NSLayoutConstraint?
    
    var widgetOpen = false
    
    
    let alphaBackground = UIView()
    
    // MARK: - Initializers -
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
        self.directLink = true
    }
    
    func setupDirectLinkForURL(_ url: URL) {
        self.url = url
        self.directLink = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup -
    
    func setup() {
        
        setupSubviews()
        setupAutoLayout()
        setupTableView()
        setupWebView()
        setupAlphaBackground()
        setupView()
        
        let closeBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .plain, target: self, action: #selector(closeBarButtonItemClicked(_:)))
        
        let navItem = UINavigationItem()
        navItem.rightBarButtonItem = closeBarButtonItem
        self.navigationBar.items = [navItem]
        if self.delegate?.numberOfContentInnovations() > 1 {
            self.navigationBar.items?[0].title = self.delegate?.contentInnovationTitle()
        } else {
            if let widget = self.delegate?.contentInnovationWidgetForInt(0) {
                self.navigationBar.items?[0].title = widget.widgetName
            }
        }
        
        if directLink {
            loadDirectLink()
        }
        
        
    }
    
    func setupSubviews() {
        view.addSubview(navigationBar)
        view.addSubview(tableView)
        view.addSubview(alphaBackground)
        view.addSubview(webView)
    }
    
    
    
    func loadDirectLink() {
        guard let url = self.url else {
            performOnMainThread({
                log.warning("Attempted to Present a direct widget without assigning a URL")
                self.dismiss(animated: true, completion: nil)
            })
            return
        }
        sendDirectAnalytics()
        openWidgetView(url)
    }
    
    let widgetActionMessageKey = "gaaction"
    
    func sendDirectAnalytics() {
        guard let url = self.url else { return }
        guard let query = url.query else { return }
        
        var widgetActionMessage = ""
        let queryItems = query.components(separatedBy: "&")
        for item in queryItems {
            if item.contains(widgetActionMessageKey) {
                let keyValue = item.components(separatedBy: "=")
                if keyValue.count == 2 {
                    widgetActionMessage = keyValue[1]
                }
            }
        }
        
        if widgetActionMessage == "" {
            log.warning("Unable to get widgetActionMessage for widget url: \(url)")
        }
        
        AnalyticsHelper.MainInstance.contentInnovationAnalyticsTagAction(productInfo, widgetName: widgetActionMessage)
    }
    
    func setupView() {
        view.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor.clear
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(CITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
    }
    
    func setupAlphaBackground() {
        alphaBackground.backgroundColor = UIColor.black
        alphaBackground.isHidden = true
        alphaBackground.alpha = 0.0
    }
    
    func setupWebView() {
        webView.scrollView.isScrollEnabled = false
    }
    
    func setupAutoLayout() {
        constrain(navigationBar, tableView, webView) { (navigationBar, tableView, webView) -> () in
            guard let superview = tableView.superview else {
                return
            }
            
            navigationBar.left == superview.left
            navigationBar.top == superview.top
            navigationBar.right == superview.right
            navigationBar.height == 64
            
            tableView.left == superview.left
            tableView.top == navigationBar.bottom
            tableView.right == superview.right
            tableView.bottom == superview.bottom
            
            webView.top == tableView.top + 8
            webViewRightConstraint = (webView.right == superview.right - 2000)
            webView.bottom == superview.bottom - 8
            webView.width == self.view.frame.size.width - 16
        }
        
        constrain(alphaBackground, navigationBar) { (alphaBackground, navigationBar) -> () in
            guard let superview = alphaBackground.superview else {
                return
            }
            
            alphaBackground.left == superview.left
            alphaBackground.top == navigationBar.bottom
            alphaBackground.right == superview.right
            alphaBackground.bottom == superview.bottom
        }
    }
    
    // MARK: - Table View -
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as? CITableViewCell
        if (cell == nil) {
            cell = CITableViewCell()
        }
        let widget = delegate!.contentInnovationWidgetForIndexPath(indexPath)
        cell?.update(widget!)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let d = delegate {
            return d.numberOfContentInnovations()
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = delegate?.contentInnovationWidgetForIndexPath(indexPath) {
            AnalyticsHelper.MainInstance.contentInnovationAnalyticsTagAction(productInfo, widgetName: item.widgetActionMessage)
            if let url = URL(string: item.widgetSrcUrl) {
                navigationBar.items?[0].title = item.widgetName
                openWidgetView(url)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func openWidgetView(_ url: URL) {
        tableView.isHidden = true
        let request = NSMutableURLRequest(url: url)
        let components = url.parameters()
        if let title = components["cititle"] {
            navigationBar.items?[0].title = title.replacingOccurrences(of: "+", with: " ")
        }
        request.setValue(Strings.CIConsumerID, forHTTPHeaderField: "consumerid")
        self.webView.loadRequest(request as URLRequest)
        
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, navigationItem.titleView)
        
        alphaBackground.isHidden = false
        widgetOpen = true
        
        UIView.animate(withDuration: 0.6, animations: { () -> Void in
            self.alphaBackground.alpha = 0.7
            self.webViewRightConstraint?.constant = -8
            self.view.layoutIfNeeded()
        }) 
    }
    
    func closeWidgetView() {
        
        self.navigationBar.items?[0].title = self.delegate?.contentInnovationTitle()
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            
            self.alphaBackground.alpha = 0.0
            self.webViewRightConstraint?.constant = -2000
            self.view.layoutIfNeeded()
            
        }, completion: { (completed) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.widgetOpen = false
                self.alphaBackground.isHidden = true
            })
        }) 
    }
    
    // MARK: - Other -
    
    func closeBarButtonItemClicked(_ sender: AnyObject) {
        if directLink == false {
            if widgetOpen == true {
                tableView.isHidden = false
                webView.loadRequest(Foundation.URLRequest(url: URL(string: "about:blank")!))
                closeWidgetView()
                
            } else {
                dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
}
