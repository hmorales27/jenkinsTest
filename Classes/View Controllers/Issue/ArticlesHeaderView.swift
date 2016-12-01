//
//  IssuesArticlesHeaderView.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/19/15.
//  Copyright © 2015 Sharkey, Justin (ELS-CON). All rights reserved.
//

import UIKit
import Cartography

private let DownloadButtonText = "Download this issue"
private let DeleteButtonText = "Delete Issue"

struct ArticlesHeaderProxyViews {
    
    init?(views: [LayoutProxy]) {
        guard views.count == count else { return nil }
        mainView            = views[0]
        coverImageView      = views[1]
        issueTypeLavel      = views[2]
        issueDateLabel      = views[3]
        issueVolumeLabel    = views[4]
        downloadButton      = views[5]
        fullTextLabel       = views[6]
        collapseButton      = views[7]
        bottomSeparatorView = views[8]
        supplementLabel     = views[9]
        noteButton          = views[10]
        starredButton       = views[11]
        spinnerView         = views[12]
        openAccessLabel     = views[13]
        freeImageView       = views[14]
        overlayView         = views[15]
    }
    
    let count = 16
    
    let mainView            : LayoutProxy // 0
    let coverImageView      : LayoutProxy // 1
    let issueTypeLavel      : LayoutProxy // 2
    let issueDateLabel      : LayoutProxy // 3
    let issueVolumeLabel    : LayoutProxy // 4
    let downloadButton      : LayoutProxy // 5
    let fullTextLabel       : LayoutProxy // 6
    let collapseButton      : LayoutProxy // 7
    let bottomSeparatorView : LayoutProxy // 8
    let supplementLabel     : LayoutProxy // 9
    let noteButton          : LayoutProxy // 10
    let starredButton       : LayoutProxy // 11
    let spinnerView         : LayoutProxy // 12
    let openAccessLabel     : LayoutProxy // 13
    let freeImageView       : LayoutProxy // 14
    let overlayView         : LayoutProxy // 15
}

class HeaderInformation {
    var notDownloaded = false
    var downloading = false
    var downloaded = false
    var notes = false
    var bookmarks = false
    
    var status = IssueDownloadStatus.notDownloaded
    func downloadStatus() -> IssueDownloadStatus {
        if downloading == true {
            return .downloading
        } else {
            if notDownloaded {
                return .notDownloaded
            } else {
                return .downloaded
            }
        }
    }
}

enum IssueDownloadStatus {
    case notDownloaded
    case downloading
    case downloaded
}

enum HeaderState {
    case collapsed
    case expanded
}

// MARK: - Article Header View -

class ArticlesHeaderView: UIView, DMSectionDelegate {
    
    weak var heightConstraint : NSLayoutConstraint?
    weak var topConstraint    : NSLayoutConstraint?
    var constraintGroup       : ConstraintGroup?
    
    /* Views */
    let coverImageView      = CoverImageView()
    let freeImageView       = FreeImageView()
    let issueTypeLabel      = UILabel()
    let issueDateLabel      = IssueDateLabel()
    let issueVolumeLabel    = IssueVolumeLabel()
    let openAccessLabel     = OpenAccessLabel()
    let downloadButton      = IssueDownloadButton()
    let fullTextLabel       = UILabel()
    let supplementLabel     = UILabel()
    let bottomSeparatorView = UIView()
    let collapseButton      = SectionsData.CollapseButton()
    let noteButton          = IssueNotesButton()
    let starredButton       = IssueStarredButton()
    let spinnerView         = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    let overlayView = UIView()
    
    weak var issueVC : ArticlesViewController?
    weak var section : DMSection?
    weak var issue   : Issue?
   
    var baseAccessibility: String?
    
    var subviewList: [UIView] {
        return [
            self,                // 0
            coverImageView,      // 1
            issueTypeLabel,      // 2
            issueDateLabel,      // 3
            issueVolumeLabel,    // 4
            downloadButton,      // 5
            fullTextLabel,       // 6
            collapseButton,      // 7
            bottomSeparatorView, // 8
            supplementLabel,     // 9
            noteButton,          // 10
            starredButton,       // 11
            spinnerView,         // 12
            openAccessLabel,     // 13
            freeImageView,       // 14
            overlayView          // 15
        ]
    }
    
    var headerState: HeaderState = HeaderState.expanded
    
