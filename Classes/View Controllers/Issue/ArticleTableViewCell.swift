/**
 ArticleTableViewCell.swift
 
 Created by Sharkey, Justin on 10/19/15
 Copyright © 2015 Elsevier. All rights reserved.
*/

import UIKit
import Cartography


protocol ArticleTableViewCellDelegate : class {
    
    func showCannotDeleteArticle()
}

protocol AuthorPlusButtonDelegate: class {
    func authorPlusButtonWasClickedforIndexPath(_ indexPath: IndexPath)
}

class ArticleTableViewCell: UITableViewCell {
    
    static let Identifier = "ArticleTableViewCell"
    
    let subTypeView         = JBSMView()
    let subTypeLabel        = UILabel()
    
    let subType2View        = JBSMView()
    let subType2Label       = UILabel()
    
    let subType3View        = JBSMView()
    let subType3Label       = UILabel()
    
    let subType4View        = JBSMView()
    let subType4Label       = UILabel()
    
    let titleLabel          = ArticleTitleLabel()
    let authorsLabel        = ArticleAuthorLabel()
    let pageNumberLabel     = PageNumberLabel()
    let openAccessLabel     = OpenAccessLabel()
    let bookmarkButton      = BookmarkButton()
    let authorsPlusButton   = UIButton(type: .custom)
    let downloadButton      = JBSMButton()
    
    let numberOfVideosLabel = NumberOfVideosView()
    let numberOfAudiosView  = NumberOfAudiosView()
    let numberOfNotesView   = NumberOfNotesView()
    let styleLayer          = CAShapeLayer()
    
    weak var delegate : ArticleTableViewCellDelegate?
    weak var authorPlusButtonDelegate : AuthorPlusButtonDelegate?
    
    var indexPath: IndexPath?
    
    let separatorView = UIView()
    
    let spinningIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    var expectedNumberOfLines = 0
    
    //TODO at some point, we should go back and add a super class for both of these and put this functionality in there so that there only has to be one delegate.
    weak var issueVC: ArticlesViewController?
    weak var highlightVC: HighlightViewController?
    weak var article: Article?
    var shouldUseNewUi = USE_NEW_UI
    weak var parentJbsmViewController: JBSMViewController?
    
    // MARK: Initializers
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
 
