//
//  BookmarkTableViewCell.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/6/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class BookmarkTableViewCell: UITableViewCell {
    
    let issueLabel = IssueVolumeLabel()
    let authorLabel = ArticleAuthorLabel()
    let titleLabel = ArticleTitleLabel()
    let authorsPlusButton = UIButton(type: .custom)
    let aipLabel = AIPLabel()
    let savedDateLabel = StarredDateLabel()
    let oaLabel = OpenAccessLabel()
    
    let separatorLine = UIView()
    
    var indexPath: IndexPath?
    var bookmarksVC: BookmarksViewController?
    
    //let stackView = VerticalStackView()
    
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
    
    // MARK: - Setup -
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupStackView()
        setupIssueLabel()
        setupTitleLabel()
        setupAutoLayout()
        setupAuthorsPlusButton()
        setupAIPLabel()
        setupSavedDateLabel()
        
        separatorLine.backgroundColor = Config.Colors.TableViewSeparatorColor
        
        authorLabel.isUserInteractionEnabled = true
        authorLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userClickedPlusButton)))
        
        isAccessibilityElement = false
    }
    
    func setupSubviews() {
        contentView.addSubview(issueLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(authorsPlusButton)
        contentView.addSubview(aipLabel)
        contentView.addSubview(savedDateLabel)
        contentView.addSubview(separatorLine)
        contentView.addSubview(oaLabel)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            issueLabel,        // 0
            titleLabel,        // 1
            authorLabel,       // 2
            aipLabel,          // 3
            savedDateLabel,    // 4
            separatorLine,     // 5
            oaLabel,           // 6
            authorsPlusButton, // 7
        ]

        constrain(subviews) { (views) in
            
            let issueL         = views[0]
            let titleL         = views[1]
            let authorL        = views[2]
            let aipL           = views[3]
            let savedDateL     = views[4]
            let separatorLineV = views[5]
            let oaL            = views[6]
            let authorPB       = views[7]
            
            guard let superview = issueL.superview else {
                return
            }
            
            issueL.top == superview.top + Config.Padding.Default
            issueL.right == superview.right - Config.Padding.Default
            issueL.left == superview.left + Config.Padding.Default
            
            titleL.top == issueL.bottom + Config.Padding.Small
            titleL.right == superview.right - Config.Padding.Default
            titleL.left == superview.left + Config.Padding.Default
            
            authorL.top == titleL.bottom + Config.Padding.Small
            authorL.left == superview.left + Config.Padding.Default
            
            authorPB.left == authorL.right + Config.Padding.Default
            authorPB.right == superview.right - Config.Padding.Default
            authorPB.centerY == authorL.centerY
            authorPB.width   == 22
            authorPB.height  == 22
            
            aipLabel.constraint.top = (aipL.top == authorL.bottom + Config.Padding.Small)
            aipL.right == superview.right - Config.Padding.Default
            aipL.left == superview.left + Config.Padding.Default
            
            savedDateL.top == aipL.bottom + Config.Padding.Small
            savedDateL.right == superview.right - Config.Padding.Default
            savedDateL.left == superview.left + Config.Padding.Default
            
            oaL.top == savedDateL.bottom + Config.Padding.Default
            oaL.right == superview.right - Config.Padding.Default
            oaL.bottom == superview.bottom - Config.Padding.Default
            oaL.left == superview.left + Config.Padding.Default
            
            separatorLineV.right == superview.right
            separatorLineV.bottom == superview.bottom
            separatorLineV.left == superview.left
            separatorLineV.height == 1
        }
    }
    
    func setupStackView() {
        
    }
    
    func setupIssueLabel() {
        issueLabel.font = AppConfiguration.DefaultBoldTitleFont
    }
    
    func setupTitleLabel() {
        
    }
    
    func setupAuthorLabel() {
        
    }
    
    func setupAuthorsPlusButton() {
        
        authorsPlusButton.setTitle("+", for: UIControlState())
        authorsPlusButton.backgroundColor = UIColor.veryLightGray()
        authorsPlusButton.layer.borderColor = UIColor.gray.cgColor
        authorsPlusButton.layer.borderWidth = 1
        authorsPlusButton.layer.cornerRadius = 4
        authorsPlusButton.setTitleColor(UIColor.gray, for: UIControlState())
        
        authorsPlusButton.isHidden = false
        authorsPlusButton.addTarget(self, action: #selector(userClickedPlusButton), for: .touchUpInside)
    }
    
    func setupAIPLabel() {
        
    }
    
    func setupSavedDateLabel() {
        
    }
    
    // MARK: - Update -
    
    func update(_ article: Article) {
        if let issue = article.issue {
            issueLabel.isHidden = false
            issueLabel.text = "\(issue.releaseDateAbbrDisplay!) | Vol \(issue.volume!) | Issue \(issue.issueNumber!)"
            aipLabel.setActive(false)
        } else {
            aipLabel.setActive(true)
            aipLabel.update(article.dateOfRelease!)
        }
        titleLabel.text = article.cleanArticleTitle
        
        accessibilityLabel = accessibilityLabelForArticle(article)
        
        authorLabel.update(article.author)
        savedDateLabel.update(article.starredDate)

        if let text = article.author {
            let rect = text.boundingRect(with: CGSize(width: authorLabel.frame.width, height: 200), options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), context: nil).size
            if rect.height > 34 {
                authorsPlusButton.isHidden = false
            }
        }

        let oaText = article.openAccess.oaStatusDisplay
        oaLabel.update(oaText)
    }

    func userClickedPlusButton(_ sender: UIButton) {
        if UIAccessibilityIsVoiceOverRunning() {
            bookmarksVC?.tableView((bookmarksVC?.tableView)!, didSelectRowAt: indexPath!)
        }
        if let _indexPath = self.indexPath {
            
            bookmarksVC?.toggleAuthorList(_indexPath)
        }
    }
    
    func accessibilityLabelForArticle(_ article: Article) -> String? {
        
        var _accessibilityLabel = " "
        
        if let issue = article.issue {
            
            let releaseDate = "\(issue.releaseDateAbbrDisplay!)"
            _accessibilityLabel += releaseDate + " Volume " + issue.volume! + " Issue " + issue.issueNumber!
        }
        
        if let oaText = article.openAccess.oaStatusDisplay {
            
            _accessibilityLabel += " \(oaText)"
        }
        
        if let title = article.articleTitle {
            _accessibilityLabel += " Article, " + title + ". "
        }
        
        
        if let starredDate = article.starredDate {
            
            _accessibilityLabel += "Saved on \(starredDate). "
        }
        
        if bookmarksVC?.tableView.isEditing == true {
        
            if isSelected == false {
                _accessibilityLabel += "Unselected, double-tap to select"
                
            } else if isSelected == true {
                _accessibilityLabel += "Selected, double-tap to deselect"
            }
        }
        return _accessibilityLabel
    }

    // MARK: - Reuse -
    
    override func prepareForReuse() {
        issueLabel.isHidden = true
        authorLabel.setActive(false)
        aipLabel.setActive(false)
        savedDateLabel.isHidden = true
        authorsPlusButton.isHidden = true
    }
    
}
