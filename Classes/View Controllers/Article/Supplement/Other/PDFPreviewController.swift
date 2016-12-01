//
//  PDFPreviewController.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/28/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import QuickLook
import MessageUI
import Social

class PDFPreviewControl: QLPreviewController, QLPreviewControllerDelegate, QLPreviewControllerDataSource, UIPopoverPresentationControllerDelegate, MFMailComposeViewControllerDelegate, ShareViewControllerDelegate, UIPrintInteractionControllerDelegate, UIDocumentInteractionControllerDelegate {
    
    var isArticlesPDF = false
    
    var article: Article
    
    var bookmarkBarButtonItem: UIBarButtonItem?
    
    var docController: UIDocumentInteractionController?
    
    let rlRemoveAccessibility = "Article has been added to reading list. Double-tap to remove it."
    let rlAddAccessibility = "Add to reading list"

    
    // MARK: - Initializers -
    
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        delegate = self
        dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Navigation Bar -
    
    func setupNavigationBar() {
        
        navigationItem.hidesBackButton = true
        
        let closeBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeBarButtonItemClicked(_:)))
        
        let shareBarButtonItem = UIBarButtonItem(image: UIImage(named: "Share"), style: .plain, target: self, action: #selector(shareBarButtonItemClicked(_:)))
        shareBarButtonItem.accessibilityLabel = "share button"
        
        if article.starred == true {
            self.bookmarkBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Starred-Active"), style: .plain, target: self, action: #selector(bookmarkBarButtonItemClicked(sender:)))
            self.bookmarkBarButtonItem?.accessibilityLabel = rlRemoveAccessibility
        } else {
            self.bookmarkBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Starred-Inactive"), style: .plain, target: self, action: #selector(bookmarkBarButtonItemClicked(sender:)))
            self.bookmarkBarButtonItem?.accessibilityLabel = rlAddAccessibility
        }
        
        var leftButtons: [UIBarButtonItem] = []
        leftButtons.append(shareBarButtonItem)
        leftButtons.append(self.bookmarkBarButtonItem!)
        
        navigationItem.setLeftBarButtonItems(leftButtons, animated: false)
        navigationItem.setRightBarButtonItems([closeBarButtonItem], animated: false)
        
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func closeBarButtonItemClicked(_ sender: UIBarButtonItem) {
        performOnMainThread {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func shareBarButtonItemClicked(_ sender: UIBarButtonItem) {
        let shareVC = ShareViewController(article: article, delegate: self)
        let navigationVC = UINavigationController(rootViewController: shareVC)
        navigationVC.modalPresentationStyle = UIModalPresentationStyle.popover
        navigationVC.popoverPresentationController?.barButtonItem = sender
        navigationVC.popoverPresentationController?.backgroundColor = AppConfiguration.NavigationBarColor
        navigationVC.popoverPresentationController?.delegate = self
        navigationVC.preferredContentSize = shareVC.expectesSize
        switch ScreenType.TypeForSize(self.view.frame.size) {
        case .tablet:
            navigationVC.popoverPresentationController?.barButtonItem = sender
        default:
            break
        }
        present(navigationVC, animated: true, completion: {})
    }
    func bookmarkBarButtonItemClicked(sender: UIBarButtonItem) {        
        
        DatabaseManager.SharedInstance.performChangesAndSave { () -> () in
            performOnMainThread({
                self.article.toggleStarred()

                var image: UIImage?
                
                if self.article.starred.boolValue == true {
                    image = UIImage(named: "Starred-Active")!
                    self.bookmarkBarButtonItem?.accessibilityLabel = self.rlRemoveAccessibility
                    
                } else if self.article.starred.boolValue == false {
                    image = UIImage(named: "Starred-Inactive")!
                    self.bookmarkBarButtonItem?.accessibilityLabel = self.rlAddAccessibility
                }
                
                if let _image = image {
                    sender.image = _image
                }
                
                var alert: UIAlertController
                if self.article.starred.boolValue {
                    alert = Alerts.AddToReadingList { (goToReadingList) in
                        let bookmarkVC = BookmarksViewController(journal: self.article.journal)
                        self.navigationController?.popToRootViewControllerAndLoadViewController(bookmarkVC)
                    }
                } else {
                    alert = Alerts.RemovedFromReadingList()
                }
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    // MARK: - Preview Delegate -
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return PDFPreviewItem(article: self.article)
    }
    
    //  MARK: - Popover delegate - 
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    
    // MARK: - Share -
    
    func shareViewController(_ viewController: ShareViewController, didRequestShareOfType type: ShareType) {
        viewController.dismiss(animated: true, completion: nil)
        switch type {
        case .emailArticle:
            shareArticleByEmail(withPDF: false)
        case .emailPDF:
            shareArticleByEmail(withPDF: true)
        case .facebook:
            shareArticleViaSocial(SLServiceTypeFacebook)
        case .twitter:
            shareArticleViaSocial(SLServiceTypeTwitter)
        case .print:
            shareArticleInPrint()
        case .differentApp:
            shareInAnotherApp(viewController)
        }
    }
    
    func shareArticleByEmail(withPDF pdf: Bool) {
        if pdf == true {
            if article.downloadInfo.pdfDownloadStatus == .downloaded {
                
                let data = try? Data(contentsOf: URL(fileURLWithPath: self.article.pdfPath))
                self.shareArticlebyEmail(withData: data)
            }
            else if article.downloadInfo.pdfDownloadStatus != .downloaded {
                APIManager.sharedInstance.downloadPDF(article: article, completion: { (success) in
                    
                    let data = try? Data(contentsOf: URL(fileURLWithPath: self.article.pdfPath))
                    self.shareArticlebyEmail(withData: data)
                })
            }
        } else {
            shareArticlebyEmail(withData: nil)
        }
    }
    
    func shareArticlebyEmail(withData data: Data?) {
        performOnMainThread {
            guard MFMailComposeViewController.canSendMail() == true else {
                // TODO: Show Dialogue
                return
            }
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setBccRecipients(nil)
            mailVC.setBccRecipients(nil)
            mailVC.setSubject("Recommended article from \(self.article.journal.journalTitle!)")
            mailVC.setMessageBody(self.article.emailBody, isHTML: true)
            if let _data = data {
                mailVC.addAttachmentData(_data, mimeType: "application/pdf", fileName: self.article.articleTitle! + ".pdf")
            }
            self.present(mailVC, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            if result == MFMailComposeResult.sent {
                Alerts.MailSent().present(from: self)
                return
            }
            if result == MFMailComposeResult.saved {
                Alerts.MailSavedToDrafts().present(from: self)
                return
            }
            if result == MFMailComposeResult.failed {
                Alerts.MailCancelled().present(from: self)
                return
            }
            if result == MFMailComposeResult.cancelled {
                Alerts.MailCancelled().present(from: self)
                return
            }
        }
    }
    
    func shareArticleViaSocial(_ type: String) {
        let sharingAvailable = SLComposeViewController.isAvailable(forServiceType: type)
        
        let vc = sharingAvailable == true ? SLComposeViewController(forServiceType: type) : UIAlertController.init(title: "", message: "", preferredStyle: .alert)
        
        if let _vc = vc as? SLComposeViewController, let doiLink = article.doiLink {
            
            switch type {
            case SLServiceTypeFacebook:
                _vc.add(URL(string: doiLink)!)
            case SLServiceTypeTwitter:
                _vc.setInitialText(doiLink)
            default:
                break
            }
        } else if let _vc = vc as? UIAlertController {
            
            if type == SLServiceTypeFacebook {
                _vc.title = "No Facebook account"
                _vc.message = "There are no Facebook accounts configured. You can add or create a Facebook account in Settings."
            
            } else if type == SLServiceTypeTwitter {
                _vc.title = "Can't send tweet"
                _vc.message = "You can't send a tweet right now. Make sure your device has an internet connection and you have at least one Twitter account setup."
            }
            _vc.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
        }
        performOnMainThread {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func shareArticleInPrint() {
        
        //  Get the PDF as NSData object
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: self.article.pdfPath)) else {
            
            return
        }

        if UIPrintInteractionController.canPrint(data) {
            let printController = UIPrintInteractionController.shared
             printController.delegate = self
            
            let printInfo = UIPrintInfo.printInfo()
            printInfo.outputType = UIPrintInfoOutputType.general
            
            let url = URL(fileURLWithPath: self.article.pdfPath)
            
            let lastComponent = url.lastPathComponent
            printInfo.jobName = lastComponent
            printInfo.duplex = UIPrintInfoDuplex.longEdge
            printController.printInfo = printInfo
            printController.showsPageRange = true
            printController.printingItem = data
            
            printController.present(animated: true, completionHandler: nil)
        }
    }
    
    func shareInAnotherApp(_ shareController: ShareViewController) {
        
        let url = URL(fileURLWithPath: self.article.pdfPath)
        docController = UIDocumentInteractionController.init(url: url)
        docController?.delegate = self
        
        guard let barItem = shareController.navigationController?.popoverPresentationController?.barButtonItem else {
            
            return
        }
        
        let canOpen = docController?.presentOpenInMenu(from: barItem, animated: true)
        
        if canOpen == false {
            let alert = Alerts.NoApp()
            
            performOnMainThread({ 
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
}

class PDFPreviewItem: NSObject, QLPreviewItem {
    
    weak var article: Article?
    
    @objc var previewItemURL: URL? {
        if let article = self.article {
            if FileSystemManager.sharedInstance.pathExists(article.pdfPath) {
                return URL(fileURLWithPath: article.pdfPath)
            } else {
                return URL(fileURLWithPath: article.oldPDFFilePath)
            }
        }
        return nil
    }
    
    @objc var previewItemTitle: String? {
        get {
            return article!.articleTitle
        }
    }
    
    init(article: Article) {
        self.article = article
    }
    
}