    func setup() {
        addSubviews([titleLabel, authorsLabel, pageNumberLabel, openAccessLabel, bookmarkButton, authorsPlusButton, downloadButton, separatorView, numberOfVideosLabel, numberOfAudiosView, numberOfNotesView, subTypeView, spinningIndicator, subType2View, subType3View, subType4View])
        
        subTypeView.addSubview(subTypeLabel)
        subType2View.addSubview(subType2Label)
        subType3View.addSubview(subType3Label)
        subType4View.addSubview(subType4Label)
        
        if shouldUseNewUi {
            layer.insertSublayer(styleLayer, at: 0)
        }
        
        authorsLabel.setGestureAction(UITapGestureRecognizer(target: self, action: #selector(userClickedPlusButton)))
        authorsPlusButton.setTitle("+", for: UIControlState())
        authorsPlusButton.backgroundColor = UIColor.veryLightGray()
        authorsPlusButton.layer.borderColor = UIColor.gray.cgColor
        authorsPlusButton.layer.borderWidth = 1
        authorsPlusButton.layer.cornerRadius = 4
        authorsPlusButton.setTitleColor(UIColor.gray, for: UIControlState())
        authorsPlusButton.addTarget(self, action: #selector(userClickedPlusButton), for: .touchUpInside)
        authorsPlusButton.isHidden = true
        authorsPlusButton.accessibilityLabel = "Expand Author Name Button"
        
        downloadButton.setImage(UIImage(named: "Download"), for: UIControlState())
        downloadButton.setImage(UIImage(named: "Trash-Filled"), for: .selected)
        downloadButton.addTarget(self, action: #selector(userClickedDownloadButton(_:)), for: .touchUpInside)
        downloadButton.layer.cornerRadius = USE_NEW_UI ? 0.0 : 4.0

        downloadButton.backgroundColor = UIColor.veryLightGray()
        downloadButton.imageEdgeInsets = UIEdgeInsets(top:8, left: 11, bottom: 8, right: 11)
        setDownloadButtonSelected(.notDownloaded)
        showDownloadButton(false)
        
        separatorView.backgroundColor = Config.Colors.TableViewSeparatorColor
        separatorView.isHidden = USE_NEW_UI
        bookmarkButton.cell = self
        
        subTypeView.backgroundColor = UIColor.colorWithHexString("939393")

        subTypeLabel.font = UIFont.systemFontOfSize(14, weight: SystemFontWeight.Bold)
        subTypeLabel.textColor = UIColor.colorWithHexString("585959")
        subTypeLabel.numberOfLines = 1
        
        subType2View.backgroundColor = UIColor.colorWithHexString("A7A7A7")
        
        subType2Label.font = UIFont.systemFontOfSize(14, weight: SystemFontWeight.Bold)
        subType2Label.textColor = UIColor.colorWithHexString("585959")
        subType2Label.numberOfLines = 1
        
        subType2View.backgroundColor = UIColor.colorWithHexString("A7A7A7")
        
        subType3Label.font = UIFont.systemFontOfSize(14, weight: SystemFontWeight.Bold)
        subType3Label.textColor = UIColor.colorWithHexString("585959")
        subType3Label.numberOfLines = 1
        
        subType3View.backgroundColor = UIColor.colorWithHexString("D4D4D4")
        
        subType4Label.font = UIFont.systemFontOfSize(14, weight: SystemFontWeight.Bold)
        subType4Label.textColor = UIColor.colorWithHexString("585959")
        subType4Label.numberOfLines = 1
        
        subType4View.backgroundColor = UIColor.colorWithHexString("E5E5E5")
        
        spinningIndicator.isHidden = true
        spinningIndicator.hidesWhenStopped = true
        spinningIndicator.color = UIColor.darkGray
        
        if USE_NEW_UI {
            setupNewUiLayout()
            
            contentView.backgroundColor = UIColor.groupTableViewBackground
        } else {
            setupAutoLayout()
        }

    }
    
    func setupAutoLayout() {
        
        let subviews = [
            titleLabel,
            authorsLabel,
            pageNumberLabel,
            openAccessLabel,
            bookmarkButton,
            authorsPlusButton,
            downloadButton,
            separatorView,
            numberOfVideosLabel,
            numberOfAudiosView,
            numberOfNotesView,
            subTypeView,
            subTypeLabel,
            spinningIndicator,
            subType2View,
            subType2Label,
            subType3View,
            subType3Label,
            subType4View,
            subType4Label
        ]
        
        constrain(subviews) { (views) in
            
            let titleL          = views[0]
            let authorsL        = views[1]
            let pageNumberL     = views[2]
            let openaccessL     = views[3]
            let bookmarkB       = views[4]
            let authorsPlusB    = views[5]
            let downloadB       = views[6]
            let separatorV      = views[7]
            let numberOfVideosV = views[8]
            let numberOfAudiosV = views[9]
            let numberOfNotesV  = views[10]
            let subTypeV        = views[11]
            let subTypeL        = views[12]
            let spinner         = views[13]
            let subType2V       = views[14]
            let subType2L       = views[15]
            let subType3V       = views[16]
            let subType3L       = views[17]
            let subType4V       = views[18]
            let subType4L       = views[19]
            
            guard let superview = titleL.superview else {
                return
            }
            
            subTypeV.top         == superview.top
            subTypeV.right       == superview.right
            subTypeV.left        == superview.left     + Config.Padding.Default
            subTypeView.layoutConstraints.height = (subTypeV.height == 0)
            
            subTypeL.centerY     == subTypeV.centerY
            subTypeL.left        == subTypeV.left + Config.Padding.Default
            subTypeL.right       == subTypeV.right - Config.Padding.Default
            
            subType2V.top        == subTypeV.bottom
            subType2V.right      == superview.right
            subType2V.left       == superview.left     + (Config.Padding.Default * 2)
            subType2View.layoutConstraints.height = (subType2V.height == 0)
            
            subType2L.centerY    == subType2V.centerY
            subType2L.left       == subType2V.left + Config.Padding.Default
            subType2L.right      == subType2V.right - Config.Padding.Default
            
            subType3V.top        == subType2V.bottom
            subType3V.right      == superview.right
            subType3V.left       == superview.left     + (Config.Padding.Default * 3)
            subType3View.layoutConstraints.height = (subType3V.height == 0)
            
            subType3L.centerY    == subType3V.centerY
            subType3L.left       == subType3V.left + Config.Padding.Default
            subType3L.right      == subType3V.right - Config.Padding.Default
            
            subType4V.top        == subType3V.bottom
            subType4V.right      == superview.right
            subType4V.left       == superview.left     + (Config.Padding.Default * 4)
            subType4View.layoutConstraints.height = (subType4V.height == 0)
            
            subType4L.centerY    == subType4V.centerY
            subType4L.left       == subType4V.left + Config.Padding.Default
            subType4L.right      == subType4V.right - Config.Padding.Default

            titleLabel.constraint.left = (titleL.left == superview.left + Config.Padding.Default)
            
            titleL.top           == subType4V.bottom + Config.Padding.Default
            titleL.right         == superview.right    - Config.Padding.Default
            
            authorsL.top         == titleL.bottom      + Config.Padding.Small
            authorsL.left        == titleL.left
            
            authorsPlusB.left    == authorsL.right     + Config.Padding.Default
            authorsPlusB.right   == superview.right    - Config.Padding.Default
            authorsPlusB.centerY == authorsL.centerY
            authorsPlusB.width   == 22
            authorsPlusB.height  == 22
            
            pageNumberL.top      == authorsL.bottom    + Config.Padding.Small
            pageNumberL.left     == authorsL.left
            pageNumberL.right    == superview.right    + Config.Padding.Default
            
            openaccessL.top      == pageNumberL.bottom + Config.Padding.Small
            openaccessL.left     == authorsL.left
            openaccessL.right    == superview.right    + Config.Padding.Default
            
            bookmarkB.top        == openaccessL.bottom + Config.Padding.Small
            bookmarkB.left       == authorsL.left
            bookmarkB.bottom     == superview.bottom   - Config.Padding.Default
            
            downloadB.top        == openaccessL.bottom + Config.Padding.Small
            downloadB.left       == bookmarkB.right + Config.Padding.Small
            downloadB.bottom     == superview.bottom   - Config.Padding.Default
            
            downloadButton.layoutConstraints.width = (downloadB.width == 0)
            downloadB.height     == 36
            
            numberOfNotesV.left    == downloadB.right        + Config.Padding.Small
            numberOfNotesV.centerY == bookmarkB.centerY
            
            numberOfVideosV.left    == numberOfNotesV.right  + Config.Padding.Small
            numberOfVideosV.centerY == bookmarkB.centerY
            
            numberOfAudiosV.left    == numberOfVideosV.right + Config.Padding.Small
            numberOfAudiosV.centerY == bookmarkB.centerY
            
            separatorV.right        == superview.right
            separatorV.bottom       == superview.bottom
            separatorV.left         == superview.left
            separatorV.height       == 1
            
            spinner.centerY         == downloadB.centerY
            spinner.centerX         == downloadB.centerX
        }
    }
    
    func setupNewUiLayout() {
        
        let subviews = [
            titleLabel,
            authorsLabel,
            pageNumberLabel,
            openAccessLabel,
            bookmarkButton,
            authorsPlusButton,
            downloadButton,
            separatorView,
            numberOfVideosLabel,
            numberOfAudiosView,
            numberOfNotesView,
            subTypeView,
            subTypeLabel,
            spinningIndicator,
            subType2View,
            subType2Label,
            subType3View,
            subType3Label,
            subType4View,
            subType4Label
        ]
        
        constrain(subviews) { (views) in
            
            let titleL          = views[0]
            let authorsL        = views[1]
            let pageNumberL     = views[2]
            let openaccessL     = views[3]
            let bookmarkB       = views[4]
            let authorsPlusB    = views[5]
            let downloadB       = views[6]
            let separatorV      = views[7]
            let numberOfVideosV = views[8]
            let numberOfAudiosV = views[9]
            let numberOfNotesV  = views[10]
            let subTypeV        = views[11]
            let subTypeL        = views[12]
            let spinner         = views[13]
            let subType2V       = views[14]
            let subType2L       = views[15]
            let subType3V       = views[16]
            let subType3L       = views[17]
            let subType4V       = views[18]
            let subType4L       = views[19]
            
            guard let superview = titleL.superview else {
                return
            }
            
            subTypeV.top         == superview.top
            subTypeV.right       == superview.right
            subTypeV.left        == superview.left     + Config.Padding.Default
            subTypeView.layoutConstraints.height = (subTypeV.height == 0)
            
            subTypeL.centerY     == subTypeV.centerY
            subTypeL.left        == subTypeV.left + Config.Padding.Default
            subTypeL.right       == subTypeV.right - Config.Padding.Default
            
            subType2V.top        == subTypeV.bottom
            subType2V.right      == superview.right
            subType2V.left       == superview.left     + (Config.Padding.Default * 2)
            subType2View.layoutConstraints.height = (subType2V.height == 0)
            
            subType2L.centerY    == subType2V.centerY
            subType2L.left       == subType2V.left + Config.Padding.Default
            subType2L.right      == subType2V.right - Config.Padding.Default
            
            subType3V.top        == subType2V.bottom
            subType3V.right      == superview.right
            subType3V.left       == superview.left     + (Config.Padding.Default * 3)
            subType3View.layoutConstraints.height = (subType3V.height == 0)
            
            subType3L.centerY    == subType3V.centerY
            subType3L.left       == subType3V.left + Config.Padding.Default
            subType3L.right      == subType3V.right - Config.Padding.Default
            
            subType4V.top        == subType3V.bottom
            subType4V.right      == superview.right
            subType4V.left       == superview.left     + (Config.Padding.Default * 4)
            subType4View.layoutConstraints.height = (subType4V.height == 0)
            
            subType4L.centerY    == subType4V.centerY
            subType4L.left       == subType4V.left + Config.Padding.Default
            subType4L.right      == subType4V.right - Config.Padding.Default
            
            titleLabel.constraint.left = (titleL.left == superview.left + Config.Padding.Default)
            
            titleL.top           == subType4V.bottom + Config.Padding.Double
            titleL.right         == superview.right    - Config.Padding.Default
            
            authorsL.top         == titleL.bottom      + Config.Padding.Default
            authorsL.left        == titleL.left
            
            authorsPlusB.left    == authorsL.right     + Config.Padding.Default
            authorsPlusB.right   == superview.right    - Config.Padding.Default
            authorsPlusB.centerY == authorsL.centerY
            authorsPlusB.width   == 22
            authorsPlusB.height  == 22
            
            pageNumberL.top      == authorsL.bottom    + Config.Padding.Small
            pageNumberL.left     == authorsL.left
            pageNumberL.right    == superview.right    + Config.Padding.Default
            
            openaccessL.top      == pageNumberL.bottom + Config.Padding.Small
            openaccessL.left     == authorsL.left
            openaccessL.right    == superview.right    + Config.Padding.Default
            
            bookmarkB.top        == openaccessL.bottom + Config.Padding.Small
            bookmarkB.left       == authorsL.left
            bookmarkB.bottom     == superview.bottom   - Config.Padding.Default
            
            downloadB.top        == openaccessL.bottom + Config.Padding.Small
            downloadB.left       == bookmarkB.right + Config.Padding.Small
            downloadB.bottom     == superview.bottom   - Config.Padding.Default
            
            downloadButton.layoutConstraints.width = (downloadB.width == 0)
            downloadB.height     == 36
            
            numberOfNotesV.left    == downloadB.right        + Config.Padding.Small
            numberOfNotesV.centerY == bookmarkB.centerY
            
            numberOfVideosV.left    == numberOfNotesV.right  + Config.Padding.Small
            numberOfVideosV.centerY == bookmarkB.centerY
            
            numberOfAudiosV.left    == numberOfVideosV.right + Config.Padding.Small
            numberOfAudiosV.centerY == bookmarkB.centerY
            
            separatorV.right        == superview.right
            separatorV.bottom       == superview.bottom
            separatorV.left         == superview.left
            separatorV.height       == 1
            
            spinner.centerY         == downloadB.centerY
            spinner.centerX         == downloadB.centerX
        }
        
    }
    
    
    
    //  MARK: Action
    // TODO: This fix is bad and we should feel bad. Accessibility shouldn't require a special
    // force of the table view being selected. Including for 6.0.0, but we should revisit at some point.
    func userClickedPlusButton() {
        if UIAccessibilityIsVoiceOverRunning() {
            highlightVC?.tableView((highlightVC?.tableView)!, didSelectRowAt: indexPath!)
            //issueVC?.tableView(issueVC!.tableView, didSelectRowAt: indexPath!)
            
            
        }
        if let indexPath = self.indexPath {
            authorPlusButtonDelegate?.authorPlusButtonWasClickedforIndexPath(indexPath)
            issueVC?.toggleAuthorList(indexPath: indexPath)
            highlightVC?.toggleAuthorList(indexPath: (indexPath as NSIndexPath) as IndexPath)
        }
    }
    
    func userClickedDownloadButton(_ sender: UIButton) {
        guard let article = self.article else {
            return
        }
        if article.downloadInfo.fullTextDownloadStatus == .downloaded {
            
            if article.canDeleteArticle == true {
                deleteOaArticle()
                
            } else if article.canDeleteArticle == false {
                delegate?.showCannotDeleteArticle()
            }
        } else if article.downloadInfo.fullTextDownloadStatus != .downloading {
            
            guard NETWORK_AVAILABLE == true && NETWORKING_ENABLED == true else {
                
                performOnMainThread({ 
                    
                    if let _vc = self.issueVC {
                        Alerts.NoNetwork().present(from:_vc)
                    
                    } else if let _vc = self.highlightVC {
                        
                        Alerts.NoNetwork().present(from: _vc)
                    }
                    
                })
                return
            }
            
            downloadOpenAccessArticle()
        }
    }
    
    
    func deleteOaArticle() {
        AnalyticsHelper.MainInstance.analyticsTagAction(AnalyticsHelper.ContentAction.deleteOaArticle, additionalInfo: "")
        performOnMainThread {
            let alertVC = UIAlertController(title: "Are you sure you want to delete?", message: "Deleting will remove this content from your device.", preferredStyle: .alert)
            
            let actionTitle = self.article?.fullTextSupplementDownloaded == true ? "Delete article with multimedia" : "Delete article"
            
            alertVC.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action) in
                performOnMainThread({
                    
                    ContentKit.SharedInstance.deleteArticle(self.article!, onlyMultimedia: false)
                    self.setDownloadButtonSelected(self.article!.downloadInfo.fullTextDownloadStatus)
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
            
            if let _issueVC = self.issueVC {
                _issueVC.present(alertVC, animated: true, completion: nil)
            
            } else if let _highlightVC = self.highlightVC {
                _highlightVC.present(alertVC, animated: true, completion: nil)
                
            } else if let parentJbsmViewController = self.parentJbsmViewController {
                parentJbsmViewController.present(alertVC, animated: true, completion: nil)
            } else {
                //MARK: - TODO Show error
            }
        }
    }
    
    func downloadOpenAccessArticle() {
        guard let article = self.article else { return }
        
        print("highlightVC on clicked cell == \(highlightVC)")
        
        if let _issueVC = issueVC {
            _issueVC.download(openAccessArticle: article, pushVC: false)
        
        } else if let _highlightVC = highlightVC {
            
            _highlightVC.download(openAccessArticle: article, pushVC: false)
            
        } else if let parentJbsmViewController = parentJbsmViewController {
            parentJbsmViewController.download(openAccessArticle: article, pushVC: false)
        } else {
            //MARK: - TODO Show error
        }
    }
    
    
    //  MARK: Notifications
    
    func setupNotificationsForOa() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(notification_oa_update(_:)), name: NSNotification.Name(rawValue: Notification.Download.Article.Started), object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_oa_update(_:)), name: NSNotification.Name(rawValue: Notification.Download.Article.Updated), object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_oa_update(_:)), name: NSNotification.Name(rawValue: Notification.Download.Article.Finished), object:nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notification_issue_update(_:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.DownloadStarted), object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_issue_update(_:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.DownloadComplete), object:nil)
    }
    
    func notification_oa_update(_ notification: Foundation.Notification) {
                
        performOnMainThread { [weak self] in
            guard let strongSelf = self,
                let article = notification.userInfo?["article"] as? Article else {
                      return
            }
            if strongSelf.article?.articleInfoId == article.articleInfoId {
                strongSelf.updateDownloadButton(article)
            }
        }
    }
    
    func notification_issue_update(_ notification: Foundation.Notification) {
        
        performOnMainThread {
            guard let issue = notification.object as? Issue else {
                return
            }

            if issue.issueId == self.article?.issueId {
                for _article in issue.allArticles {
                    let isMatch = _article.articleId == self.article?.articleId ? true : false
                    if isMatch == true {
                        self.updateDownloadButton(_article)
                        break
                    }
                }
            }
        }
    }
    
    
    //  MARK: Update view
            
    func updateDownloadButton(_ article: Article) {
        self.setDownloadButtonSelected(article.downloadInfo.fullTextDownloadStatus)
    }
    
    func setDownloadButtonSelected(_ status: DownloadStatus) {
        switch status {
        case .downloaded:
            performOnMainThread({
                self.downloadButton.isSelected = true
                self.downloadButton.tintColor = UIColor.navyBlueColor()
                self.spinningIndicator.stopAnimating()
                self.downloadButton.isAccessibilityElement = true
                self.downloadButton.accessibilityLabel = "Delete this article"
            })
        case .downloading:
            performOnMainThread({
                self.downloadButton.isSelected = false
                self.downloadButton.tintColor = UIColor.clear
                self.spinningIndicator.startAnimating()
                self.downloadButton.isAccessibilityElement = false
            })
        default:
            performOnMainThread({
                self.downloadButton.isSelected = false
                self.downloadButton.tintColor = UIColor.gray
                self.spinningIndicator.stopAnimating()
                
                self.downloadButton.isAccessibilityElement = true
                self.downloadButton.accessibilityLabel = "Download this article"
            })
        }
    }
    
    func update(_ article: Article, previousArticle: Article? = nil) {
        titleLabel.update(article.cleanArticleTitle)
        
        authorsLabel.update(article.author)
        pageNumberLabel.update(article.pageRange)

        openAccessLabel.update(article.showOpenAccessLabel ? article.openAccess.oaStatusDisplay : nil)
        
        let pageNumbers = article.pageRange?.components(separatedBy: "-")
        
        if let author = article.author, let _pageNumbers = pageNumbers {
            
            var openAccess = ""
            
            if article.showOpenAccessLabel == true, let oaStatus = article.openAccess.oaStatusDisplay {
                
                openAccess = oaStatus
            }

            
            guard let firstPage = _pageNumbers.first else { return }
            
            var pageLabel = ""
            
            if _pageNumbers.count == 1 {
                
                pageLabel = "page \(firstPage)"
            }
            else if _pageNumbers.count == 2, let lastPage = _pageNumbers.last {
                
                pageLabel = "pages " + firstPage + " through " + lastPage
            }

            let authorsAccessible = author.contains(",") ? "Authors: \(author). " :
                                                                  "Author: \(author). "
            
            var _accessibilityLabel = openAccess + " Article: \(article.cleanArticleTitle). " + authorsAccessible + pageLabel + ". "
            
            let notesCount = article.allNotes.count
            
            if notesCount > 0 {
                
                _accessibilityLabel += notesCount > 1 ? "\(notesCount) notes." :
                                       notesCount == 1 ? "\(notesCount) note." : ""
            }

            let audiosCount = article.audios.count

            if audiosCount > 0 {
                
                _accessibilityLabel += audiosCount > 1 ? "\(audiosCount) Audios." :
                                        audiosCount == 1 ? "\(audiosCount) Audio." : ""
            }
            
            let videosCount = article.videos.count
            if videosCount > 0 {
                
                _accessibilityLabel += videosCount > 1 ? "\(videosCount) videos." :
                                       videosCount == 1 ? "\(videosCount) video." : ""
            }

            contentView.isAccessibilityElement = true
            contentView.accessibilityLabel = _accessibilityLabel
            isAccessibilityElement = false
        }

        
        var showDownload = false
        if article.showOpenAccessLabel {
            if article.openAccess.oaIdentifier != 0 {
                showDownload = true
            }
        }
        accessibilityElements = [contentView, bookmarkButton, downloadButton]

        
        showDownloadButton(showDownload)

        bookmarkButton.update(article)
        if showDownload == true {
            setDownloadButtonSelected(article.downloadInfo.fullTextDownloadStatus)
            setupNotificationsForOa()
        }
        
        
        numberOfVideosLabel.count = article.videos.count
        numberOfAudiosView.count = article.audios.count
        numberOfNotesView.count = article.allNotes.count
        
        var subViewCount: CGFloat = 1
        
        if let subType = article.articleSubType {
            if subType != "" {
                subViewCount += 1
                if let _article = previousArticle {
                    if _article.articleSubType != subType {
                        subTypeView.layoutConstraints.height?.constant = 40
                        subTypeLabel.text = subType
                    } else {
                        subTypeView.layoutConstraints.height?.constant = 0
                    }
                } else {
                    subTypeView.layoutConstraints.height?.constant = 40
                    subTypeLabel.text = subType
                }
            }
        }
        
        if let subType2 = article.articleSubType2 {
            if subType2 != "" {
                subViewCount += 1
                if let _article = previousArticle {
                    if _article.articleSubType2 != subType2 {
                        subType2View.layoutConstraints.height?.constant = 40
                        subType2Label.text = subType2
                    } else {
                        subType2View.layoutConstraints.height?.constant = 0
                    }
                } else {
                    subType2View.layoutConstraints.height?.constant = 40
                    subType2Label.text = subType2
                }
            }
        }
        
        if let subType3 = article.articleSubType3 {
            if subType3 != "" {
                subViewCount += 1
                if let _article = previousArticle {
                    if _article.articleSubType3 != subType3 {
                        subType3View.layoutConstraints.height?.constant = 40
                        subType3Label.text = subType3
                    } else {
                        subType3View.layoutConstraints.height?.constant = 0
                    }
                } else {
                    subType3View.layoutConstraints.height?.constant = 40
                    subType3Label.text = subType3
                }
            }
        }
        
        if let subType4 = article.articleSubType4 {
            if subType4 != "" {
                subViewCount += 1
                if let _article = previousArticle {
                    if _article.articleSubType4 != subType4 {
                        subType4View.layoutConstraints.height?.constant = 40
                        subType4Label.text = subType4
                    } else {
                        subType4View.layoutConstraints.height?.constant = 0
                    }
                } else {
                    subType4View.layoutConstraints.height?.constant = 40
                    subType4Label.text = subType4
                }
            }
        }
        
        titleLabel.constraint.left?.constant = (Config.Padding.Default * subViewCount)
        
        if let text = article.author {
            let rect = text.boundingRect(with: CGSize(width: authorsLabel.frame.width, height: 200), options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), context: nil).size
            if rect.height > 34 {
                authorsPlusButton.isHidden = false
            }
        }
        self.article = article
    }
    
