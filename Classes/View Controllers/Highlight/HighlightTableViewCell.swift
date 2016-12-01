//
//  HighlightTableViewCell.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/6/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let openAccessStartingText = "In Press Corrected Proof | "

class HighlightTableViewCell: UITableViewCell {
    
    static let CellIdentifier = "HighlightTableViewCell"
    
    weak var article: Article?
    
    var titleTextLabel = ArticleTitleLabel()
    var authorTextLabel = ArticleAuthorLabel()
    let openAccessLabel = OpenAccessLabel()
    let pageRangeLabel = PageNumberLabel()
    
    let bookmarkButton = BookmarkButton()
    let downloadButton = UIButton(type: UIButtonType.custom)
    
    let bottomSeparator = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        setupSubViews()
        setupAutoLayout()
        setupDownloadButton()
        
        bottomSeparator.backgroundColor = Config.Colors.TableViewSeparatorColor
    }
    
    func setupSubViews() {
        contentView.addSubview(titleTextLabel)
        contentView.addSubview(authorTextLabel)
        contentView.addSubview(openAccessLabel)
        contentView.addSubview(pageRangeLabel)
        contentView.addSubview(bookmarkButton)
        contentView.addSubview(downloadButton)
        contentView.addSubview(bottomSeparator)
    }
    
    func setupAutoLayout() {
        constrain(titleTextLabel) { (title) -> () in
            title.top == title.superview!.top + Config.Padding.Default
            title.left == title.superview!.left + Config.Padding.Default
            title.right == title.superview!.right - Config.Padding.Default
        }
        
        constrain(titleTextLabel, authorTextLabel) { (title, author) -> () in
            author.top == title.bottom + Config.Padding.Small
            author.left == author.superview!.left + Config.Padding.Default
            author.right == author.superview!.right - Config.Padding.Default
        }
        
        constrain(authorTextLabel, pageRangeLabel) { (authorTextLabel, pageRangeLabel) -> () in
            pageRangeLabel.left == pageRangeLabel.superview!.left + Config.Padding.Default
            pageRangeLabel.top == authorTextLabel.bottom + Config.Padding.Small
            pageRangeLabel.right == pageRangeLabel.superview!.right - Config.Padding.Default
        }
        
        constrain(pageRangeLabel, bookmarkButton) { (pageRangeLabel, bookmark) -> () in
            bookmark.top == pageRangeLabel.bottom + Config.Padding.Small
            bookmark.left == bookmark.superview!.left + Config.Padding.Default
            bookmark.bottom == bookmark.superview!.bottom + -Config.Padding.Default
        }
        
        constrain(bookmarkButton, downloadButton) { (bookmark, download) -> () in
            download.width == 44
            download.height == 44
            download.left == bookmark.right + Config.Padding.Default
            download.centerY == bookmark.centerY
        }
        
        constrain(bottomSeparator) { (bottomS) in
            guard let superview = bottomS.superview else {
                return
            }
            bottomS.right == superview.right
            bottomS.bottom == superview.bottom
            bottomS.left == superview.left
            bottomS.height == 1
        }
    }
    
    func setupDownloadButton() {
        downloadButton.setImage(UIImage(named: "Download"), for: UIControlState())
        downloadButton.setImage(UIImage(named: "Trash-Filled"), for: .selected)
        downloadButton.addTarget(self, action: #selector(downloadButtonClicked(_:)), for: UIControlEvents.touchUpInside)
        downloadButton.layer.borderColor = UIColor.gray.cgColor
        downloadButton.layer.borderWidth = 1.0
        downloadButton.layer.cornerRadius = 4.0
        downloadButton.backgroundColor = UIColor.veryLightGray()
        downloadButton.isHidden = true
        setDownloadButtonSelected(false)
    }
    
    func setup(_ article: Article) {
        self.article = article
        bookmarkButton.update(article)
        
        titleTextLabel.text = article.cleanArticleTitle
        if let authors = article.author {
            authorTextLabel.text = authors
        }
        pageRangeLabel.text = "p. " + article.pageRange!
        
        switch article.downloadInfo.fullTextDownloadStatus {
        case .downloaded:
            setDownloadButtonSelected(true)
        default:
            setDownloadButtonSelected(false)
        }
        
        var accessibility = "Article: "
        accessibility += article.cleanArticleTitle + ". "
        if let authors = article.author {
            accessibility += "Authors: \(authors). "
        }
        if var pages = article.pageRange {
            if pages.contains("-") {
                pages = "Pages: \(pages)"
                pages = pages.replacingOccurrences(of: "-", with: " through ")
            } else {
                pages = "Page: \(pages)"
            }
            accessibility += pages
        }
        
        self.accessibilityLabel = accessibility
    }
    
    func setDownloadButtonSelected(_ selected: Bool) {
        downloadButton.isSelected = selected
        if selected {
            downloadButton.tintColor = UIColor.navyBlueColor()
        } else {
            downloadButton.tintColor = UIColor.gray
        }
    }
    
    func downloadButtonClicked(_ sender: AnyObject) {
        guard let article = self.article else {
            return
        }
        switch article.downloadInfo.fullTextDownloadStatus {
        case .downloaded:
            setDownloadButtonSelected(true)
            // TODO: Delete Article
        default:
            setDownloadButtonSelected(false)
            // TODO: Download Article
        }
    }
    
    func setAuthorLabel(_ text: String?) {
        if let authors = text {
            authorTextLabel.text = authors
        } else {
            authorTextLabel.text = nil
        }
    }
    
    override func prepareForReuse() {
        titleTextLabel.text = nil
        authorTextLabel.text = nil
        bookmarkButton.setActive(false)
        setDownloadButtonSelected(false)
        downloadButton.isHidden = true
    }
}
