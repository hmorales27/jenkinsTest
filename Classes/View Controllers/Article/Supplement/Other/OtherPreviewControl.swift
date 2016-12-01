//
//  OtherPreviewControl.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/28/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import Cartography
import QuickLook
import MessageUI


class PreviewControlDelegate: NSObject, QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    let media: Media
    
    init(media: Media) {
        self.media = media
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return media.pathURL as QLPreviewItem
    }
}

class OtherFilePreviewControl: QLPreviewController, QLPreviewControllerDelegate, QLPreviewControllerDataSource, UIDocumentInteractionControllerDelegate, EmailInfoDelegate {
    
    var isArticlesPDF = false
    
    var media: Media
    
    var docController: UIDocumentInteractionController?
    
    var _delegate: PreviewControlDelegate
    
    var close = false

    
    // MARK: - Initializers -
    
    init(media: Media) {
        self.media = media
        _delegate = PreviewControlDelegate(media: media)
        super.init(nibName: nil, bundle: nil)
        self.dataSource = _delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
 
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationBar()
        performOnMainThread { 
            self.setupNavigationBar()
        }
    }
    
    // MARK: - Navigation Bar -
    
    func setupNavigationBar() {
        let shareBarButtonItem = UIBarButtonItem(image: UIImage(named: "Share"), style: .plain, target: self, action: #selector(shareBarButtonItemClicked(_:)))
        if close {
            _ = UIBarButtonItem(image: UIImage(named: "Close"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(closeBarButtonItemClicked(_:)))
            //navigationItem.leftBarButtonItem = closeButton
        } else {
            //navigationItem.leftBarButtonItems = []
        }
        if media.shareable == true {
            navigationItem.rightBarButtonItem = shareBarButtonItem
        }
    }
    
    func closeBarButtonItemClicked(_ sender: UIBarButtonItem) {
        performOnMainThread { 
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func shareBarButtonItemClicked(_ sender: UIBarButtonItem) {
        let url = media.pathURL
        let controller = UIDocumentInteractionController.init(url: url as URL)
        controller.delegate = self
        
        let provider = EmailInfoProvider()
        provider.delegate = self
        
        let postItems: [Any] = [provider, url]
        
        let avc = UIActivityViewController(activityItems: postItems, applicationActivities: nil)
        
        if MFMailComposeViewController.canSendMail() == false {
            
            avc.excludedActivityTypes = [UIActivityType.mail]
        }
        
        avc.setValue("Recommended content from \(media.article.journal.journalTitle!)", forKey: "subject")
        
        avc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        avc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
    
        performOnMainThread({
            self.present(avc, animated: true, completion: nil)
        })
    }
    
    func bookmarkBarButtonItemClicked(_ sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Preview Delegate -
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return OtherFilePreviewItem(media: self.media)
    }
    
    func emailBody() -> String {
        
        var body = "<html><body>"
        body += media.article.emailBody
        body += "</body></html>"
        
        return body
    }
}

class OtherFilePreviewItem: NSObject, QLPreviewItem {
    
    weak var media: Media?
    
    @objc var previewItemURL: URL? {
        get {
            return media!.pathURL as URL
        }
    }
    
    @objc var previewItemTitle: String? {
        get {
            return ""
        }
    }
    
    init(media: Media) {
        self.media = media
    }
    
    

    
}