    func updateOnSearchVc(_ article: Article, searchType: SearchType, previousArticle: Article? = nil) {
        
        var titleString = ""
        let issue = article.issue
        let journal = article.journal
        guard let journalTitle = journal?.journalTitle else { return }
        
        var issueTitle = ""
        
        if let _issueTitle = issue?.displayTitle {
            
            issueTitle = _issueTitle + "\n"
        }
        
        switch searchType {
        case .AllJournals:
            titleString = journalTitle + "\n" + issueTitle + article.cleanArticleTitle
        default:
            titleString = issueTitle + article.cleanArticleTitle
        }
        
        titleLabel.update(titleString)
        
        titleLabel.accessibilityLabel = titleString.replacingOccurrences(of: "|", with: "")
        
        authorsLabel.update(article.author)
        pageNumberLabel.update(article.pageRange)
        
        print(article.openAccess.oaIdentifier)
        
        if article.isArticleOpenAccess || article.isArticleOpenArchive {
            if let statusDisplay = article.openAccess.oaStatusDisplay {
                openAccessLabel.update(statusDisplay)
            } else if let statusArchive = article.openAccess.oaStatusArchive {
                openAccessLabel.update(statusArchive)
            } else {
                openAccessLabel.update(nil)
            }
        } else {
            print("None")
            openAccessLabel.update(nil)
        }
        
        var showDownload = false
        if article.showOpenAccessLabel {
            if article.openAccess.oaIdentifier != 0 {
                showDownload = true
            }
        }
        showDownloadButton(showDownload)
        if showDownload == true {
            setDownloadButtonSelected(article.downloadInfo.fullTextDownloadStatus)
            setupNotificationsForOa()
        }
        bookmarkButton.update(article)
        numberOfVideosLabel.count = article.videos.count
        numberOfAudiosView.count = article.audios.count
        numberOfNotesView.count = article.allNotes.count
        
        let notesCount = numberOfNotesView.count
        numberOfNotesView.accessibilityLabel =  notesCount == 1 ? "\(notesCount) note" :
                                                                  "\(notesCount) notes"
        
        if let subType = article.articleSubType {
            if subType != "" {
                if let _article = previousArticle {
                    if _article.articleSubType != subType {
                        subTypeView.layoutConstraints.height?.constant = 40
                        subTypeLabel.text = subType
                    } else {
                        subTypeView.layoutConstraints.height?.constant = 0
                    }
                } else {
                    subTypeView.layoutConstraints.height?.constant = 40
                    subTypeLabel.text = subType
                }
            }
        }
        
        let font = authorsLabel.font
        let size = CGSize(width: frame.width - (Config.Padding.Default * 3), height: 200)
        let attributes = [NSFontAttributeName: font]
        if let text = article.author {
            let rect = text.boundingRect(with: size, options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), context: nil).size
            if rect.height > 34 {
                authorsPlusButton.isHidden = false
            }
        }
        self.article = article
    }
    
    func updateSubType(_ currentArticle: Article, previousArticle: Article?) {
        subTypeView.layoutConstraints.height?.constant = 0
        guard let subType = article?.articleSubType else { return }
        guard subType != "" else { return }
        if let previousSubType = previousArticle?.articleSubType {
            guard subType != previousSubType else { return }
        }
        subTypeView.layoutConstraints.height?.constant = 40
        subTypeLabel.text = subType
    }
    
    func showDownloadButton(_ show: Bool) {
        if show == true {
            downloadButton.isHidden = false
            downloadButton.layoutConstraints.width?.constant = 48
        } else {
            downloadButton.isHidden = true
            downloadButton.layoutConstraints.width?.constant = 0
            
            downloadButton.isAccessibilityElement = false
            
            accessibilityElements = [contentView, bookmarkButton]
        }
    }
    
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        titleLabel.reset()
        authorsLabel.reset()
        pageNumberLabel.reset()
        openAccessLabel.reset()
        setDownloadButtonSelected(.notDownloaded)
        NotificationCenter.default.removeObserver(self)
        
        subTypeLabel.text = nil
        subTypeView.layoutConstraints.height?.constant = 0
        
        subType2Label.text = nil
        subType2View.layoutConstraints.height?.constant = 0
        
        subType3Label.text = nil
        subType3View.layoutConstraints.height?.constant = 0
        
        subType4Label.text = nil
        subType4View.layoutConstraints.height?.constant = 0
        
        indexPath = nil
        authorsPlusButton.isHidden = true
        
        authorsPlusButton.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if shouldUseNewUi {
            addCornerWithShadow(toLayer:styleLayer, fillColor: UIColor.white, radius: 5, shadowColor: UIColor.gray, shadowOffset: CGSize(width: 0.0, height: 1.0), shadowOpacity: 1, shadowRadius: 1.5)
            
            contentView.layer.cornerRadius = 5
            contentView.layer.masksToBounds = true
        }
    }
}
