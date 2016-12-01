//
//  AIPTableViewCell.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 11/30/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let aipStartingText = "In Press Corrected Proof | "

class AIPDownloadButton: UIButton {
    
    init() {
        super.init(frame: CGRect.zero)
        
        let downloadImage = UIImage(named: "Download")
        let deleteImage = UIImage(named: "Trash-Filled")
        
        tintColor = UIColor.gray
        
        setImage(downloadImage, for: UIControlState())
        setImage(deleteImage, for: .selected)
        
        backgroundColor = UIColor.veryLightGray()
        layer.cornerRadius = 4.0
        imageEdgeInsets = UIEdgeInsets(top:8, left: 11, bottom: 8, right: 11)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


protocol AIPCellDelegate : class {
    func articleWasDeleted()
    func showCannotDeleteArticle()
}


class AIPTableViewCell: UITableViewCell {
    
    static let Identifier = "AIPTableViewCell"
    static let disabled = ", Disabled"
    
    weak var article: Article?
    weak var tableViewController: AIPTableViewController?
    weak var delegate: AIPCellDelegate?
    
    var titleTextLabel: UILabel = ArticleTitleLabel()
    var authorTextLabel: UILabel = ArticleAuthorLabel()
    let openAccessLabel: UILabel = OpenAccessLabel()
    let aipLabel: UILabel = UILabel()
    
    let bookmarkButton: UIButton = UIButton(type: .custom)
    let authorsPlusButton = UIButton(type: .custom)
    let downloadButton = AIPDownloadButton()
    let numberOfVideosLabel = NumberOfVideosView()
    let numberOfAudiosView  = NumberOfAudiosView()
    let numberOfNotesView = NumberOfNotesView()
    let separatorView = UIView()
    
    var indexPath: IndexPath?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        
        setupSubviews()
        setupAutoLayout()
        
        aipLabel.text = aipStartingText
        aipLabel.textColor = UIColor.gray
        aipLabel.font = UIFont.italicSystemFont(ofSize: 14)
        aipLabel.numberOfLines = 0
        
        authorTextLabel.isUserInteractionEnabled = true
        authorTextLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userClickedPlusButton)))

        bookmarkButton.setImage(UIImage(named: "Starred-Inactive"), for: UIControlState())
        bookmarkButton.setImage(UIImage(named: "Starred-Active"), for: .selected)
        bookmarkButton.accessibilityLabel = "Add to reading list"
        bookmarkButton.addTarget(self, action: #selector(bookmarkButtonClicked(_:)), for: .touchUpInside)
        bookmarkButton.layer.cornerRadius = 4.0
        bookmarkButton.backgroundColor = UIColor.veryLightGray()
        bookmarkButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        setBookmarkButtonSelected(false)
        
        authorsPlusButton.setTitle("+", for: UIControlState())
        authorsPlusButton.backgroundColor = UIColor.veryLightGray()
        authorsPlusButton.layer.borderColor = UIColor.gray.cgColor
        authorsPlusButton.layer.borderWidth = 1
        authorsPlusButton.layer.cornerRadius = 4
        authorsPlusButton.setTitleColor(UIColor.gray, for: UIControlState())
//        authorsPlusButton.hidden = true
        
        authorsPlusButton.isHidden = false
        authorsPlusButton.isAccessibilityElement = false
        
        authorsPlusButton.addTarget(self, action: #selector(userClickedPlusButton), for: .touchUpInside)
        
        
        downloadButton.accessibilityLabel = "Download this article"
        downloadButton.addTarget(self, action: #selector(downloadButtonClicked(_:)), for: .touchUpInside)
        setDownloadButtonSelected(.notDownloaded)
        
        separatorView.backgroundColor = Config.Colors.TableViewSeparatorColor        
    }
    
    func setupSubviews() {
        contentView.addSubview(titleTextLabel)
        contentView.addSubview(authorTextLabel)
        contentView.addSubview(aipLabel)
        contentView.addSubview(openAccessLabel)
        contentView.addSubview(bookmarkButton)
        contentView.addSubview(authorsPlusButton)
        contentView.addSubview(downloadButton)
        contentView.addSubview(numberOfNotesView)
        contentView.addSubview(numberOfVideosLabel)
        contentView.addSubview(numberOfAudiosView)
        contentView.addSubview(separatorView)
    }
    
    func setupAutoLayout() {
        
        let views = [
            titleTextLabel,
            authorTextLabel,
            aipLabel,
            openAccessLabel,
            authorsPlusButton,
            bookmarkButton,
            downloadButton,
            separatorView,
            numberOfNotesView,
            numberOfVideosLabel,
            numberOfAudiosView,
        ]
        
        constrain(views) { (subviews) in
            let titleTextL = subviews[0]
            let authorTextL = subviews[1]
            let aipL = subviews[2]
            let openAccessL = subviews[3]
            let authorsPlusB = subviews[4]
            let bookmarkB = subviews[5]
            let downloadB = subviews[6]
            let separatorV = subviews[7]
            let notesV = subviews[8]
            let videosL = subviews[9]
            let audiosV = subviews[10]
            
            guard let superview = titleTextL.superview else { return }
            
            titleTextL.top == superview.top + Config.Padding.Default
            titleTextL.right == superview.right - Config.Padding.Default
            titleTextL.left == superview.left + Config.Padding.Default
            
            authorTextL.top == titleTextL.bottom + Config.Padding.Small
            authorTextL.right == authorsPlusB.left - Config.Padding.Default
            authorTextL.left == superview.left + Config.Padding.Default
            
            authorsPlusB.right   == superview.right - Config.Padding.Default
            authorsPlusB.centerY == authorTextL.centerY
            authorsPlusB.width   == 22
            authorsPlusB.height  == 22
            
            aipL.top == authorTextL.bottom + Config.Padding.Small
            aipL.right == superview.right - Config.Padding.Default
            aipL.left == superview.left + Config.Padding.Default
            
            openAccessL.top == aipL.bottom + Config.Padding.Small
            openAccessL.right == superview.right - Config.Padding.Default
            openAccessL.left == superview.left + Config.Padding.Default
            
            bookmarkB.top       == openAccessL.bottom + Config.Padding.Default
            bookmarkB.left      == superview.left + Config.Padding.Default
            bookmarkB.bottom    == superview.bottom - Config.Padding.Default
            bookmarkB.width     == 44
            bookmarkB.height    == 36
            
            downloadB.width     == 44
            downloadB.height    == 36
            downloadB.left      == bookmarkB.right + 8
            downloadB.centerY   == bookmarkB.centerY
            
            separatorV.right    == superview.right
            separatorV.bottom   == superview.bottom
            separatorV.left     == superview.left
            separatorV.height   == 1
            
            notesV.left         == downloadB.right + Config.Padding.Small
            notesV.centerY      == bookmarkB.centerY
            
            videosL.left        == notesV.right + Config.Padding.Small
            videosL.centerY     == bookmarkB.centerY
            
            audiosV.left        == videosL.right + Config.Padding.Small
            audiosV.centerY     == bookmarkB.centerY
            
        }
    }
    
    func setArticleInfo(_ article: Article) {
        self.article = article
        setDownloadButtonSelected(article.downloadInfo.fullTextDownloadStatus)
        setBookmarkButtonSelected(article.starred!.boolValue)
        setupNotifications()
    }
    
    func setBookmarkButtonSelected(_ selected: Bool) {
        bookmarkButton.isSelected = selected
        if selected {
            bookmarkButton.tintColor = UIColor.darkGoldColor()
            bookmarkButton.accessibilityLabel = "Article has been added to reading list, double tap to remove it"
        } else {
            bookmarkButton.tintColor = UIColor.gray
            bookmarkButton.accessibilityLabel = "Add to reading list"
        }
    }
    
    func bookmarkButtonClicked(_ sender: AnyObject) {
        guard let article = self.article, let starred = self.article?.starred else {
            return
        }
        DatabaseManager.SharedInstance.performChangesAndSave { () -> () in
            if starred.boolValue {
                article.toggleStarred()
            } else {
                article.toggleStarred()
            }
            DispatchQueue.main.async(execute: { () -> Void in
                self.setBookmarkButtonSelected(article.starred.boolValue)
            })
        }
    }
    
    func setDownloadButtonSelected(_ status: DownloadStatus) {
        switch status {
        case .downloaded:
            performOnMainThread({ 
                self.downloadButton.isSelected = true
                self.downloadButton.tintColor = UIColor.navyBlueColor()
                self.downloadButton.accessibilityLabel = "Delete this article"
            })
        case .downloading:
            performOnMainThread({ 
                self.downloadButton.isSelected = false
                self.downloadButton.tintColor = UIColor.lightGray
                self.downloadButton.accessibilityLabel = "Article is downloading, this control is disabled."
            })
        default:
            performOnMainThread({ 
                self.downloadButton.isSelected = false
                self.downloadButton.tintColor = UIColor.gray
                self.downloadButton.accessibilityLabel = "Download this article"
            })
        }
    }
    
    func update(_ article: Article, previousArticle: Article? = nil) {

        if let text = article.author {
            let rect = text.boundingRect(with: CGSize(width: frame.width, height: 200), options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), context: nil).size
            if rect.height > 34 {
                authorsPlusButton.isHidden = false
            } else {
                authorsPlusButton.isHidden = true
            }
        }
        numberOfVideosLabel.count = article.videos.count
        numberOfAudiosView.count = article.audios.count
        numberOfNotesView.count = article.allNotes.count
        
        let notesCount = numberOfNotesView.count
        numberOfNotesView.accessibilityLabel = notesCount == 1 ? "\(notesCount) note" :
                                                                 "\(notesCount) notes"
        
        let audiosCount = numberOfAudiosView.count
        numberOfAudiosView.accessibilityLabel = audiosCount == 1 ? "\(audiosCount) note" :
                                                                   "\(audiosCount) notes"
        
        let videosCount = numberOfVideosLabel.count
        numberOfVideosLabel.accessibilityLabel = videosCount == 1 ? "\(videosCount) note" :
                                                                    "\(videosCount) notes"
    }
    
    func userClickedPlusButton() {
        if UIAccessibilityIsVoiceOverRunning() {
            tableViewController?.tableView((tableViewController?.tableView)!, didSelectRowAt: indexPath!)
        }
        if let indexPath = self.indexPath {
            tableViewController?.toggleAuthorList(indexPath: indexPath)
        }
    }
    
    func downloadButtonClicked(_ sender: AnyObject) {
        guard let article = self.article else { return }
        if article.downloadInfo.fullTextDownloadStatus == .downloaded {
            
            if article.canDeleteArticle == true {
                deleteAIP()
                
            } else if article.canDeleteArticle == false {
                delegate?.showCannotDeleteArticle()
            }
        } else {
            downloadAIP()
        }
    }
    
    func deleteAIP() {
        AnalyticsHelper.MainInstance.analyticsTagAction(AnalyticsHelper.ContentAction.deleteAIP, additionalInfo: "")
        guard let tableVC = self.tableViewController else { return }
        
        let alertVC = UIAlertController(title: "Are you sure you want to delete?", message: "Deleting will remove this content from your device", preferredStyle: .alert)
        
        let actionTitle = self.article?.fullTextSupplementDownloaded == true ? "Delete article with multimedia" : "Delete article"
        
        alertVC.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action) in
            performOnMainThread({ 
                ContentKit.SharedInstance.deleteArticle(self.article!, onlyMultimedia: false)
                self.setDownloadButtonSelected(self.article!.downloadInfo.fullTextDownloadStatus)
                
                self.delegate?.articleWasDeleted()
                //  Dispatch message for header to update article count.
            })
        }))
        if self.article?.fullTextSupplementDownloaded == true {
            alertVC.addAction(UIAlertAction(title: "Delete multimedia only", style: .default, handler: { (action) in
                performOnMainThread({
                    ContentKit.SharedInstance.deleteArticle(self.article!, onlyMultimedia: true)
                    self.setDownloadButtonSelected(self.article!.downloadInfo.fullTextDownloadStatus)
                })
            }))
        }
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertVC.present(from: tableVC)
    }
    
    func downloadAIP() {
        guard NETWORK_AVAILABLE == true && NETWORKING_ENABLED else {
            
            if let _vc = tableViewController {
                
                performOnMainThread({ 
                    Alerts.NoNetwork().present(from: _vc)
                })
            }
            return
        }
        
        guard let article = self.article else { return }
        guard let tableVC = self.tableViewController else { return }
        switch article.downloadInfo.fullTextDownloadStatus {
        case .notDownloaded, .downloadFailed:
            tableVC.delegate?.aipTableViewDidSelectArticle(article: article, push: false)
        default:
            break
        }
    }
    
    func setAuthorLabel(_ text: String?) {
        if let authors = text {
            authorTextLabel.text = authors
        } else {
            authorTextLabel.text = nil
        }
    }
    
    
    //  MARK: Notifications
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_aip_started(_:)), name: NSNotification.Name(rawValue: Notification.Download.AIP.Started), object: article)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_aip_completed(_:)), name: NSNotification.Name(rawValue: Notification.Download.AIP.Completed), object: article)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_article(_:)), name: NSNotification.Name(rawValue: Notification.Download.Article.Updated), object: article)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_article(_:)), name: NSNotification.Name(rawValue: Notification.Download.Article.Started), object: article)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_article(_:)), name: NSNotification.Name(rawValue: Notification.Download.Article.Finished), object: article)
    }
    
    func notification_download_aip_started(_ notification: Foundation.Notification) {
        guard let article = notification.object as? Article else {
            return
        }
        performOnMainThread { 
            self.setDownloadButtonSelected(article.downloadInfo.fullTextDownloadStatus)
        }
    }
    
    func notification_download_aip_completed(_ notification: Foundation.Notification) {
        guard let article = notification.object as? Article else {
            return
        }
        performOnMainThread {
            self.setDownloadButtonSelected(article.downloadInfo.fullTextDownloadStatus)
        }
    }
    
    func notification_download_article(_ notification: Foundation.Notification) {
        guard let article = notification.object as? Article else {
            return
        }
        performOnMainThread {
            self.setDownloadButtonSelected(article.downloadInfo.fullTextDownloadStatus)
        }
    }

    override func prepareForReuse() {
        titleTextLabel.text = nil
        authorTextLabel.text = nil
        setBookmarkButtonSelected(false)
        setDownloadButtonSelected(.notDownloaded)
        NotificationCenter.default.removeObserver(self)
        article = nil
        
        openAccessLabel.isHidden = false
        openAccessLabel.text = nil
        authorsPlusButton.isHidden = true
    }
}