    // MARK: - Initialers -
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
    }
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    // MARK: - Setup -
    
    func setupNotifications(_ issue: Issue) {
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_issue(_:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.UpdateCount),      object: issue)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_issue(_:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.DownloadComplete), object: issue)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_issue(_:)), name: NSNotification.Name(rawValue: Notification.Download.Issue.DownloadStarted),  object: issue)
    }
    
    // MARK: - Update -

    func update(_ issue: Issue, issueVC: IssueDownloadButtonDelegate) {
        
        issueVolumeLabel.numberOfLines = 0
        
        self.issue = issue
        
        freeImageView.isHidden = true
        
        var coverImageAccessibility = issue.isFreeIssue == true ? "Free " : ""
        
        openAccessLabel.isHidden = true
        
        if let issueType = issue.issueTypeDisplay {
            issueTypeLabel.text = issueType
        }
        
        if issue.openAccess.oaIdentifier != 0 {
            if let text = issue.openAccess.oaStatusDisplay {
                openAccessLabel.update(text)
                coverImageAccessibility += text + " " + issue.issueTypeDisplay! + ". "
            } else {
                coverImageAccessibility += issue.issueTypeDisplay! + ". "
            }
        } else {
            coverImageAccessibility += issue.issueTypeDisplay! + ". "
        }
        
        if let issueDate = issue.releaseDateDisplay {
            coverImageAccessibility += issueDate + ". "
            issueDateLabel.text = issueDate
        }
        
        if let issueVolume = issue.issueLabelDisplay {
            issueVolumeLabel.text = issueVolume
            
            var _issueVolume = issueVolume
            _issueVolume = _issueVolume.replacingOccurrences(of: "Vol", with: "Volume")
            _issueVolume = _issueVolume.replacingOccurrences(of: "No.", with: "Number")
            
            if _issueVolume.contains("-") {
                _issueVolume = _issueVolume.replacingOccurrences(of: "p", with: "Pages: ")
                _issueVolume = _issueVolume.replacingOccurrences(of: "-", with: " through ")
            } else {
                _issueVolume = _issueVolume.replacingOccurrences(of: "p", with: "Page: ")
            }
            
            coverImageAccessibility += _issueVolume + ". "
        }
 
        overlayView.isAccessibilityElement = true
        overlayView.accessibilityLabel = coverImageAccessibility        
        baseAccessibility = coverImageAccessibility
        
        issueDateLabel.isAccessibilityElement = false
        issueVolumeLabel.isAccessibilityElement = false
        openAccessLabel.isAccessibilityElement = false
        fullTextLabel.isAccessibilityElement = false
        
        
        setupNotifications(issue)
        updateCoverImage(issue)
        
        updateSection()
        
        collapseButton.delegate = issueVC as? SectionDataCollapseButtonDelegate
        noteButton.delegate = self
        starredButton.delegate = self
    }
    
    
    func updateOffsetY(_ yPoint: CGFloat) {
        
        if yPoint > 0 {
            headerState = .collapsed
        } else {
            headerState = .expanded
        }
        
        setupAutoLayout(screenType: issueVC!.screenType)
    }
    
    func updateCoverImage(_ issue: Issue) {
        if issue.coverImagePath != nil {
            coverImageView.update(issue)
        } else {
            coverImageView.widthConstraint?.constant = 0
            coverImageView.leftConstraint?.constant = 0
        }
    }
    
    func updateNotesButton(_ count: Int) {
        if count == 0 {
            noteButton.isHidden = true
        } else {
            noteButton.isHidden = false
            noteButton.countLabel.text = String(count)
        }
    }
    
    func updateStarredButton(_ count: Int) {
        if count == 0 {
            starredButton.isHidden = true
        } else {
            starredButton.isHidden = false
            starredButton.countLabel.text = String(count)
        }
    }
    
    
    // MARK: - Notifications -
    
    func notification_download_issue(_ sender: Foundation.Notification) {
        updateSection()
    }
    
    func updateSection() {
        performOnMainThread { 
            self.attemptToGetSection()
            if let _section = self.section {
                self.sectionDidUpdate(section: _section)
            } else {
                self.showDownloadOrDeleteButton()
            }
        }
    }
    
    func attemptToGetSection() {
        guard let issue = self.issue else {
            return
        }
        let manager = DMManager.sharedInstance
        if let _section = manager.sectionForIssue(issue) {
            self.section = _section
        }
    }
    
    func showDownloadButton(_ show: Bool) {
        setupAutoLayout(screenType: self.issueVC!.screenType)
    }
    
    func showArticleCount(_ count: Int, total: Int) {
        if count == 0 && total == 0 {
            spinnerView.isHidden = true
            spinnerView.stopAnimating()
            fullTextLabel.isHidden = true
            fullTextLabel.text = nil
            
            if let _base = baseAccessibility {
                overlayView.accessibilityLabel = _base
            }
            
        } else {
            spinnerView.isHidden = false
            spinnerView.startAnimating()
            fullTextLabel.isHidden = false
            fullTextLabel.text = "\(count) of \(total) Articles"
            
            if let _base = baseAccessibility {
                overlayView.accessibilityLabel = _base + "\(count) of \(total) Articles downloaded"
            }
        }
    }
    
    func sectionDidUpdate(section: DMSection) {
        performOnMainThread {
            self.showDownloadOrDeleteButton()
        }
    }
    
    func showDownloadOrDeleteButton() {
        performOnMainThread { 

            guard let issue = self.issue else {
                return
            }
            var isDownloading = false
            
            let sections = DMManager.sharedInstance.sectionsWithFullText
            for section in sections {
                if section.issue == issue {
                    isDownloading = true
                }
            }
            
            if isDownloading == true {
                if issue.fullTextDownloadedCount == issue.fullTextTotalCount {
                    self.showDownloadButton(false)
                    self.showArticleCount(0, total: 0)
                } else {
                    self.showDownloadButton(false)
                    self.showArticleCount(issue.fullTextDownloadedCount, total: issue.fullTextTotalCount)
                }
            } else {
                
                let downloaded = issue.fullTextDownloadedCount
                let total = issue.fullTextTotalCount
                
                if downloaded == total {
                    self.showDownloadButton(false)
                    self.showArticleCount(0, total: 0)
                } else {
                    self.showDownloadButton(true)
                    self.showArticleCount(0, total: 0)
                }
            }
        }
    }

    // MARK: - Reset -
    
    func reset() {
        
    }
}

