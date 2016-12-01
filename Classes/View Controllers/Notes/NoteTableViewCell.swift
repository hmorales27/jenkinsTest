//
//  NoteTableViewCell.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 4/11/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class NotesTableViewCell: UITableViewCell {
    
    static let Identifier = "NotesTableViewCell"
    
    let issueTitleLabel = JournalTitleLabel()
    let articleTitleLabel = ArticleTitleLabel()
    let articleAuthorsLabel = JBSMLabel()
    let authorsPlusButton = UIButton.init(type: .custom)
    let highlightedLabel = JBSMLabel()
    let noteLabel = JBSMLabel()
    let savedDateLabel = AIPLabel()
    let openAccessLabel = OpenAccessLabel()
    let bottomSeparator = UIView()
    
    var indexPath: IndexPath?
    var notesVC: NotesViewController?
    
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
        setupAuthorsLabels()
        setupAuthorsPlusButton()
        setupAutoLayout()
        bottomSeparator.backgroundColor = Config.Colors.TableViewSeparatorColor
    }
    func setupAuthorsLabels(){
        articleAuthorsLabel.isUserInteractionEnabled = true
        articleAuthorsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userClickedPlusButton)))
    }
    
    func setupAuthorsPlusButton() {
        
        authorsPlusButton.setTitle("+", for: UIControlState())
        authorsPlusButton.backgroundColor = UIColor.veryLightGray()
        authorsPlusButton.layer.borderColor = UIColor.gray.cgColor
        authorsPlusButton.layer.borderWidth = 1
        authorsPlusButton.layer.cornerRadius = 4
        authorsPlusButton.setTitleColor(UIColor.gray, for: UIControlState())
        
        authorsPlusButton.isHidden = true
        authorsPlusButton.addTarget(self, action: #selector(userClickedPlusButton), for: .touchUpInside)
    }
    
    func setupSubviews() {
        contentView.addSubview(issueTitleLabel)
        contentView.addSubview(articleTitleLabel)
        contentView.addSubview(articleAuthorsLabel)
        contentView.addSubview(authorsPlusButton)
        contentView.addSubview(highlightedLabel)
        contentView.addSubview(noteLabel)
        contentView.addSubview(savedDateLabel)
        contentView.addSubview(openAccessLabel)
        contentView.addSubview(bottomSeparator)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            issueTitleLabel,
            articleTitleLabel,
            articleAuthorsLabel,
            highlightedLabel,
            noteLabel,
            savedDateLabel,
            openAccessLabel,
            bottomSeparator,
            authorsPlusButton
        ]
        
        constrain(subviews) { (views) in
            
            let issueTitleL = views[0]
            let articleTitleL = views[1]
            let articleAuthorL = views[2]
            let highlightedL = views[3]
            let noteL = views[4]
            let savedDateL = views[5]
            let openAccessL = views[6]
            let bottomS = views[7]
            let authorsPlusB = views[8]
            
            guard let superview = issueTitleL.superview else {
                return
            }
            
            issueTitleL.top == superview.top + Config.Padding.Default
            issueTitleL.right == superview.right - Config.Padding.Default
            issueTitleL.left == superview.left + Config.Padding.Default
            
            articleTitleL.top == issueTitleL.bottom + Config.Padding.Small
            articleTitleL.right == superview.right - Config.Padding.Default
            articleTitleL.left == superview.left + Config.Padding.Default
            
            articleAuthorL.top == articleTitleL.bottom + Config.Padding.Small
            articleAuthorL.right == authorsPlusB.left - Config.Padding.Default
            articleAuthorL.left == superview.left + Config.Padding.Default
            
            authorsPlusB.right == superview.right - Config.Padding.Default
            authorsPlusB.centerY == articleAuthorL.centerY
            authorsPlusB.width == 22
            authorsPlusB.height == 22
            
            highlightedL.top == articleAuthorL.bottom + Config.Padding.Small
            highlightedL.right == superview.right - Config.Padding.Default
            highlightedL.left == superview.left + Config.Padding.Default
            
            noteL.top == highlightedL.bottom + Config.Padding.Small
            noteL.right == superview.right - Config.Padding.Small
            noteL.left == superview.left + Config.Padding.Default
            
            savedDateL.top == noteL.bottom + Config.Padding.Small
            savedDateL.right == superview.right - Config.Padding.Default
            savedDateL.left == superview.left + Config.Padding.Default
            
            openAccessL.top == savedDateL.bottom + Config.Padding.Small
            openAccessL.right == superview.right - Config.Padding.Default
            openAccessL.bottom == superview.bottom - Config.Padding.Small
            openAccessL.left == superview.left + Config.Padding.Default
            
            bottomS.right == superview.right
            bottomS.bottom == superview.bottom
            bottomS.left == superview.left
            bottomS.height == 1
        }
    }
    
    // MARK: - Update -
    
    func update(note: Note) {
        let article = note.article
        
        if let issue = article?.issue {
            issueTitleLabel.text = issue.displayTitle
        }
        articleTitleLabel.text = article?.cleanArticleTitle
        if let authors = article?.author {
            articleAuthorsLabel.text = authors
        }
        
        let highlightedAttributedString = NSMutableAttributedString(string: "Highlighted Text: ", attributes: [NSFontAttributeName: AppConfiguration.DefaultBoldFont])
        highlightedAttributedString.append(NSAttributedString(string: note.selectedText))
        highlightedLabel.attributedText = highlightedAttributedString
        
        let noteAttributedString = NSMutableAttributedString(string: "Notes: ", attributes: [NSFontAttributeName: AppConfiguration.DefaultBoldFont])
        noteAttributedString.append(NSAttributedString(string: note.noteText))
        noteLabel.attributedText = noteAttributedString
        
        let dateFormatter = DateFormatter(dateFormat: "MMM dd, YYYY")
        let date = dateFormatter.string(from: note.savedDate)
        savedDateLabel.text = "Saved on " + date
        
        if (article?._isOpenAccess)! {
            openAccessLabel.text = "Open Access"
            openAccessLabel.isHidden = false
        }
        
        if let text = article?.author {
            let rect = text.boundingRect(with: CGSize(width: frame.width, height: 200), options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), context: nil).size
            if rect.height > 34 {
                authorsPlusButton.isHidden = false
            }
        }
    }
    
    func userClickedPlusButton(_ sender: UIButton) {
        if UIAccessibilityIsVoiceOverRunning() {
            notesVC?.tableView((notesVC?.tableView)!, didSelectRowAt: indexPath!)
        }
        if let _indexPath = self.indexPath {
            
            notesVC?.toggleAuthorList(_indexPath)
            //  notesVC.toggleAuthorsList(_indexPath)
        }
    }
    
    func reset() {
        issueTitleLabel.text = nil
        articleTitleLabel.text = nil
        articleAuthorsLabel.text = nil
        highlightedLabel.attributedText = nil
        noteLabel.attributedText = nil
        savedDateLabel.text = nil
        openAccessLabel.text = nil
        authorsPlusButton.isHidden = true
    }
}


