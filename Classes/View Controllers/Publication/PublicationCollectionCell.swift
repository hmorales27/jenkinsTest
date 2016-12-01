//
//  PublicationCollectionViewCell.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/10/15.
//  Copyright © 2015 Sharkey, Justin (ELS-CON). All rights reserved.
//

import UIKit
import Cartography

protocol PublicationCellDelegate: class {
    
    func stackViewSelectedForIssue(_ issue: Issue)
}



class PublicationCollectionCell: UICollectionViewCell {
    
    static let Identifier = "PublicationCollectionCell"
    
    struct Information {
        
        fileprivate struct CoverImageView {
            static let Height: CGFloat = 200
        }
        
        fileprivate struct IssueStackView {
            static let Height: CGFloat = 56
        }
        
        fileprivate static let Padding: CGFloat = 8
        
        fileprivate static let Height: CGFloat = Information.CoverImageView.Height + Information.IssueStackView.Height + (3 * Information.Padding)
        fileprivate static let Width: CGFloat = 300
        
        static var Size: CGSize {
            return CGSize(width: Information.Width, height: Information.Height)
        }
    }
    
    let coverImageView = CoverImageView()
    let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let freeImageView = FreeImageView()
    
    let journalView = UIView()
    let journalContainerView = UIView()
    
    let titleLabel = JournalTitleLabel()
    let openAccessLabel = OpenAccessLabel()
    let openArchiveLabel = UILabel()
    
    let issueStackBackgroundView = UIView()
    let issueDateLabel = IssueDateLabel()
    let issueVolumeLabel = IssueVolumeLabel()
    
    let issueTypeLabel = UILabel()
    
    weak var issue:Issue?
    weak var delegate: PublicationCellDelegate?
    
    // MARK: - Initializer -

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup -
    
    fileprivate func setup() {
        contentView.backgroundColor = UIColor.white
        setupView()
        setupSubviews()
        setupAutoLayout()
    }
    
    fileprivate func setupSubviews() {
        contentView.addSubview(journalView)
        
        journalView.addSubview(coverImageView)
        journalView.isAccessibilityElement = true
        
        coverImageView.addSubview(loadingIndicator)
        
        journalView.addSubview(freeImageView)
        
        journalView.addSubview(journalContainerView)
        
        journalContainerView.addSubview(titleLabel)
        titleLabel.isAccessibilityElement = false
        
        journalContainerView.addSubview(openAccessLabel)
        openAccessLabel.isAccessibilityElement = false
        openAccessLabel.numberOfLines = 0
        
        journalContainerView.addSubview(openArchiveLabel)
        openArchiveLabel.isAccessibilityElement = false
        openArchiveLabel.isHidden = true
        openArchiveLabel.font = AppConfiguration.DefaultSmallFont
        openArchiveLabel.numberOfLines = 0
        
        contentView.addSubview(issueStackBackgroundView)
        
        issueStackBackgroundView.addSubview(issueTypeLabel)
        issueTypeLabel.textColor = UIColor.gray
        issueTypeLabel.font = UIFont.systemFontOfSize(14, weight: SystemFontWeight.Light)
        
        issueStackBackgroundView.isAccessibilityElement = true
        issueStackBackgroundView.addSubview(issueDateLabel)
        
        issueDateLabel.isAccessibilityElement = false
        issueStackBackgroundView.addSubview(issueVolumeLabel)
        
        issueVolumeLabel.isAccessibilityElement = false

        contentView.clipsToBounds = true
        clipsToBounds = true
        issueStackBackgroundView.backgroundColor = UIColor.veryLightGray()
    }
    
