/*
 
 AddNoteAlertView.swift
 
 Created by Sharkey, Justin (ELS-CON) on 4/10/16.
 Copyright © 2016 Elsevier, Inc. All rights reserved.
 
*/

import UIKit
import Cartography
import MessageUI

protocol NoteViewDelegate: class {
    func noteViewDidClickSaveText(_ dataSource: NoteViewDataSource)
    func noteViewDidClickUpdateNote(_ note: Note, userNote: String)
    func noteViewDidClickCancel(_ noteId: String)
    func noteViewDidClickDelete(_ note: Note)
    func noteViewDidSendMail()
}

struct NoteViewDataSource {
    
    var _note: Note?
    
    var article: Article?
    var highlightedText: String?
    
    var noteId: String?
    var savedOnDate: String?
    var selectionInnerHTMLString: String?
    var showUserNote: String?
    var playTitle: String?
    var playAuthorName: String?
    var playId: Int?
    var versionNumber: Int?
    var note: String?
    var isAlreadyNote: Bool = false
    
    @available(*, deprecated: 0.2) var filePath: String?

    init(article: Article, highlightedText: String) {
        self.article = article
        self.highlightedText = highlightedText
    }
    
    init(note: Note) {
        self._note = note
    }
    
}

class AddNoteView: JBSMViewController, UITextViewDelegate {
    
    weak var delegate: NoteViewDelegate?
    var dataSource: NoteViewDataSource
    
    let backgroundView   = UIView()
    let presentationView = UIView()
    let noteTextView     = UITextView()
    
    let saveLabel        = UIButton(type: .custom)
    let cancelLabel      = UIButton(type: .custom)
    let deleteButton     = UIButton(type: .custom)
    
    let mailButton       = UIButton(type: .custom)
    
    init(dataSource: NoteViewDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.clear
    }
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupBackgroundView()
        setupPresentationView()
        setupNoteTextView()
        setupSaveLabel()
        setupCancelLabel()
        setupDeleteButton()
        setupMailButton()
        
