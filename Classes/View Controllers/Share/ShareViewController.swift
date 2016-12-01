//
//  ShareViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 4/18/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography


private let ShareMail = "Share_Mail"
private let ShareMailPDF = "Share_MailPDF"
private let ShareFacebook = "Share_Facebook"
private let ShareTwitter = "Share_Twitter"
private let SharePrint = "Share_Print"
private let ShareOtherApp = "Share_PDF"

enum ShareType {
    case emailArticle
    case emailPDF
    case facebook
    case twitter
    case print
    case differentApp
    
    func item() -> ShareItem {
        switch self {
        case .emailArticle:
            return ShareItem(title: "Email article link", accessibilityLabel: "Email article link button", type: .emailArticle)
        case .emailPDF:
            return ShareItem(title: "Email PDF", accessibilityLabel: "Email as pdf button", type: .emailPDF)
        case .facebook:
            return ShareItem(title: "Facebook", accessibilityLabel: "Share via facebook", type: .facebook)
        case .twitter:
            return ShareItem(title: "Twitter", accessibilityLabel: "Share via twitter", type: .twitter)
        case .print:
            return ShareItem(title: "Print", accessibilityLabel: "Print this pdf", type: .print)
        case .differentApp:
            return ShareItem(title: "Open in Other app", accessibilityLabel: "Open in Other App", type: .differentApp)
        }
    }
}

struct ShareItem {
    let title: String
    let accessibilityLabel: String
    let type: ShareType
    
    var image: UIImage {
        get {
            switch type {
            case .emailArticle:
                return UIImage(named: ShareMail)!
            case .emailPDF:
                return UIImage(named: ShareMailPDF)!
            case .facebook:
                return UIImage(named: ShareFacebook)!
            case .twitter:
                return UIImage(named: ShareTwitter)!
            case .print:
                return UIImage(named: SharePrint)!
            case .differentApp:
                return UIImage(named: ShareOtherApp)!
            }
        }
    }
}

protocol ShareViewControllerDelegate: class {
    func shareViewController(_ viewController: ShareViewController, didRequestShareOfType type: ShareType)
}

class ShareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var article: Article?
    weak var delegate: ShareViewControllerDelegate?
    
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    var tableViewData: [ShareItem] = []
    
    var expectesSize: CGSize {
        get {
            return CGSize(width: 320, height: (44 * itemCount))
        }
    }
    var itemCount: CGFloat = 0
    
    init(article: Article, delegate: ShareViewControllerDelegate?) {
        self.article = article
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        setup()
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Setup -
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupTableView()
        
        title = "Share"
    }
    
    func setupSubviews() {
        view.addSubview(tableView)
    }
    
    func setupAutoLayout() {
        let subviews = [
            tableView
        ]
        constrain(subviews) { (views) in
            let tableV = views[0]
            guard let superview = tableV.superview else {
                return
            }
            tableV.top == superview.top
            tableV.right == superview.right
            tableV.bottom == superview.bottom
            tableV.left == superview.left
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Update -
    
    func update() {
        updateTableViewData()
    }
    
    func updateTableViewData() {
        tableViewData.removeAll()
        tableViewData.append(ShareType.emailArticle.item())
        itemCount += 1
        if article?.downloadInfo.fullTextDownloadStatus == .downloaded {
            tableViewData.append(ShareType.emailPDF.item())
            itemCount += 1
        }
        tableViewData.append(ShareType.facebook.item())
        itemCount += 1
        tableViewData.append(ShareType.twitter.item())
        itemCount += 1
        
        if delegate as? PDFPreviewControl != nil {
            tableViewData.append(ShareType.print.item())
            tableViewData.append(ShareType.differentApp.item())
            itemCount += 2
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table View -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let item = tableViewData[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = item.title
        cell.imageView?.image = item.image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate?.shareViewController(self, didRequestShareOfType: tableViewData[(indexPath as NSIndexPath).row].type)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