    func setupJournal(_ journal: Journal, screenType: ScreenType) {
        setTitleLabel(journalTitle: journal.journalTitle)
        setOpenAccessLabel(oaStatus: journal.openAccess.oaStatusDisplay)
        setupOpenArchive(oaArchive: journal.openAccess.oaStatusArchive)

        if let firstIssue = journal.firstIssue {
            setupIssue(firstIssue, screenType: screenType)
        }
        
        titleLabel.textColor = journal.hexColorCode
        
        var accessibility: String = ""
        if var openAccess = journal.openAccess.oaStatusDisplay {
            if openAccess.lowercased() == "supports open access" {
                openAccess += " journal"
            }
            accessibility += openAccess + ". "
        
        }
        
        if let accessType = journal.accessType {
            
            accessibility = accessType == "Free Access" ? accessibility + "Free Journal, " : accessibility
        }
        
        if let journalTitle = journal.journalTitle {
            accessibility += journalTitle + ". "
        }
        
        if let openArchive = journal.openAccess.oaStatusArchive {
            accessibility += openArchive + ". "
        }

        journalView.accessibilityLabel = accessibility
    }
    
    fileprivate func setupIssue(_ issue: Issue, screenType: ScreenType) {
        self.issue = issue
        setupStackBackgroundView()
        setIssueDateLabel(releaseDate: issue.releaseDateDisplay)
        setIssueVolumeLabel(issueVolume: issue.issueLabelDisplay)
        coverImageView.update(issue)
        
        if let issueType = issue.issueTypeDisplay {
            self.issueTypeLabel.text = issueType
        }
        
        var accessibility: String = ""
        
        if let journalTitle = issue.journal.journalTitle {
            accessibility += "Journal: \(journalTitle). "
        }
        
        if let releaseDate = issue.releaseDateDisplay {
            accessibility += "Issue: \(releaseDate)"
        }
        
        if var issueLabel = issue.issueLabelDisplay {
            issueLabel = issueLabel.replacingOccurrences(of: "Vol", with: "Volume")
            issueLabel = issueLabel.replacingOccurrences(of: "No.", with: "Number")
            issueLabel = issueLabel.replacingOccurrences(of: "p", with: "Pages ")
            issueLabel = issueLabel.replacingOccurrences(of: "-", with: " through ")
            accessibility += " \(issueLabel)."
        }
        
        freeImageView.isHidden = issue.coverImageShouldShowFreeLabel ? false : true
        
        issueStackBackgroundView.accessibilityLabel = accessibility
    }
    
    // MARK: Main View
    
    fileprivate func setupView() {
        contentView.layer.cornerRadius = 8
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.borderWidth = 1.0
    }
    
    // MARK: Loading Indicator
    
    fileprivate func setupLoadingIndicator() {
        loadingIndicator.isHidden = true
    }
    
    // MARK: Title Label
    
    func setTitleLabel(journalTitle text: String?) {
        guard let journalTitle = text else {
            return
        }
        titleLabel.isHidden = false
        titleLabel.text = journalTitle
    }
    
    // MARK: Open Access Label
    
    func setOpenAccessLabel(oaStatus status: String?) {
        guard let oaStatus = status else {
            return
        }
        openAccessLabel.update(oaStatus)
    }
    
    func setupOpenArchive(oaArchive archive: String?) {
        guard let oaArchive = archive else {
            return
        }
        openArchiveLabel.text = oaArchive
        openArchiveLabel.isHidden = false
    }
    
    //  MARK: Stack background view 
    
