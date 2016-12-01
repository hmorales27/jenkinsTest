//
//  UsageJournalTableViewCell.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/9/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

protocol UsageJournalTableViewCellDelegate: class {
    func usageJournalTableViewCellDidClickDelete(_ indexPath: IndexPath)
}

class UsageJournalTableViewCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let sizeLabel = UILabel()
    let deleteButton = UIButton(type: .custom)
    let continueLabel = UIImageView()
    
    var indexPath: IndexPath?
    weak var delegate: UsageJournalTableViewCellDelegate?
    
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
        setupContinueLabel()
    }
    
    fileprivate func setupSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(deleteButton)
        contentView.addSubview(continueLabel)
    }
    
    fileprivate func setupAutoLayout() {
        constrain(titleLabel, sizeLabel, deleteButton, continueLabel) { (titleLabel, sizeLabel, deleteButton, continueLabel) -> () in
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
            
            continueLabel.centerY == sizeLabel.centerY
            continueLabel.right == superview.right - Config.Padding.Default
            continueLabel.width == 18
            continueLabel.height == 18
        }
    }
    
    fileprivate func setupTitleLabel() {
        titleLabel.font = UIFont.systemFontOfSize(16, weight: SystemFontWeight.Bold)
        titleLabel.numberOfLines = 0
    }
    
    fileprivate func setupSizeLabel() {
        sizeLabel.textColor = UIColor.blue
        sizeLabel.textAlignment = .right
        sizeLabel.font = UIFont.systemFontOfSize(16, weight: SystemFontWeight.Light)
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
    
    func deleteButtonClicked(_ sender: UIButton) {
        delegate?.usageJournalTableViewCellDidClickDelete(indexPath!)
    }
    
    fileprivate func setupContinueLabel() {
        continueLabel.isHidden = true
        if let image = UIImage(named: "Continue") {
            continueLabel.image = image
            continueLabel.tintColor = UIColor.gray
        }
    }
    
    // MARK: - Update -
    
    func update(_ journal: Journal) {
        updateTitleLabel(journal)
        updateSizeLabel(journal)
    }
    
    fileprivate func updateTitleLabel(_ journal: Journal) {
        titleLabel.text = journal.journalTitle
    }
    
    fileprivate func updateSizeLabel(_ journal: Journal) {
        let articles = DatabaseManager.SharedInstance.getDownloadedArticlesForJournal(journal)
        if articles.count > 0 {
            var size: Int64 = 0
            for article in articles {
                size += article.downloadInfo.fullTextFileSize
                if article.downloadInfo.fullTextSupplDownloadStatus == .downloaded {
                    size += article.downloadInfo.fullTextSupplFileSize
                }
            }
            if size > 0 {
                deleteButton.isHidden = false
            }
            sizeLabel.text = Int(size).convertToFileSize()
        }
    }
    
    // MARK: - Reset -
    
    override func prepareForReuse() {
        reset()
    }
    
    fileprivate func reset() {
        titleLabel.text = nil
        sizeLabel.text = 0.convertToFileSize()
        continueLabel.isHidden = true
        deleteButton.isHidden = true
        indexPath = nil
    }
    
}
