//
//  IVCCell.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/24/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class IssueCollectionViewCell: UICollectionViewCell {
    
    let accessibilityView = UIView()
    
    var coverImageView   = CoverImageView()
    fileprivate var issueTypeLabel   = UILabel()
    fileprivate var issueDateLabel   = IssueDateLabel()
    fileprivate var issueVolumeLabel = UILabel()
    fileprivate var openAccessLabel  = OpenAccessLabel()
    fileprivate var openArchiveLabel = JBSMLabel()
    fileprivate var freeImageView    = FreeImageView()
    
    let notesButton = IssueNotesButton()
    let starredButton = IssueStarredButton()
    
    let popoverSourceView = UIView()
    
    fileprivate var downloadedIcon   = UIImageView(image: UIImage(named: "DownloadedIssue"))
    
    fileprivate var deleteIssueButton = UIButton(type: .custom)
    fileprivate weak var deleteIssueButtonHeightConstraint: NSLayoutConstraint?
    
    fileprivate var issue: Issue?
    
    weak var viewController: IssuesViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        
        layer.cornerRadius = 8
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1.0
        clipsToBounds = true
        
        setupSubviews()
        setupIssueTypeLabel()
        setupIssueVolumeLabel()
        setupLayout()
        
        openAccessLabel.isHidden = true
        
        openArchiveLabel.isHidden = true
        openArchiveLabel.textColor = UIColor.orange
        openArchiveLabel.font = AppConfiguration.DefaultSmallFont
        
        downloadedIcon.isHidden = true
        
        deleteIssueButton.setTitleColor(UIColor.darkGray, for: UIControlState())
        deleteIssueButton.backgroundColor = UIColor.lightGray()
        deleteIssueButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        deleteIssueButton.titleLabel?.textAlignment = NSTextAlignment.right
        deleteIssueButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        deleteIssueButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        deleteIssueButton.addTarget(self, action: #selector(deleteButtonClicked(_:)), for: .touchUpInside)
        deleteIssueButton.isHidden = true
        
        backgroundColor = UIColor.white
        
        accessibilityView.isAccessibilityElement = true
        isAccessibilityElement = false
        issueTypeLabel.isAccessibilityElement = false
        issueDateLabel.isAccessibilityElement = false
        issueVolumeLabel.isAccessibilityElement = false
        openAccessLabel.isAccessibilityElement = false
        openArchiveLabel.isAccessibilityElement = false
        coverImageView.isAccessibilityElement = false
        
        starredButton.isAccessibilityElement = true
        starredButton.accessibilityLabel = "Reading List Filter"
        
        
        //  **Refactor--make func 'setupNotesButton', and there remove the default action
        //  attached to the gesture recognizer on notesButton.
        
        //  Replace it with another action, which will send the user to
        notesButton.isAccessibilityElement = true
        notesButton.accessibilityLabel = "Notes Filter"
        deleteIssueButton.isAccessibilityElement = true
        deleteIssueButton.accessibilityLabel = "Delete Issue Button"
        
        popoverSourceView.backgroundColor = UIColor.clear
    }
    
    fileprivate func setupSubviews() {
        contentView.addSubview(accessibilityView)
        
        contentView.addSubview(coverImageView)
        contentView.addSubview(issueTypeLabel)
        contentView.addSubview(issueDateLabel)
        contentView.addSubview(issueVolumeLabel)
        contentView.addSubview(freeImageView)
        
        contentView.addSubview(openAccessLabel)
        contentView.addSubview(openArchiveLabel)
        contentView.addSubview(downloadedIcon)
        contentView.addSubview(deleteIssueButton)
        
        contentView.addSubview(notesButton)
        contentView.addSubview(starredButton)
        
        contentView.addSubview(popoverSourceView)
    }
    
    fileprivate func setupIssueTypeLabel() {
        issueTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        issueTypeLabel.numberOfLines = 0
        issueTypeLabel.font = UIFont.systemFontOfSize(12, weight: .Light)
        issueTypeLabel.textColor = UIColor.gray
    }
    
    fileprivate func setupIssueVolumeLabel() {
        issueVolumeLabel.translatesAutoresizingMaskIntoConstraints = false
        issueVolumeLabel.numberOfLines = 0
    }
    
    fileprivate func setupAccessibilityView() {
        
        
    }

    fileprivate func setupLayout() {
        
        let subviews = [
            coverImageView,
            issueTypeLabel,
            issueDateLabel,
            issueVolumeLabel,
            freeImageView,
            openAccessLabel,
            openArchiveLabel,
            downloadedIcon,
            deleteIssueButton,
            notesButton,
            starredButton,
            accessibilityView,
            popoverSourceView
        ]
        
        constrain(subviews) { (views) in
            
            let coverIV      = views[0]
            let issueTypeL   = views[1]
            let issueDateL   = views[2]
            let issueVolumeL = views[3]
            let freeIV       = views[4]
            let openAccessL  = views[5]
            let openArchiveL = views[6]
            let downloadedIV = views[7]
            let deleteIssueB = views[8]
            let notesB       = views[9]
            let starredB     = views[10]
            let accessibility = views[11]
            let popoverSourceV = views[12]
            
            guard let superview = coverIV.superview else {
                return
            }
            
            accessibility.top == superview.top
            accessibility.right == superview.right
            accessibility.bottom == superview.bottom
            accessibility.left == superview.left
            
            downloadedIV.width  == 54
            downloadedIV.height == 54
            downloadedIV.top    == superview.top
            downloadedIV.right  == superview.right
            
            deleteIssueB.right == superview.right
            deleteIssueB.bottom == superview.bottom
            deleteIssueB.left == superview.left
            deleteIssueB.height == 24
            
            popoverSourceV.centerY == deleteIssueB.centerY
            popoverSourceV.height == 1
            popoverSourceV.width == 1
            popoverSourceV.right == superview.right - 10
            
            coverIV.top         == superview.top       + Config.Padding.Default
            coverIV.bottom      == deleteIssueB.top    - Config.Padding.Default
            coverImageView.leftConstraint  = (coverIV.left == superview.left)
            coverImageView.widthConstraint = (coverIV.width == 0)
            
            freeIV.top          == coverIV.top - 1
            freeIV.right        == coverIV.right + 1
            freeIV.width        == 40
            freeIV.height       == 40
            
            issueTypeL.top      == superview.top       + Config.Padding.Default
            issueTypeL.right    == superview.right     - Config.Padding.Default
            issueTypeL.left     == coverIV.right       + Config.Padding.Default
            
            issueDateL.top      == issueTypeL.bottom   + Config.Padding.Small
            issueDateL.right    == superview.right     - Config.Padding.Default
            issueDateL.left     == coverIV.right       + Config.Padding.Default
            
            issueVolumeL.top    == issueDateL.bottom   + Config.Padding.Small
            issueVolumeL.right  == superview.right     - Config.Padding.Default
            issueVolumeL.left   == coverIV.right       + Config.Padding.Default
            
            openAccessLabel.constraint.top    = ( openAccessL.top    == issueVolumeL.bottom + Config.Padding.Small   )
            openAccessLabel.constraint.right  = ( openAccessL.right  == superview.right     - Config.Padding.Default )
            openAccessLabel.constraint.left   = ( openAccessL.left   == coverIV.right       + Config.Padding.Default )
            
            openArchiveLabel.constraint.top   = ( openArchiveL.top   == openAccessL.bottom  + Config.Padding.Small   )
            openArchiveLabel.constraint.right = ( openArchiveL.right == superview.right     - Config.Padding.Default )
            openArchiveLabel.constraint.left  = ( openArchiveL.left  == coverIV.right       + Config.Padding.Default )
            
            starredB.bottom == deleteIssueB.top - Config.Padding.Default
            starredB.left   == coverIV.right + Config.Padding.Default
            
            notesB.left     == starredB.right + Config.Padding.Default
            notesB.centerY  == starredB.centerY
        }
    }
    
    // MARK: - Setup Subviews -

    func setupIssue(_ issue: Issue) {
        
        var accessibility = ""
        
        var issueType = ""
        
        if let _issueTypeDisplay = issue.issueTypeDisplay {
            issueTypeLabel.text = _issueTypeDisplay
            issueType = _issueTypeDisplay
        }
        openAccessLabel.isHidden = true
        openArchiveLabel.isHidden = true
        
        if issue.openArchive() == true {
            accessibility += "Open Archive "
        } else if issue.isFreeIssue == true {
            accessibility += "Free "
        }
        if issue.shouldShowOpenAccessLabel {
            
            if let openAccess = issue.openAccess.oaStatusDisplay {
                openAccessLabel.isHidden = false
                openArchiveLabel.isHidden = true
                openAccessLabel.update(openAccess)
            } else {
                accessibility += issueType + ". "
            }
        } else {
            accessibility += issueType + ". "
        }
        
        if let releaseDateDisplay = issue.releaseDateDisplay {
            issueDateLabel.text = releaseDateDisplay
            accessibility += releaseDateDisplay + ". "
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

            accessibility += _issueVolume + ". "
        }
        freeImageView.isHidden = issue.coverImageShouldShowFreeLabel ? false : true
        
        updateDeleteButtonForIssue(issue)
        
        var notesCount = 0
        var starredCount = 0
        
        for article in issue.allArticles {
            if article.starred == true {
                starredCount += 1
            }
            if article.allNotes.count > 0 {
                notesCount += 1
            }
        }
        
        if notesCount > 0 {
            notesButton.isHidden = false
            notesButton.countLabel.text = String(notesCount)
        } else {
            notesButton.isHidden = true
        }
        
        if starredCount > 0 {
            starredButton.layoutConstraints.width?.constant = 60
            starredButton.isHidden = false
            starredButton.countLabel.text = String(starredCount)
        } else {
            starredButton.layoutConstraints.width?.constant = 0
            starredButton.isHidden = true
        }
        
        if issue.issuePii != self.issue?.issuePii {
            coverImageView.image = nil
            coverImageView.update(issue)
        }
        accessibilityView.accessibilityLabel = accessibility
        
        self.issue = issue
    }
    
    func refresh() {
        guard let issue = self.issue else { return }
        
        let articles = DatabaseManager.SharedInstance.getAllArticlesForIssue(issue)
        
        var notesCount = 0
        var starredCount = 0
        
        for article in articles {
            if article.starred == true {
                starredCount += 1
            }
            if article.allNotes.count > 0 {
                notesCount += 1
            }
        }
        
        if notesCount > 0 {
            notesButton.isHidden = false
            notesButton.countLabel.text = String(notesCount)
        } else {
            notesButton.isHidden = true
        }
        
        if starredCount > 0 {
            starredButton.layoutConstraints.width?.constant = 60
            starredButton.isHidden = false
            starredButton.countLabel.text = String(starredCount)
        }
        else {
            starredButton.layoutConstraints.width?.constant = 0
            starredButton.isHidden = true
        }
        updateDeleteButtonForIssue(issue)
    }
    
    fileprivate func updateDeleteButtonForIssue(_ issue: Issue?) {
        
        if let issue = issue {
            if issue.downloaded() == true {
            downloadedIcon.isHidden = false
            
            let downloaded = issue.fullTextDownloadedCount
            let size = Numbers.fullSizeForIssue(issue)
            
            deleteIssueButton.isHidden = false
            deleteIssueButton.setTitle("\(downloaded) Articles - \(size.convertToFileSize()) | X", for: UIControlState())
            deleteIssueButton.accessibilityLabel = "Downloaded size of \(downloaded) articles is \(size.convertToFileSize()). Double tap for more detail."
            deleteIssueButtonHeightConstraint?.constant = 24
               
            return
            }
        }
        //  Either no issue was passed in or issue is not downloaded
        deleteIssueButton.setTitle("", for: UIControlState())
        deleteIssueButton.isHidden = true
        deleteIssueButtonHeightConstraint?.constant = 0
    }
    
    // MARK: - Reuse -
    
    override func prepareForReuse() {
        reset()
    }
    
    func deleteButtonClicked(_ sender: UIButton) {
        let presentView = DeleteIssuePopover(issue: self.issue!)
        presentView.cell = self
        let navigationVC = UINavigationController(rootViewController: presentView)
        navigationVC.modalPresentationStyle = UIModalPresentationStyle.popover
        navigationVC.popoverPresentationController?.sourceView = popoverSourceView
        navigationVC.popoverPresentationController?.backgroundColor = AppConfiguration.NavigationBarColor
        navigationVC.popoverPresentationController?.delegate = viewController
        navigationVC.preferredContentSize = CGSize(width: 300, height: 140)
        navigationVC.popoverPresentationController?.permittedArrowDirections = [.up, .left, .down, .right]
        viewController?.present(navigationVC, animated: true, completion: nil)
        viewController?.popover = navigationVC.popoverPresentationController
    }
    
    fileprivate func reset() {
        issueTypeLabel.text = ""
        issueDateLabel.text = ""
        issueVolumeLabel.text = ""
        freeImageView.isHidden = true
        
        openAccessLabel.isHidden = true
        openAccessLabel.text = ""
        openAccessLabel.constraint.top?.constant = Config.Padding.Small
        
        openArchiveLabel.isHidden = true
        openArchiveLabel.text = ""
        openArchiveLabel.constraint.top?.constant = Config.Padding.Small
        
        downloadedIcon.isHidden = true
        
        updateDeleteButtonForIssue(nil)
        notesButton.isHidden = true
        starredButton.isHidden  = true
    }
}