    func setupStackBackgroundView() {
        
        let gestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(onStackViewTapped(_:)))
        issueStackBackgroundView.addGestureRecognizer(gestureRecognizer)
    }
    
    func onStackViewTapped(_ sender: UIView) {
        guard let _issue = issue else {
            
            return
        }
        delegate?.stackViewSelectedForIssue(_issue)
    }
    
    
    // MARK: Issue Date Label
    
    fileprivate func setIssueDateLabel(releaseDate date: String?) {
        guard let releaseDate = date else {
            return
        }
        issueDateLabel.text = releaseDate
        issueDateLabel.isHidden = false
    }
    
    // MARK: Issue Volume Label
    
    fileprivate func setIssueVolumeLabel(issueVolume volume: String?) {
        guard let issueVolume = volume else {
            return
        }
        issueVolumeLabel.text = issueVolume
        issueVolumeLabel.isHidden = false
    }
    
    // MARK: Auto Layout
    
    fileprivate func setupAutoLayout() {
        
        let subviews: [UIView] = [
            journalView,              // 0
            coverImageView,           // 1
            freeImageView,            // 2
            loadingIndicator,         // 3
            titleLabel,               // 4
            openAccessLabel,          // 5
            issueStackBackgroundView, // 6
            issueDateLabel,           // 7
            issueVolumeLabel,         // 8
            openArchiveLabel,         // 9
            issueTypeLabel,           // 10
            journalContainerView,     // 11
        ]
        
        constrain(subviews) { (views) in
            
            let journal         = views[0]
            let coverImage      = views[1]
            let freeImage       = views[2]
            let loading         = views[3]
            let title           = views[4]
            let openAccess      = views[5]
            let issueBackground = views[6]
            let issueDate       = views[7]
            let issueVolume     = views[8]
            let openArchive     = views[9]
            let issueTypeL      = views[10]
            let journalCV       = views[11]
            
            guard let superview = journal.superview else {
                return
            }
            
            // Cover Image
            
            journal.top            == superview.top
            journal.right          == superview.right
            journal.left           == superview.left
            
            coverImage.top         == journal.top            + Config.Padding.Default
            coverImage.bottom      == journal.bottom         - Config.Padding.Default
            coverImage.left        == journal.left           + Config.Padding.Default
            
            freeImage.top          == coverImage.top - 1
            freeImage.right        == coverImage.right + 1
            
            loading.centerX        == coverImage.centerX
            loading.centerY        == coverImage.centerY
            
            // Title
            
            journalCV.left         == coverImage.right       + Config.Padding.Default
            journalCV.right        == journal.right          - Config.Padding.Default
            journalCV.centerY      == coverImage.centerY
            
            title.top              == journalCV.top
            title.right            == journalCV.right
            title.left             == journalCV.left
            
            openAccess.top         == title.bottom
            openAccess.right       == journalCV.right
            openAccess.left        == journalCV.left
            
            openArchive.top        == journalCV.bottom
            openArchive.right      == journalCV.right
            openArchive.left       == journalCV.left
            openAccess.bottom      == journalCV.bottom
            
            // Issue

            issueBackground.top    == journal.bottom
            issueBackground.right  == superview.right
            issueBackground.bottom == superview.bottom
            issueBackground.left   == superview.left
            
            issueTypeL.left        == issueBackground.left   + Config.Padding.Default
            issueTypeL.width       == 80
            issueTypeL.centerY     == issueDate.centerY
            
            issueDate.top          == issueBackground.top    + Config.Padding.Small
            issueDate.right        == issueBackground.right  - Config.Padding.Default
            issueDate.left         == issueTypeL.right       + Config.Padding.Default
            
            issueVolume.right      == issueBackground.right  - Config.Padding.Default
            issueVolume.bottom     == issueBackground.bottom - Config.Padding.Small
            issueVolume.left       == issueDate.left
        }
    }
    
    // MARK: - Override -
    
    override func prepareForReuse() {
        coverImageView.image    = nil
        coverImageView.isHidden   = false
        freeImageView.isHidden    = true
        loadingIndicator.isHidden = true
        titleLabel.text         = nil
        titleLabel.isHidden       = true
        openAccessLabel.text    = nil
        openAccessLabel.isHidden  = true
        openArchiveLabel.text   = nil
        openArchiveLabel.isHidden = true
        issueDateLabel.text     = nil
        issueDateLabel.isHidden   = true
        issueVolumeLabel.text   = nil
        issueVolumeLabel.isHidden = true
    }
}
