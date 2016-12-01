//
//  UsageTableViewCell.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/8/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class UsageTableViewCell: UITableViewCell {
    
    fileprivate let titleLabel = UILabel()
    fileprivate let sizeLabel = UILabel()
    fileprivate let continueLabel = UIImageView()
    
    // MARK: - Initializers -
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Setup -
    
    fileprivate func setup() {
        setupSubviews()
        setupAutoLayout()
        setupTitleLabel()
        setupSizeLabel()
        setupContinueLabel()
    }
    
    fileprivate func setupSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(continueLabel)
    }
    
    fileprivate func setupAutoLayout() {
        constrain(titleLabel, sizeLabel, continueLabel) { (titleLabel, sizeLabel, continueLabel) -> () in
            guard let superview = titleLabel.superview else {
                return
            }
            
            titleLabel.left == superview.left + Config.Padding.Default
            titleLabel.top == superview.top + Config.Padding.Default
            titleLabel.bottom == superview.bottom - Config.Padding.Default
            titleLabel.height >= 28
            
            sizeLabel.left == titleLabel.right + Config.Padding.Default
            sizeLabel.centerY == titleLabel.centerY
            sizeLabel.width == 100
            
            continueLabel.left == sizeLabel.right + Config.Padding.Default
            continueLabel.centerY == sizeLabel.centerY
            continueLabel.right == superview.right - Config.Padding.Default
            continueLabel.width == 18
            continueLabel.height == 18
        }
    }
    
    fileprivate func setupTitleLabel() {
        titleLabel.font = UIFont.systemFontOfSize(16, weight: .Bold)
        titleLabel.numberOfLines = 0
    }
    
    fileprivate func setupSizeLabel() {
        sizeLabel.textColor = UIColor.blue
        sizeLabel.textAlignment = .right
        sizeLabel.font = UIFont.systemFontOfSize(16, weight: SystemFontWeight.Light)
        sizeLabel.text = 0.convertToFileSize()
    }
    
    fileprivate func setupContinueLabel() {
        if let image = UIImage(named: "Continue") {
            continueLabel.image = image
            continueLabel.tintColor = UIColor.gray
        }
    }
    
    fileprivate func updateAccessibility(_ journal: Journal) {
        
        guard let journalTitle = journal.journalTitle, let sizeText = sizeLabel.text else {
            
            return
        }
        accessibilityLabel = "Downloaded size of journal: " + journalTitle + " is \(sizeText). " + "Double-tap to go to detail."
    }
    
    
    // MARK: - Update -
    
    func update(_ journal: Journal) {
        updateTitleLabel(journal)
        updateSizeLabel(journal)
        
        updateAccessibility(journal)
    }
    
    fileprivate func updateTitleLabel(_ journal: Journal) {
        titleLabel.text = journal.journalTitle
    }
    
    fileprivate func updateSizeLabel(_ journal: Journal) {
        var size: Int = 0
        for article in DatabaseManager.SharedInstance.getAllArticlesforJournal(journal) {
            if article.downloadInfo.abstractSupplDownloadStatus == .downloaded {
                size += Int(article.downloadInfo.abstractSupplFileSize)
            } else {
                for media in article.allMedia where media.articleType == .abstract {
                    if media.downloadStatus == .downloaded {
                        size += Int(media.fileSize)
                    }
                }
            }
            if article.downloadInfo.fullTextDownloadStatus == .downloaded {
                size += Int(article.downloadInfo.fullTextFileSize)
            }
            
            if article.downloadInfo.fullTextSupplDownloadStatus == .downloaded {
                size += Int(article.downloadInfo.fullTextSupplFileSize)
            } else {
                for media in article.allMedia where media.articleType == .fullText {
                    if media.downloadStatus == .downloaded {
                        size += Int(media.fileSize)
                    }
                }
            }
        }
        sizeLabel.text = size.convertToFileSize()
    }
    
    // MARK: - Reset -
    
    override func prepareForReuse() {
        reset()
    }
    
    fileprivate func reset() {
        titleLabel.text = nil
        sizeLabel.text = 0.convertToFileSize()
    }
    
}