// MARK: - Setup -

extension ArticlesHeaderView {
    
    func setup(screenType type: ScreenType) {
        setupSubviews(screenType: type)
        setupView()
        setupAutoLayout(screenType: type)

        noteButton.issueHeader = self
        starredButton.issueHeader = self
        
        noteButton.isHidden = true
        noteButton.accessibilityLabel = "Notes Filter"
        noteButton.isAccessibilityElement = true
        
        starredButton.isHidden = true
        starredButton.accessibilityLabel = "Reading List Filter"
        starredButton.isAccessibilityElement = true
        
        issueTypeLabel.font = UIFont.systemFontOfSize(14, weight: SystemFontWeight.Light)
        spinnerView.isHidden = false
    }
    
    func setupSubviews(screenType type: ScreenType) {
        addSubview(overlayView)
        addSubview(coverImageView)
        addSubview(freeImageView)
        addSubview(issueTypeLabel)
        addSubview(issueDateLabel)
        addSubview(issueVolumeLabel)
        addSubview(downloadButton)
        addSubview(fullTextLabel)
        addSubview(supplementLabel)
        addSubview(collapseButton)
        addSubview(bottomSeparatorView)
        addSubview(noteButton)
        addSubview(starredButton)
        addSubview(spinnerView)
        addSubview(openAccessLabel)
    }