        if dataSource._note == .none {
            mailButton.isEnabled = false
            deleteButton.isHidden = true
        }
    }
    
    func setupSubviews() {
        view.addSubview(backgroundView)
        view.addSubview(presentationView)
        presentationView.addSubview(noteTextView)
        presentationView.addSubview(saveLabel)
        presentationView.addSubview(cancelLabel)
        presentationView.addSubview(deleteButton)
        presentationView.addSubview(mailButton)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            noteTextView,
            saveLabel,
            cancelLabel,
            presentationView,
            backgroundView,
            deleteButton,
            mailButton
        ]
            
        constrain(subviews) { (views) in
            
            let noteTV = views[0]
            let saveL = views[1]
            let cancelL = views[2]
            let presentationV = views[3]
            let backgroundV = views[4]
            let deleteB = views[5]
            let mailB = views[6]
            
            guard let superview = noteTV.superview else {
                return
            }
            
            noteTV.top            == superview.top + 8
            noteTV.right          == superview.right - 8
            noteTV.left           == superview.left + 8
            noteTV.bottom         == saveL.top - Config.Padding.Default
            
            saveL.top             == noteTV.bottom + 8
            saveL.right           == superview.right - 8
            saveL.bottom          == superview.bottom - 8
            saveL.width           == 60
            saveL.height          == 28
            
            cancelL.centerY       == saveL.centerY
            cancelL.right         == saveL.left - 8
            cancelL.height        == saveL.height
            cancelL.width         == 60
            
            deleteB.centerY       == saveL.centerY
            deleteB.right         == cancelL.left - Config.Padding.Default
            deleteB.height        == cancelL.height
            deleteB.width         == 60
            
            mailB.height          == 21
            mailB.width           == 31
            mailB.left            == presentationV.left + Config.Padding.Default
            mailB.centerY         == saveL.centerY
            
            presentationV.width   == 300
            presentationV.height  == 160
            presentationV.centerX == presentationV.superview!.centerX
            presentationV.top     == presentationV.superview!.top + 100
            
            backgroundV.top       == backgroundV.superview!.top
            backgroundV.right     == backgroundV.superview!.right
            backgroundV.bottom    == backgroundV.superview!.bottom
            backgroundV.left      == backgroundV.superview!.left
            
        }
    }
    
    func setupNoteTextView() {
        noteTextView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        noteTextView.becomeFirstResponder()
        noteTextView.delegate = self
        if let note = dataSource._note {
            noteTextView.text = note.noteText
        }
    }
    
    func setupSaveLabel() {
        var mode: String
        if dataSource._note == .none {
            saveLabel.setTitle("Save", for: UIControlState())
            mode = "Save"
        } else {
            saveLabel.setTitle("Update", for: UIControlState())
            mode = "Update"
        }
        saveLabel.setTitleColor(UIColor.white, for: UIControlState())
        saveLabel.backgroundColor = UIColor.colorWithHexString("323232")
        saveLabel.layer.cornerRadius = 4
        saveLabel.titleLabel?.font = UIFont.systemFontOfSize(14, weight: SystemFontWeight.Bold)
        saveLabel.addTarget(self, action: #selector(didClickSave(_:)), for: .touchUpInside)
        saveLabel.accessibilityLabel = "\(mode) Note"
        saveLabel.accessibilityHint = "Double Tap to \(mode) Note"
    }
    
    func setupCancelLabel() {
        cancelLabel.setTitle("Cancel", for: UIControlState())
        cancelLabel.setTitleColor(UIColor.white, for: UIControlState())
        cancelLabel.backgroundColor = UIColor.darkGray
        cancelLabel.layer.cornerRadius = 4
        cancelLabel.titleLabel?.font = UIFont.systemFontOfSize(14, weight: SystemFontWeight.Bold)
        cancelLabel.addTarget(self, action: #selector(didClickCancel(_:)), for: .touchUpInside)
        cancelLabel.accessibilityLabel = "Cancel"
        cancelLabel.accessibilityHint = "Double Tap to Cancel"
    }
    
    func setupDeleteButton() {
        deleteButton.setTitle("Delete", for: UIControlState())
        deleteButton.setTitleColor(UIColor.white, for: UIControlState())
        deleteButton.backgroundColor = UIColor.darkGray
        deleteButton.layer.cornerRadius = 4
        deleteButton.titleLabel?.font = UIFont.systemFontOfSize(14, weight: SystemFontWeight.Bold)
        deleteButton.addTarget(self, action: #selector(didClickDelete(_:)), for: .touchUpInside)
        deleteButton.accessibilityLabel = "Delete Note"
        deleteButton.accessibilityHint = "Double Tap to Delete Note"
    }
    
    func setupMailButton() {
        mailButton.setImage(UIImage(named: "MailIcon")!, for: UIControlState())
        mailButton.addTarget(self, action: #selector(emailNote), for: .touchUpInside)
        mailButton.accessibilityLabel = "Main Note"
        mailButton.accessibilityHint = "Double Tap to Mail Note"
    }
    
    func setupBackgroundView() {
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.1
    }
    
    func setupPresentationView() {
        presentationView.backgroundColor = UIColor.black
        presentationView.layer.cornerRadius = 8.0
        presentationView.layer.borderWidth = 1.0
        presentationView.layer.borderColor = UIColor.gray.cgColor
        presentationView.clipsToBounds = true
    }
    
    func didClickSave(_ sender: UIButton) {
        let text = noteTextView.text
        if text != "" {
            if let _note = dataSource._note {
                delegate?.noteViewDidClickUpdateNote(_note, userNote: text!)
                dismiss(animated: true, completion: nil)
            } else {
                dataSource.note = text
                dismiss(animated: true, completion: nil)
                delegate?.noteViewDidClickSaveText(dataSource)
            }
        } else {
            let alertVC = UIAlertController(title: nil, message: "Please enter any text.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            performOnMainThread({ 
                self.present(alertVC, animated: true, completion: nil)
            })
        }
    }
    
    func didClickCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        if dataSource._note == .none {
            if let noteId = dataSource.noteId {
                delegate?.noteViewDidClickCancel(noteId)
            }
        }
    }
    
    func didClickDelete(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        if let note = dataSource._note {
            delegate?.noteViewDidClickDelete(note)
        }
    }
    
    func emailNote() {
        var article: Article
        if let _article = dataSource.article {
            article = _article
        } else if let _note = dataSource._note {
            article = _note.article
        } else {
            return
        }
        
        var text = "Article Citation"
        text += "<br>"
        
        if article.cleanArticleTitle != "" {
            text += "<br>"
            text += "<b>" + "Article Title" + "</b>"
            text += "<br>"
            text += article.cleanArticleTitle
            text += "<br>"
        }
        
        if let _authors = article.author {
            if _authors != "" {
                text += "<br>"
                text += "<b>" + "Authors" + "</b>"
                text += "<br>"
                text += _authors
                text += "<br>"
            }
        }
        
        text += "<br>"
        text += "<b>" + "Source" + "</b>"
        text += "<br>"
        text += article.journal.journalTitle!
        let dateFormatter = DateFormatter(dateFormat: "MMM dd, YYYY")
        let date = dateFormatter.string(from: article.dateOfRelease!)
        text += " - " + "\(date)"
        text += "<br>"
        
        if let volume = article.issue?.volume {
            text += volume + " | "
        }
        
        if let issueNumber = article.issue?.issueNumber {
            text += "\(issueNumber)" + " | "
        }
        if let range = article.pageRange {
            text += "Pages " + range
        }
        
        text += "<br>"
        
        if let doi = article.doi {
            text += "DOI: " + doi
        }
        
        text += "<br>"
        
        if let highlightedText = dataSource.highlightedText {
            text += "<br>"
            text += "<b>Highlighted Text:</b> \(highlightedText)"
        } else if let note = dataSource._note {
            text += "<br>"
            text += "<b>Highlighted Text:</b> \(note.selectedText)"
        }
        
        text += "<br>"
        
        if let note = noteTextView.text {
            text += "<br>"
            text += "<b>Note:</b> \(note)"
            text += "<br>"
        }
        
        if let doiLink = article.doiLink {
            text += "<br>"
            text += "DOI: " + "<a href='\(doiLink)'>" + doiLink + "</a>"
        }
        
        if let copyright = article.copyright {
            text += "<p align = 'left'>" + copyright + "</p>"
        }
        
        guard MFMailComposeViewController.canSendMail() == true else {
            // TODO: Show Dialogue
            return
        }
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setBccRecipients(nil)
        mailVC.setBccRecipients(nil)
        mailVC.setSubject(article.cleanArticleTitle)
        mailVC.setMessageBody(text, isHTML: true)
        present(mailVC, animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            mailButton.isEnabled = false
        } else {
            mailButton.isEnabled = true
        }
    }
}
