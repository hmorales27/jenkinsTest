//
//  UsageIssueTableViewCell.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/8/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

protocol UsageIssueTableViewCellDelegate: class {
    func usageIssueTableViewCellDidClickDelete(_ indexPath: IndexPath)
}

class UsageIssueTableViewCell: UITableViewCell {
    
    fileprivate let titleLabel = UILabel()
    fileprivate let sizeLabel = UILabel()
    fileprivate let deleteButton = UIButton(type: .custom)
    
    weak var viewController: UsageIssueViewController?
    
    weak var issue: Issue?
    
    weak var delegate: UsageIssueTableViewCellDelegate?
    var indexPath: IndexPath?
    
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
        setupDeleteButton()
    }
    
    fileprivate func setupSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(deleteButton)
    }
    
    fileprivate func setupAutoLayout() {
        constrain(titleLabel, sizeLabel, deleteButton) { (titleLabel, sizeLabel, deleteButton) -> () in
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
            
            deleteButton.left == sizeLabel.right + Config.Padding.Default
            deleteButton.centerY == sizeLabel.centerY
            deleteButton.right == superview.right - Config.Padding.Default
            deleteButton.width == 80
            deleteButton.height == 30
            
        }
    }
    
    fileprivate func setupTitleLabel() {
        titleLabel.font = AppConfiguration.DefaultBoldFont
        titleLabel.numberOfLines = 0
    }
    
    fileprivate func setupSizeLabel() {
        sizeLabel.textColor = UIColor.blue
        sizeLabel.textAlignment = .right
        sizeLabel.text = 0.convertToFileSize()
    }
    
    fileprivate func setupDeleteButton() {
        deleteButton.isHidden = true
        deleteButton.setTitle("Delete", for: UIControlState())
        deleteButton.setTitleColor(UIColor.white, for: UIControlState())
        deleteButton.backgroundColor = UIColor.colorWithHexString("7F0000")
        deleteButton.layer.cornerRadius = 4
        deleteButton.addTarget(self, action: #selector(deleteButtonClicked(_:)), for: .touchUpInside)
    }
    
    // MARK: - Update -
    
    func update(_ issue: Issue) {
        self.issue = issue
        
        updateTitleLabel(issue)
        updateSizeLabel(issue)
        updateAccessibilityLabel(issue)
    }
    
    fileprivate func updateTitleLabel(_ issue: Issue) {
        titleLabel.text = issue.releaseDateDisplay
    }
    
    fileprivate func updateSizeLabel(_ issue: Issue) {
        var size = 0
        let articles = DatabaseManager.SharedInstance.getAllArticlesForIssue(issue)
        for article in articles {
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
        if size > 0 {
            deleteButton.isHidden = false
            
            if let dateDisplay = issue.releaseDateDisplay {
                deleteButton.accessibilityLabel = "Delete \(dateDisplay) issue"
            }
        }
    }
    
    fileprivate func updateAccessibilityLabel(_ issue: Issue) {
        
        guard let dateDisplay = issue.releaseDateDisplay, let sizeText = sizeLabel.text else {
            
            return
        }
        accessibilityLabel = "Downloaded size of \(dateDisplay) issue is \(sizeText)."
    }
    
    
    // MARK: - Reset -
    
    override func prepareForReuse() {
        reset()
    }
    
    fileprivate func reset() {
        titleLabel.text = nil
        sizeLabel.text = 0.convertToFileSize()
        deleteButton.isHidden = true
    }
    
    // MARK: - Other -
    
    func deleteButtonClicked(_ sender: AnyObject) {
        guard let indexPath = self.indexPath else { return }
        delegate?.usageIssueTableViewCellDidClickDelete(indexPath)
    }
    
}