    func setupView() {
        issueTypeLabel.isAccessibilityElement = false
        collapseButton.accessibilityLabel = "Collapse All Articles."
        for view in subviewList {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}

// MARK: - Auto Layout -

extension ArticlesHeaderView {
    
    var headerInfo: HeaderInformation {
        let info = HeaderInformation()
        guard let issue = self.issue else { return info }
        for article in DatabaseManager.SharedInstance.getAllArticlesForIssue(issue) {
            switch article.downloadInfo.fullTextDownloadStatus {
            case .downloaded:
                info.downloaded = true
            case .downloading:
                info.downloading = true
            case .notDownloaded, .downloadFailed:
                info.notDownloaded = true
            default:
                break
            }
            if article.allNotes.count > 0 { info.notes = true }
            if article.starred == true { info.bookmarks = true }
        }
        if info.downloading {
            info.status = .downloading
        } else {
            if info.notDownloaded == true {
                info.status = .notDownloaded
            } else {
                info.status = .downloaded
            }
        }
        return info
    }
    
    func issueInfo() -> HeaderInformation? {
        let info = HeaderInformation()
        guard let issue = self.issue else { return nil }
        for article in DatabaseManager.SharedInstance.getAllArticlesForIssue(issue) {
            switch article.downloadInfo.fullTextDownloadStatus {
            case .downloaded:
                info.downloaded = true
            case .downloading:
                info.downloading = true
            case .notDownloaded, .downloadFailed:
                info.notDownloaded = true
            default:
                break
            }
            if article.allNotes.count > 0 { info.notes = true }
            if article.starred == true { info.bookmarks = true }
        }
        if info.downloading {
            info.status = .downloading
        } else {
            if info.notDownloaded == true {
                info.status = .notDownloaded
            } else {
                info.status = .downloaded
            }
        }
        return info
    }
    
    
    
    func setupAutoLayout(screenType type: ScreenType) {
        
        _setupAutoLayout(screenType: type)
        
        /*guard let issue = self.issue else { return }
        
        var color: UIColor = UIColor.grayColor()
        if let _color = issue.journal.color {
            color = _color
        }
        
        /* Download Button, Full Text Label */
        
        let info = headerInfo
        if info.notDownloaded == true && info.downloading == false {
            downloadButton.hidden = false
            fullTextLabel.hidden = true
            spinnerView.hidden = true
        } else if info.downloading == true {
            downloadButton.hidden = true
            fullTextLabel.hidden = false
            spinnerView.hidden = false
        } else {
            downloadButton.hidden = true
            fullTextLabel.hidden = true
            spinnerView.hidden = true
        }
        
        /* Notes Button, Starred Button */
        
        noteButton.hidden = !info.notes
        starredButton.hidden = !info.bookmarks
        
        /* Info */
        
        switch type {
        case .mobile:
            
            coverImageView.hidden = true
            freeImageView.hidden = true
            // issueTypeLabel
            issueDateLabel.hidden = false
            // issueVolumeLabel
            // Open Access Label
            
            collapseButton.hidden = true
            
            switch headerState {
            case .Collapsed:
                
                issueTypeLabel.hidden = true
                issueVolumeLabel.hidden = true
                openAccessLabel.hidden = true
                
            case .Expanded:
                
                issueTypeLabel.hidden = false
                issueVolumeLabel.hidden = false
                if issue.isIssueOpenAccess {
                    openAccessLabel.hidden = false
                }
                
            }
            
        case .tablet:

            issueDateLabel.hidden = false
            collapseButton.hidden = false
            
            switch headerState {
            case .Collapsed:
                coverImageView.hidden = true
                freeImageView.hidden = true
                issueTypeLabel.hidden = true
                issueVolumeLabel.hidden = true
            case .Expanded:
                coverImageView.hidden = false
                freeImageView.hidden = issue.coverImageShouldShowFreeLabel ? false : true
                issueTypeLabel.hidden = false
                issueVolumeLabel.hidden = false
            }
            break
        }
        
        switch type {
        case .mobile:
            backgroundColor = color
        case .tablet:
            switch headerState {
            case .Collapsed:
                backgroundColor = color
            case .Expanded:
                backgroundColor = UIColor.whiteColor()
            }

        }
        
        switch type {
        case .mobile:
            setupAutoLayoutForMobile()
        case .tablet:
            setupAutoLayoutforTablet()
        }*/
    }
    
    func setupAutoLayoutForMobile() {
        
        let info = headerInfo
        
        if let issue = self.issue {
            if let color = issue.journal.color {
                self.backgroundColor = color
            } else {
                self.backgroundColor = UIColor.gray
            }
        }
        
        issueTypeLabel.textColor = UIColor.white
        issueDateLabel.textColor = UIColor.white
        issueVolumeLabel.textColor = UIColor.white

        if let cg = constraintGroup { constrain(clear: cg) }
        
        constraintGroup = constrain(subviewList) { (_views) in
            
            guard let views = ArticlesHeaderProxyViews(views: _views) else { return }
            
            if headerState == .collapsed {
                
                views.issueDateLabel.top == views.mainView.top + Config.Padding.Default
                views.issueDateLabel.left == views.mainView.left + Config.Padding.Default
                views.issueDateLabel.right == views.mainView.right - Config.Padding.Default
                
                if info.notDownloaded == true && info.downloading == false {
                    
                    views.downloadButton.top == views.issueDateLabel.bottom + Config.Padding.Default
                    views.downloadButton.left == views.mainView.left + Config.Padding.Default
                    views.downloadButton.bottom == views.mainView.bottom - Config.Padding.Default
                    
                } else if info.downloading == true {
                    
                    views.fullTextLabel.top == views.issueDateLabel.bottom + Config.Padding.Default
                    views.fullTextLabel.left == views.spinnerView.right + Config.Padding.Default
                    views.fullTextLabel.bottom == views.mainView.bottom - Config.Padding.Default
                    
                    views.spinnerView.left == views.mainView.left + Config.Padding.Default
                    views.spinnerView.centerY == views.fullTextLabel.centerY
                    
                } else {
                    views.issueDateLabel.bottom == views.mainView.bottom - Config.Padding.Default
                }
            } else {
                
                views.issueTypeLavel.top == views.mainView.top + Config.Padding.Default
                views.issueTypeLavel.right == views.mainView.right - Config.Padding.Default
                views.issueTypeLavel.left == views.mainView.left + Config.Padding.Default
                
                views.issueDateLabel.top == views.issueTypeLavel.bottom + Config.Padding.Small
                views.issueDateLabel.right == views.mainView.right - Config.Padding.Default
                views.issueDateLabel.left == views.mainView.left + Config.Padding.Default
                
                views.issueVolumeLabel.top == views.issueDateLabel.bottom + Config.Padding.Small
                views.issueVolumeLabel.left == views.mainView.left + Config.Padding.Default
                
                views.openAccessLabel.top == views.issueVolumeLabel.bottom + Config.Padding.Small
                views.openAccessLabel.right == views.mainView.right - Config.Padding.Default
                views.openAccessLabel.left == views.mainView.left + Config.Padding.Default
                
                if info.notDownloaded == true && info.downloading == false {
                    views.downloadButton.top == views.openAccessLabel.bottom + Config.Padding.Default
                    views.downloadButton.left == views.mainView.left + Config.Padding.Default
                    views.downloadButton.bottom == views.mainView.bottom - Config.Padding.Default
                } else if info.downloading == true {
                    views.fullTextLabel.top == views.openAccessLabel.bottom + Config.Padding.Default
                    views.fullTextLabel.left == views.spinnerView.right + Config.Padding.Default
                    views.fullTextLabel.bottom == views.mainView.bottom - Config.Padding.Default
                    
                    views.spinnerView.left == views.mainView.left + Config.Padding.Default
                    views.spinnerView.centerY == views.fullTextLabel.centerY
                } else {
                    views.openAccessLabel.bottom == views.mainView.bottom - Config.Padding.Default
                }
            }
            
            // Download Button
            
            views.downloadButton.height == 32
            views.downloadButton.width == 150
            
            // Notes Button
            
            if info.notes {
                views.noteButton.right == views.mainView.right - Config.Padding.Default
                views.noteButton.bottom == views.mainView.bottom - Config.Padding.Default
                views.noteButton.height == 34
            }
            
            // Starred
            
            if info.bookmarks {
                if info.notes {
                    views.starredButton.right == views.noteButton.left - Config.Padding.Default
                } else {
                    views.starredButton.right == views.mainView.right - Config.Padding.Default
                }
                views.starredButton.bottom == views.mainView.bottom - Config.Padding.Default
                views.starredButton.height == 34
            }
            
            views.bottomSeparatorView.right == views.mainView.right
            views.bottomSeparatorView.bottom == views.mainView.bottom
            views.bottomSeparatorView.left == views.mainView.left
            views.bottomSeparatorView.height == 1
            
            views.mainView.height >= (34 + (Config.Padding.Default * 2))
        }
    }
    
    fileprivate func setupForDownloadButton(_ downloadStatus: IssueDownloadStatus, state: HeaderState, screenType: ScreenType) {
        switch screenType {
        case .mobile:
            switch state {
            case .collapsed:
                switch downloadStatus {
                case .notDownloaded:
                    break
                case .downloading:
                    break
                case .downloaded:
                    break
                }
            case .expanded:
                switch downloadStatus {
                case .notDownloaded:
                    break
                case .downloading:
                    break
                case .downloaded:
                    break
                }
            }
        case .tablet:
            switch state {
            case .collapsed:
                switch downloadStatus {
                case .notDownloaded:
                    downloadButton.isHidden  = false
                    fullTextLabel.isHidden   = true
                    spinnerView.isHidden     = true
                case .downloading:
                    downloadButton.isHidden  = true
                    fullTextLabel.isHidden   = false
                    spinnerView.isHidden     = false
                case .downloaded:
                    downloadButton.isHidden  = true
                    fullTextLabel.isHidden   = true
                    spinnerView.isHidden     = true
                }
            case .expanded:
                switch downloadStatus {
                case .notDownloaded:
                    downloadButton.isHidden  = false
                    fullTextLabel.isHidden   = true
                    spinnerView.isHidden     = true
                case .downloading:
                    downloadButton.isHidden  = true
                    fullTextLabel.isHidden   = false
                    spinnerView.isHidden     = false
                case .downloaded:
                    downloadButton.isHidden  = true
                    fullTextLabel.isHidden   = true
                    spinnerView.isHidden     = true
                }
            }
        }
    }
    
    func setupAutoLayoutforTablet() {
        
        guard let issue = self.issue else { return }
        
        let type = headerInfo.status
        
        setupForDownloadButton(type, state: headerState, screenType: .tablet)
        
        if let cg = constraintGroup { constrain(clear: cg) }
        
        switch headerState {
        case .collapsed:
            
            // Colors
            backgroundColor            = issue.journal.color ?? UIColor.gray
            issueTypeLabel.textColor   = UIColor.white
            issueDateLabel.textColor   = UIColor.white
            issueVolumeLabel.textColor = UIColor.white
            freeImageView.isHidden       = true
            
            // Hidden
            issueTypeLabel.isHidden      = true
            issueVolumeLabel.isHidden    = true
            coverImageView.isHidden      = true
            openAccessLabel.isHidden     = true
            
            switch type {
            case .notDownloaded:
                downloadButton.isHidden  = false
                fullTextLabel.isHidden   = true
                spinnerView.isHidden     = true
            case .downloading:
                downloadButton.isHidden  = true
                fullTextLabel.isHidden   = false
                spinnerView.isHidden     = false
            case .downloaded:
                downloadButton.isHidden  = true
                fullTextLabel.isHidden   = true
                spinnerView.isHidden     = true
            }
            
        case .expanded:
            
            // Colors
            backgroundColor            = UIColor.white
            issueTypeLabel.textColor   = UIColor.gray
            issueDateLabel.textColor   = UIColor.black
            issueVolumeLabel.textColor = UIColor.black
            
            // Hidden
            freeImageView.isHidden       = issue.coverImageShouldShowFreeLabel ? false : true
            issueTypeLabel.isHidden      = false
            issueVolumeLabel.isHidden    = false
            coverImageView.isHidden      = false
        }
        
        constraintGroup = constrain(subviewList) { (_views) -> () in
            
            guard let views = ArticlesHeaderProxyViews(views: _views) else { return }
            
            switch headerState {
            case .collapsed:
                
                views.issueDateLabel.left == views.mainView.left + Config.Padding.Default
                views.issueDateLabel.top == views.mainView.top + Config.Padding.Default
                views.issueDateLabel.right == views.mainView.right - Config.Padding.Default
                
                switch type {
                case .notDownloaded:
                    views.downloadButton.top == views.issueDateLabel.bottom + Config.Padding.Default
                    views.downloadButton.left == views.mainView.left + Config.Padding.Default
                    views.downloadButton.bottom == views.mainView.bottom - Config.Padding.Default
                    views.downloadButton.height == 32
                    views.downloadButton.width == 150
                case .downloading:
                    views.fullTextLabel.top == views.issueDateLabel.bottom + Config.Padding.Default
                    views.fullTextLabel.left == views.spinnerView.right + Config.Padding.Default
                    views.fullTextLabel.bottom == views.mainView.bottom - Config.Padding.Default
                    
                    views.spinnerView.left == views.mainView.left + Config.Padding.Default
                    views.spinnerView.centerY == views.fullTextLabel.centerY
                case .downloaded:
                    views.issueDateLabel.bottom == views.mainView.bottom - Config.Padding.Default
                }
                
            case .expanded:
                
                views.coverImageView.left     == views.mainView.left + Config.Padding.Default
                views.coverImageView.top      == views.mainView.top + Config.Padding.Default
                
                views.freeImageView.top       == views.coverImageView.top - 1
                views.freeImageView.right     == views.coverImageView.right + 1
                
                views.coverImageView.bottom   == views.mainView.bottom - Config.Padding.Default
                
                views.issueTypeLavel.left     == views.coverImageView.right   + Config.Padding.Default
                views.issueTypeLavel.top      == views.mainView.top      + 16
                views.issueTypeLavel.right    == views.mainView.right    - Config.Padding.Default
                
                views.issueDateLabel.left     == views.issueTypeLavel.left
                views.issueDateLabel.top      == views.issueTypeLavel.bottom   + Config.Padding.Default
                views.issueDateLabel.right    == views.mainView.right    - Config.Padding.Default
                
                views.issueVolumeLabel.left   == views.issueTypeLavel.left
                views.issueVolumeLabel.top    == views.issueDateLabel.bottom   + Config.Padding.Default
                views.issueVolumeLabel.right  == views.mainView.right    - Config.Padding.Default
                
                views.openAccessLabel.left    == views.issueTypeLavel.left
                views.openAccessLabel.top     == views.issueVolumeLabel.bottom   + Config.Padding.Default
                views.openAccessLabel.right   == views.mainView.right    - Config.Padding.Default
                
                switch type {
                case .notDownloaded:
                    views.downloadButton.top == views.openAccessLabel.bottom + Config.Padding.Default
                    views.downloadButton.left == views.coverImageView.right + Config.Padding.Default
                    views.downloadButton.height == 32
                    views.downloadButton.width == 150
                case .downloading:
                    views.spinnerView.left == views.coverImageView.right + Config.Padding.Default
                    views.spinnerView.centerY == views.fullTextLabel.centerY
                    
                    views.fullTextLabel.top == views.issueDateLabel.bottom + Config.Padding.Default
                    views.fullTextLabel.left == views.spinnerView.right + Config.Padding.Default
                case .downloaded:
                    break
                }
            }

            // Selection Buttons

            views.collapseButton.right == views.mainView.right - Config.Padding.Default
            views.collapseButton.bottom == views.mainView.bottom - Config.Padding.Default
            views.collapseButton.width == 120
            
            views.noteButton.height == 32
            views.noteButton.right == views.collapseButton.left - Config.Padding.Default
            views.noteButton.centerY == views.collapseButton.centerY
            
            views.starredButton.height == 32
            views.starredButton.right == views.noteButton.left - Config.Padding.Default
            views.starredButton.centerY == views.collapseButton.centerY
            
            // Bottom Separator
            
            views.bottomSeparatorView.right     == views.mainView.right
            views.bottomSeparatorView.bottom    == views.mainView.bottom
            views.bottomSeparatorView.left      == views.mainView.left
            views.bottomSeparatorView.height    == 1
        }
    }
}

extension ArticlesHeaderView: IssueNotesDelegate {
    
    func notesButtonWasClicked(_ button: IssueNotesButton) {
        updateFilterAndNotesButton(button)
    }
    
    func updateFilterAndNotesButton(_ button: IssueNotesButton) {
        button.backgroundColor      =  button.selected ? UIColor.veryLightGray() : UIColor.blue
        button.countLabel.textColor =  button.selected ? UIColor.darkGray : UIColor.white
        button.selected             = !button.selected
        
        button.accessibilityLabel = button.selected == true ? "Notes Filter, button, selected" : "Notes filter, button"
        
        if let issueVC = self.issueVC {
            issueVC.dataSource.showOnlyArticlesWithNotes = button.selected
            issueVC.sectionViewDidToggleCollapseAll(false)
            issueVC.reloadTableView()
        }
    }
}


extension ArticlesHeaderView: IssueStarDelegate {
    
    func starButtonWasClicked(_ button: IssueStarredButton) {
        updateFilterAndStarButton(button)
    }
    
    func updateFilterAndStarButton(_ button: IssueStarredButton) {
        setStarFilterActive(!button.selected)
    }
    
    func setStarFilterActive(_ active: Bool) {
        if active == false {
            starredButton.backgroundColor = UIColor.veryLightGray()
            starredButton.countLabel.textColor = UIColor.darkGray
            starredButton.selected = false
            starredButton.accessibilityLabel = "Reading list filter, button"
            
        } else {
            starredButton.backgroundColor = UIColor.blue
            starredButton.countLabel.textColor = UIColor.white
            starredButton.selected = true
            starredButton.accessibilityLabel = "Reading list filter, button, selected"
            
            self.issueVC!.sectionViewDidToggleCollapseAll(false)
        }
        issueVC?.dataSource.showOnlyStarredArticles = starredButton.selected
        issueVC?.reloadTableView()
    }
}

