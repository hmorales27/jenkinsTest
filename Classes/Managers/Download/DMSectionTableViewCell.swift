//
//  DMSectionTableViewCell.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 4/7/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class DMSectionTableViewCell: UITableViewCell, DMDeleteButtonDelegate {
    
    static let Identifier = "DMSectionTableViewCell"
    
    let issueLabel = JBSMLabel()
    
    let fulltextCountLabel = JBSMLabel()
    let supplementCountLabel = JBSMLabel()
    
    let progressView = UIProgressView()
    let deleteButton = DMDeleteButton()
    
    let articleListLabel = UILabel()
    
    weak var issue: Issue?
    weak var article: Article?
    
    weak var item: DMItem?
    
    // MARK: - Initializers -
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup -
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupIssueLabel()
        setupArticleListLabel()
        
        deleteButton.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemWasUpdated(_:)), name: NSNotification.Name(rawValue: Notification.Download.DMItem.Updated), object: nil)
        
        deleteButton.isAccessibilityElement = true
        deleteButton.accessibilityLabel = "Cancel Download"
        
        articleListLabel.isAccessibilityElement = false
    }
    
    func setupSubviews() {
        contentView.addSubview(issueLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(deleteButton)
        contentView.addSubview(fulltextCountLabel)
        contentView.addSubview(supplementCountLabel)
        contentView.addSubview(articleListLabel)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            issueLabel,
            fulltextCountLabel,
            supplementCountLabel,
            progressView,
            articleListLabel,
            deleteButton
        ]
        
        constrain(subviews) { (views) in
            
            let issueL = views[0]
            let fulltextCountL = views[1]
            let supplementCountL = views[2]
            let progressV = views[3]
            let articleListL = views[4]
            let deleteB = views[5]
            
            guard let superview = issueL.superview else {
                return
            }
            
            issueLabel.constraint.top             = (issueL.top == superview.top + Config.Padding.Default)
            issueLabel.constraint.right           = (issueL.right == superview.right - Config.Padding.Default)
            issueLabel.constraint.left            = (issueL.left == superview.left + Config.Padding.Default)
            
            progressV.top       == issueL.bottom + Config.Padding.Default
            progressV.left      == superview.left + Config.Padding.Default
            
            deleteB.left        == progressV.right + Config.Padding.Default
            deleteB.right       == superview.right - Config.Padding.Default
            deleteB.centerY     == progressV.centerY
            
            fulltextCountLabel.constraint.top     = (fulltextCountL.top == progressV.bottom + Config.Padding.Default)
            fulltextCountLabel.constraint.right   = (fulltextCountL.right == superview.right - Config.Padding.Default)
            fulltextCountLabel.constraint.left    = (fulltextCountL.left == superview.left + Config.Padding.Default)
            
            supplementCountLabel.constraint.top   = (supplementCountL.top == fulltextCountL.bottom + Config.Padding.Small)
            supplementCountLabel.constraint.right = (supplementCountL.right == superview.right - Config.Padding.Default)
            supplementCountLabel.constraint.left  = (supplementCountL.left == superview.left + Config.Padding.Default)
            
            articleListL.top    == supplementCountL.bottom + Config.Padding.Small
            articleListL.right  == superview.right - Config.Padding.Default
            articleListL.bottom == superview.bottom - Config.Padding.Default
            articleListL.left   == superview.left + Config.Padding.Default
        }
    }
    
    func setupIssueLabel() {
        issueLabel.font = AppConfiguration.DefaultBoldTitleFont
        issueLabel.textColor = AppConfiguration.PrimaryColor
        issueLabel.adjustsFontSizeToFitWidth = true
        issueLabel.minimumScaleFactor = 0.8
        issueLabel.numberOfLines = 1
    }
    
    func setupArticleListLabel() {
        let text = "Full Article List"
        let attributes: [String: AnyObject] = [
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject,
            NSForegroundColorAttributeName: AppConfiguration.PrimaryColor
        ]
        articleListLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
    
    // MARK: - Update -
    
    func update(section: DMSection) {
        switch section.type {
        case .issue:
            guard let issue = section.issue else {
                return
            }
            
            let ftCount = issue.fullTextDownloadedCount
            let ftTotal = issue.fullTextTotalCount
            
            let supplCount = issue.fullTextAndAbstractSupplementDownloadedCount
            let supplTotal = issue.fullTextAndAbstractSupplementTotalcount
            
            let count = ftCount + supplCount
            let total = ftTotal + supplTotal
            
            self.issue = issue
            self.updateIssueLabel(issue)
            self.updateFullTextLabel(ftCount, total: ftTotal)
            self.updateSupplementLabel(supplCount, total: supplTotal)
            self.updateProgressView(Float(Float(count) / Float(total)))
        case .aip:
            guard let article = section.article else {
                return
            }
            guard let item = section.itemForArticle(article) else {
                return
            }
            self.item = item
            self.article = article
            self.updateForAIP(aipItem: item)
        default:
            return
        }
    }
    
    func itemWasUpdated(_ notification: Foundation.Notification) {
        guard let item = notification.object as? DMItem else {
            return
        }
        
        if item === self.item {
            performOnMainThread({ 
                self.updateForAIP(aipItem: item)
            })
            
        }
    }
    
    func updateForAIP(aipItem item: DMItem) {
        
        let article = item.article
        
        performOnMainThread { 
            self.updateAIPLabel(article)
        }
        
        var ftCount = 0
        var ftTotal = 0
        
        var supCount = 0
        var supTotal = 0
        
        var fullTextExpectedSize           : Int = 0
        var fullTextSupplementExpectedSize : Int = 0
        var abstractSupplementExpectedSize : Int = 0
        
        var fullTextProgress           : Float = 0.0
        var fullTextSupplementProgress : Float = 0.0
        var abstractSupplementProgress : Float = 0.0
        
        if item.fullTextExists == true {
            ftTotal += 1
            fullTextExpectedSize = Int(article.downloadInfo.fullTextFileSize)
            fullTextProgress = item.fullTextProgress
        }
        if item.fullTextDownloaded == true {
            ftCount += 1
        }
        
        if item.fullTextSupplementExists == true {
            supTotal += 1
            fullTextSupplementExpectedSize = Int(article.downloadInfo.fullTextSupplFileSize)
            fullTextSupplementProgress = item.fullTextSupplementProgress
        }
        if item.fullTextSupplementDownloaded == true {
            supCount += 1
        }
        
        if item.abstractSupplementExists == true {
            supTotal += 1
            abstractSupplementExpectedSize = Int(article.downloadInfo.abstractSupplFileSize)
            abstractSupplementProgress = item.abstractSupplementProgress
        }
        if item.abstractsupplementDownloaded == true {
            supCount += 1
        }
        
        performOnMainThread { 
            self.updateFullTextLabel(ftCount, total: ftTotal)
            self.updateSupplementLabel(supCount, total: supTotal)
        }
        
        let fullTextDownloadedSize = Float(fullTextExpectedSize) * fullTextProgress
        let fullTextSupplementDownloadedSize = Float(fullTextSupplementExpectedSize) * fullTextSupplementProgress
        let abstractSupplementdownloadedSize = Float(abstractSupplementExpectedSize) * abstractSupplementProgress
        
        let downloadedSize = fullTextDownloadedSize + fullTextSupplementDownloadedSize + abstractSupplementdownloadedSize
        let totalSize = Float(fullTextExpectedSize + fullTextSupplementExpectedSize + abstractSupplementExpectedSize)
        
        let percent = downloadedSize / totalSize
        
        performOnMainThread {
            self.updateProgressView(percent)
        }
    }
    
    func update(article: Article) {
        issueLabel.text = "AIP"
    }
    
    func updateIssueLabel(_ issue: Issue) {

        var issueLabelText = ""
        
        if let dateText = issue.releaseDateDisplay {
            issueLabelText += dateText
        }
        if let volumeText = issue.volume {
            issueLabelText += " | Volume \(volumeText)"
        }
        if let numberText = issue.issueNumber {
            issueLabelText += " | Issue \(numberText)"
        }
        
        issueLabel.text = issueLabelText
    }
    
    func updateAIPLabel(_ article: Article) {
        issueLabel.text = article.cleanArticleTitle
    }
    
    func updateAIPProgress(_ article: Article) {
        fulltextCountLabel.text = "Preparing for Download"
    }
    
    func updateFullTextLabel(_ downloaded: Int, total: Int) {
        fulltextCountLabel.isHidden = false
        fulltextCountLabel.text = "\(downloaded)/\(total) articles are downloaded"
    }
    
    func updateSupplementLabel(_ downloaded: Int, total: Int) {
        if total == 0 {
            supplementCountLabel.isHidden = true
            supplementCountLabel.text = ""
        } else {
            supplementCountLabel.isHidden = false
            supplementCountLabel.text = "\(downloaded)/\(total) supplements are downloaded"
        }
    }
    
    func updateProgressView(_ progress: Float) {
        progressView.progress = progress
    }
    
    // MARK: - Reset -
    
    override func prepareForReuse() {
        
    }
    
    func reset() {
        issueLabel.text = ""
        
        fulltextCountLabel.text = ""
        fulltextCountLabel.isHidden = true
        
        supplementCountLabel.text = ""
        supplementCountLabel.isHidden = true
        
        self.item = nil
    }
    
    // MARK: - Methods -
    
    func deleteButtonWasClicked() {
        
        if let issue = self.issue {
            DMManager.sharedInstance.cancelDownloadForIssue(issue)
        } else if let article = self.article {
            DMManager.sharedInstance.cancelDownloadForAIP(article)
        }
    }
}
