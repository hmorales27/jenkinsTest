//
//  DMItemTableViewCell.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 4/8/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class DMItemTableViewCell: UITableViewCell, DMDeleteButtonDelegate {
    
    static let Identifier = "DMItemTableViewCell"
    
    let articleTitleLabel = UILabel()
    let progressView = UIProgressView(progressViewStyle: .bar)
    let cancelButton = DMDeleteButton()
    let downloadStatusLabel = UILabel()
    
    weak var item: DMTableViewItem?
    
    // MARK: - Initializer -
    
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
        
        setupArticleTitleLabel()
        setupDownloadStatusLabel()
        
        progressView.backgroundColor = UIColor.gray
        progressView.setProgress(0.0, animated: true)
        
        cancelButton.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress(_:)), name: NSNotification.Name(rawValue: Notification.Download.DMItem.Updated), object: nil)
    }
    
    func setupSubviews() {
        contentView.addSubview(articleTitleLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(cancelButton)
        contentView.addSubview(downloadStatusLabel)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            articleTitleLabel,
            progressView,
            cancelButton,
            downloadStatusLabel
        ]
        
        constrain(subviews) { (views) in
            
            let articleTitleL = views[0]
            let progressV = views[1]
            let cancelB = views[2]
            let downloadStatusL = views[3]
            
            guard let superview = articleTitleL.superview else {
                return
            }
            
            articleTitleL.top == superview.top + Config.Padding.Default
            articleTitleL.right == cancelB.left - Config.Padding.Default
            articleTitleL.left == superview.left + Config.Padding.Default
            
            progressV.top == articleTitleL.bottom + Config.Padding.Default
            progressV.left == superview.left + Config.Padding.Default
            
            cancelB.left == progressV.right + Config.Padding.Default
            cancelB.right == superview.right - Config.Padding.Default
            cancelB.centerY == superview.centerY
            
            downloadStatusL.top == progressV.bottom + Config.Padding.Default
            downloadStatusL.right == cancelB.left - Config.Padding.Default
            downloadStatusL.bottom == superview.bottom - Config.Padding.Default
            downloadStatusL.left == superview.left + Config.Padding.Default
        }
    }
    
    func setupArticleTitleLabel() {
        articleTitleLabel.text = "N/A"
    }
    
    func setupDownloadStatusLabel() {
        downloadStatusLabel.text = "Preparing for Download"
    }
    
    // MARK: - Update -
    
    func update(article: Article) {
        articleTitleLabel.text = article.cleanArticleTitle
    }
    
    func update(item: DMTableViewItem) {
        self.item = item
        guard let article = item.article else {
            return
        }
        
        if item.type == .FullText {
            articleTitleLabel.text = article.cleanArticleTitle
        } else {
            articleTitleLabel.text = article.cleanArticleTitle + " (Supplementary)"
        }
        
        articleTitleLabel.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
        
        var total     : Int = 0
        var completed : Int = 0
        var progress  : Float = 0
        
        switch item.type {
        case .FullText:
            completed = item.item.fullTextCompleted
            total = item.item.fullTextTotal
            progress = item.item.fullTextProgress
        case .FullTextSupplement:
            completed = item.item.fullTextSupplementCompleted
            total = item.item.fullTextSupplementTotal
            progress = item.item.fullTextSupplementProgress
        case .AbstractSupplement:
            completed = item.item.abstractSupplementCompleted
            total = item.item.abstractSupplementTotal
            progress = item.item.abstractSupplementProgress
        default:
            break
        }
        
        progressView.setProgress(progress, animated: false)
        
        if progress == 0 {
            downloadStatusLabel.text = "Preparing for download"
        } else {
            downloadStatusLabel.text = "\(completed.convertToFileSize()) of \(total.convertToFileSize()) Downloaded"
        }
    }
    
    func updateProgress(_ notification: Foundation.Notification) {
        guard let item = notification.object as? DMItem else {
            return
        }
        guard let tableItem = self.item else {
            return
        }
        if item === tableItem.item {
            performOnMainThread({ 
                self.update(item: tableItem)
            })
        }
    }
    
    func deleteButtonWasClicked() {
        guard let item = self.item else {
            return
        }
        let dItem = item.item
        let type = item.type
        
        dItem.invalidateType(type)
    }
    
    // MARK: - Reset -
    
    override func prepareForReuse() {
        reset()
    }
    
    func reset() {
        articleTitleLabel.text = ""
        progressView.setProgress(0.0, animated: false)
        downloadStatusLabel.text = ""
    }
}