class DeleteIssuePopover: UIViewController {
    
    let issueLabel = UILabel()
    
    let articleMultimediaLabel = UILabel()
    let articleMultimediaSizeLabel = UILabel()
    let articleMultimediaDeleteButton = UILabel()
    
    let multimediaLabel = UILabel()
    let multimediaSizeLabel = UILabel()
    let multimediaDeleteButton = UILabel()
    
    let noteLabel = UILabel()
    
    weak var cell: IssueCollectionViewCell?
    
    weak var issue: Issue?
    
    init(issue: Issue) {
        super.init(nibName: nil, bundle: nil)
        self.issue = issue
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        
        self.view.isUserInteractionEnabled = true
        
        guard let issue = self.issue else {
            return
        }
        
        view.backgroundColor = UIColor.white
        if let date = issue.releaseDateDisplay {
            title = "Delete \(date)?"
        }
        
//        var fullTextMultimediaSize : Int = 0
        let mediaSize = multimediaSize()
        let totalSize = Numbers.fullSizeForIssue(issue)
        
        articleMultimediaLabel.font = UIFont.systemFontOfSize(12, weight: SystemFontWeight.Bold)
        articleMultimediaLabel.text = "Articles & Multimedia"
        articleMultimediaLabel.accessibilityLabel = "Downloaded size of article and multimedia is " + totalSize.convertToFileSize()
        
        articleMultimediaSizeLabel.text = totalSize.convertToFileSize()
        articleMultimediaSizeLabel.font = UIFont.systemFontOfSize(12, weight: SystemFontWeight.Regular)
        articleMultimediaSizeLabel.textColor = UIColor.blue
        
        articleMultimediaDeleteButton.text = "Delete"
        articleMultimediaDeleteButton.textColor = UIColor.white
        articleMultimediaDeleteButton.backgroundColor = UIColor.colorWithHexString("7F0000")
        articleMultimediaDeleteButton.layer.cornerRadius = 4
        articleMultimediaDeleteButton.font = UIFont.systemFontOfSize(12, weight: SystemFontWeight.Bold)
        articleMultimediaDeleteButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteFullTextMultimedia)))
        articleMultimediaDeleteButton.isUserInteractionEnabled = true
        articleMultimediaDeleteButton.textAlignment = NSTextAlignment.center
        articleMultimediaDeleteButton.clipsToBounds = true
        articleMultimediaDeleteButton.accessibilityLabel = "Delete article and Multimedia"
        
        multimediaLabel.font = UIFont.systemFontOfSize(12, weight: SystemFontWeight.Bold)
        multimediaLabel.text = "Multimedia Only"
        
        //  Replace this passed-in text with 'combined multimedia'
        multimediaLabel.accessibilityLabel = "Downloaded size of multimedia only is " + mediaSize.convertToFileSize()
        
        multimediaSizeLabel.text = mediaSize.convertToFileSize()
        multimediaSizeLabel.font = UIFont.systemFontOfSize(12, weight: SystemFontWeight.Regular)
        multimediaSizeLabel.textColor = UIColor.blue
        
        multimediaDeleteButton.text = "Delete"
        multimediaDeleteButton.textColor = UIColor.white
        multimediaDeleteButton.backgroundColor = UIColor.colorWithHexString("7F0000")
        multimediaDeleteButton.layer.cornerRadius = 4
        multimediaDeleteButton.font = UIFont.systemFontOfSize(12, weight: SystemFontWeight.Bold)
        multimediaDeleteButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteMultimedia)))
        multimediaDeleteButton.isUserInteractionEnabled = true
        multimediaDeleteButton.textAlignment = NSTextAlignment.center
        multimediaDeleteButton.clipsToBounds = true
        multimediaDeleteButton.accessibilityLabel = "Delete multimedia only"
        
        if mediaSize == 0 {
            multimediaDeleteButton.isEnabled = false
            multimediaDeleteButton.isUserInteractionEnabled = false
        }
        noteLabel.text = "Articles in Reading List and with notes will not be deleted."
        noteLabel.numberOfLines = 0
        noteLabel.font = UIFont.systemFontOfSize(14, weight: SystemFontWeight.Regular)
    }
    
    func multimediaSize() -> Int {
        
            var multimediaSize = 0
            var issueSupplement: Int = 0
            
            guard let _issue = issue else { return 0 }
            
            let articles = DatabaseManager.SharedInstance.getAllArticlesForIssue(_issue)
            
            for article in articles {
                
                var supplement: Int = 0
                if article.downloadInfo.abstractSupplDownloadStatus == .downloaded {
                    supplement += Int(article.downloadInfo.abstractSupplFileSize)
                }
                
                if article.downloadInfo.fullTextSupplDownloadStatus == .downloaded {
                    supplement += Int(article.downloadInfo.fullTextSupplFileSize)
                } else {
                    for media in article.allMedia {
                        if media.downloadStatus == .downloaded {
                            supplement += Int(media.fileSize)
                        }
                    }
                }
                issueSupplement += supplement
            }
            multimediaSize = issueSupplement
            return multimediaSize
    }
    
    
    
    func deleteFullTextMultimedia() {
        performOnMainThread {
            let alertVC = Alerts.Delete { (delete) in
                if delete == true {
                    ContentKit.SharedInstance.deleteIssue(self.issue!, onlyMultimedia: false, completion: { (success) in
                        performOnMainThread({
                            self.cell?.viewController?.setupDisplayForSelectedSegment()
                            let alertVC = Alerts.ArticlesDeleted()
                            self.cell?.viewController?.dismiss(animated: true, completion: nil)
                            self.cell?.viewController?.present(alertVC, animated: true, completion: nil)
                        })
                    })
                }
            }
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func deleteMultimedia() {
        performOnMainThread {
            let alertVC = Alerts.Delete { (delete) in
                if delete == true {
                    ContentKit.SharedInstance.deleteIssue(self.issue!, onlyMultimedia: true, completion: { (success) in
                        performOnMainThread({
                            self.cell?.viewController?._collectionView.reloadData()
                            let alertVC = Alerts.ArticlesDeleted()
                            self.cell?.viewController?.dismiss(animated: true, completion: nil)
                            self.cell?.viewController?.present(alertVC, animated: true, completion: nil)
                        })
                    })
                }
            }
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func setupSubviews() {
        view.addSubview(issueLabel)
        
        view.addSubview(articleMultimediaLabel)
        view.addSubview(articleMultimediaSizeLabel)
        view.addSubview(articleMultimediaDeleteButton)
        
        view.addSubview(multimediaLabel)
        view.addSubview(multimediaSizeLabel)
        view.addSubview(multimediaDeleteButton)
        
        view.addSubview(noteLabel)
    }
    
    func setupAutoLayout() {
        let subviews = [
            issueLabel,
            articleMultimediaLabel,
            articleMultimediaSizeLabel,
            articleMultimediaDeleteButton,
            multimediaLabel,
            multimediaSizeLabel,
            multimediaDeleteButton,
            noteLabel
        ]
        constrain(subviews) { (views) in
            let issueL                   = views[0]
            let articleMultimediaL       = views[1]
            let articleMultimediaSizeL   = views[2]
            let articleMultimediaDeleteB = views[3]
            let multimediaL              = views[4]
            let multimediaSizeL          = views[5]
            let multimediaDeleteB        = views[6]
            let noteL                    = views[7]
            
            guard let superview = issueL.superview else {
                return
            }
            
            // Article & Multimedia
            
            articleMultimediaL.top           == superview.top + Config.Padding.Default
            articleMultimediaL.left          == superview.left + Config.Padding.Default
            articleMultimediaL.height        == 32
            
            articleMultimediaSizeL.centerY   == articleMultimediaL.centerY
            //articleMultimediaSizeL.left      == articleMultimediaL.right + Config.Padding.Small
            
            articleMultimediaDeleteB.centerY == articleMultimediaL.centerY
            articleMultimediaDeleteB.right   == superview.right - Config.Padding.Default
            articleMultimediaDeleteB.left    == articleMultimediaSizeL.right + Config.Padding.Small
            articleMultimediaDeleteB.width   == 60
            articleMultimediaDeleteB.height  == 30
            
            // Multimedia
            
            multimediaL.top                  == articleMultimediaL.bottom + Config.Padding.Default
            multimediaL.left                 == superview.left + Config.Padding.Default
            multimediaL.height               == 32
            
            multimediaSizeL.centerY          == multimediaL.centerY
            //multimediaSizeL.left             == multimediaL.right + Config.Padding.Small
            
            multimediaDeleteB.centerY        == multimediaL.centerY
            multimediaDeleteB.right          == superview.right - Config.Padding.Default
            multimediaDeleteB.left           == multimediaSizeL.right + Config.Padding.Small
            multimediaDeleteB.width          == 60
            multimediaDeleteB.height         == 30
            
            noteL.right                      == superview.right - Config.Padding.Default
            noteL.bottom                     == superview.bottom - Config.Padding.Default
            noteL.left                       == superview.left + Config.Padding.Default
        }
    }
}

extension IssueCollectionViewCell: IssueNotesDelegate {
    
    func notesButtonWasClicked(_ button: IssueNotesButton) {
        
        //  Give direction to issuesViewController to handle this action appropriately.
        
    }
}
