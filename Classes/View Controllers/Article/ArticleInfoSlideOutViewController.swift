//
//  ArticleInfoSlideOutViewController.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/22/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import UIKit
import Cartography
import MessageUI
import GoogleMobileAds
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol ArticleInfoSlideOutProtocol: class {
    func noteTabWasClicked()
    func outlineTabWasClicked()
    
    func openDrawer(_ open: Bool)
    
    func openNote(_ note: Note)
    func openReference(_ reference: Reference)
    func presentMailVC(_ mailVC: MFMailComposeViewController)
}

enum ArticleInfoType {
    case outline
    case notes
}

class ArticleInfoSlideOutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, MFMailComposeViewControllerDelegate {
    
    let outlineContainer = UIView()
    let outlineTabView = UIButton(type: .custom)
    let outlineSegmentControl = UISegmentedControl(items: ["Article Outline", "Citation"])
    let outlineTableView = UITableView()
    let outlineWebView = UIWebView()
    
    let notesContainer = UIView()
    let notesTabView = UIButton(type: .custom)
    let notesHeadlineView = UIView()
    let notesHeadlineLabel = UILabel()
    let notesMailButton = UIButton()
    let notesTableView = UITableView()
    
    let internet = Reachability(hostName: "www.google.com")
    
    var items: [String] = []
    
    weak var delegate: ArticleInfoSlideOutProtocol?
    
    weak var parentVC: ArticlePagerController?
    
    var type: ArticleInfoType?
    var open: Bool = false
    
    var article: Article?
    
    weak var issue: Issue?
    
    var notes: [Note] = []
    var references: [Reference] = []
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup -
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupNotesContainer()
        setupNotesHeadlineView()
        setupNotesHeadlineLabel()
        setupNotesMailButton()
        setupNotesTabView()
        setupOutlineTabView()
        setupOutlineContainer()
        setupOutlineTableView()
        setupOutlineWebView()
        setupOutlineSegmentControl()
        setupNotesTableView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFontSize), name: NSNotification.Name(rawValue: Notification.Font.DidChange), object: nil)
    }
    
    func setupSubviews() {
        view.addSubview(outlineContainer)
        view.addSubview(notesContainer)
        
        outlineContainer.addSubview(outlineSegmentControl)
        outlineContainer.addSubview(outlineTableView)
        outlineContainer.addSubview(outlineWebView)
        
        notesContainer.addSubview(notesHeadlineView)
        notesContainer.addSubview(notesHeadlineLabel)
        notesContainer.addSubview(notesMailButton)
        notesContainer.addSubview(notesTableView)
        
        view.addSubview(outlineTabView)
        view.addSubview(notesTabView)
        
        outlineTabView.accessibilityLabel = "Open Article Outline & Citation Menu"
        notesTabView.accessibilityLabel = "Open Article Notes Menu"
    }
    
    func setupAutoLayout() {
        
        let containerViews = [
            outlineContainer,
            notesContainer,
            outlineTabView,
            notesTabView,
            outlineSegmentControl,
            outlineTableView,
            outlineWebView,
            notesHeadlineView,
            notesHeadlineLabel,
            notesMailButton,
            notesTableView
        ]
        constrain(containerViews) { (views) in
            let outlineC    = views[0]
            let notesC      = views[1]
            let outlineTabV = views[2]
            let notesTabV   = views[3]
            let outlineSC   = views[4]
            let outlineTV   = views[5]
            let outlineWV   = views[6]
            let notesHV     = views[7]
            let notesHL     = views[8]
            let notesMB     = views[9]
            let notesTV     = views[10]

            guard let superview = outlineC.superview else {
                return
            }
            
            outlineTabV.right == superview.right
            outlineTabV.width == 33
            outlineTabV.height == 130
            outlineTabV.top == superview.top + Config.Padding.Double
            
            notesTabV.right == superview.right
            notesTabV.width == 33
            notesTabV.height == 130
            notesTabV.top == outlineTabV.bottom - Config.Padding.Double
            
            outlineC.top == superview.top
            outlineC.right == superview.right - 33
            outlineC.bottom == superview.bottom
            outlineC.left == superview.left
            
            outlineSC.top == outlineC.top + Config.Padding.Small
            outlineSC.right == outlineC.right - Config.Padding.Small
            outlineSC.left == outlineC.left + Config.Padding.Small
            
            outlineTV.top == outlineSC.bottom + Config.Padding.Default
            outlineTV.right == outlineC.right
            outlineTV.bottom == outlineC.bottom
            outlineTV.left == outlineC.left
            
            outlineWV.top == outlineSC.bottom + Config.Padding.Default
            outlineWV.right == outlineC.right
            outlineWV.bottom == outlineC.bottom
            outlineWV.left == outlineC.left
            
            notesC.top == superview.top
            notesC.right == superview.right - 33
            notesC.bottom == superview.bottom
            notesC.left == superview.left
            
            notesHV.top == notesC.top
            notesHV.right == notesC.right - Config.Padding.Small
            notesHV.left == notesC.left
            notesHV.height == 40

            notesHL.top == notesC.top + Config.Padding.Small
            notesHL.left == notesC.left + Config.Padding.Default + 2
            notesHL.width == 70
            notesHL.height == notesHV.height - Config.Padding.Small
            
            notesMB.top == notesC.top + Config.Padding.Small
            notesMB.right == notesHV.right - Config.Padding.Default
            notesMB.width == 40
            notesMB.height == notesHV.height - Config.Padding.Default
            
            notesTV.top == notesHV.bottom + Config.Padding.Default
            notesTV.right == notesC.right
            notesTV.bottom == notesC.bottom
            notesTV.left == notesC.left
        }
    }
    
    func setupNotesContainer() {
        notesContainer.backgroundColor = UIColor(red: (255/255), green: (230/255), blue: (185/255), alpha: 1)
        notesContainer.isHidden = true
    }
    
    func setupNotesTabView() {
        notesTabView.layer.zPosition = 10
        notesTabView.setImage(UIImage(named: "TabsNotes"), for: UIControlState())
        notesTabView.addTarget(self, action: #selector(noteTabWasClicked(_:)), for: .touchUpInside)
    }
    
    func setupOutlineContainer() {
        outlineContainer.isHidden = true
        outlineContainer.backgroundColor = AppConfiguration.BackgroundColor
    }
    
    func setupOutlineTabView() {
        outlineTabView.layer.zPosition = 20
        outlineTabView.setImage(UIImage(named: "TabsOutline"), for: UIControlState())
        outlineTabView.addTarget(self, action: #selector(outlineTabWasClicked(_:)), for: .touchUpInside)
    }
    
    func setupOutlineSegmentControl() {
        outlineSegmentControl.backgroundColor = UIColor.white
        outlineSegmentControl.layer.cornerRadius = 4
        outlineSegmentControl.addTarget(self, action: #selector(outlineSegmentControlValueDidChange(_:)), for: .valueChanged)
    }
    
    func setupOutlineTableView() {
        outlineTableView.backgroundColor = UIColor.clear
        outlineTableView.isHidden = true
        outlineTableView.delegate = self
        outlineTableView.dataSource = self
        outlineTableView.estimatedRowHeight = 66.0
        outlineTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setupOutlineWebView() {
        outlineWebView.isOpaque = false
        outlineWebView.backgroundColor = UIColor.clear
        outlineWebView.isHidden = true
        outlineWebView.backgroundColor = AppConfiguration.BackgroundColor
        outlineWebView.delegate = self
    }
    
    func setupNotesHeadlineView() {
        notesHeadlineView.backgroundColor = UIColor.init(red: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 0.3)
        notesHeadlineView.isHidden = false
    }
    
    func setupNotesHeadlineLabel() {
        
        notesHeadlineLabel.text = "Notes"
        notesHeadlineLabel.isHidden = false
        notesHeadlineLabel.backgroundColor = UIColor.clear
        notesHeadlineLabel.font = UIFont.systemFontOfSize(21.0, weight: SystemFontWeight.Semibold)
        notesHeadlineLabel.textColor = UIColor.init(red: 119.0/255.0, green: 107.0/255.0, blue: 82.0/255.0, alpha: 1)
    }
    
    func setupNotesMailButton() {
        
        let defaultImage = UIImage.init(named: "message_ipad_sel")
        notesMailButton.setImage(defaultImage, for: UIControlState())
        notesMailButton.contentMode = UIViewContentMode.scaleAspectFit
        notesMailButton.addTarget(self, action: #selector(mailButtonWasClicked(_:)), for: UIControlEvents.touchUpInside)
    }
    
    func setupNotesTableView() {
        notesTableView.backgroundColor = UIColor.clear
        notesTableView.isHidden = false
        notesTableView.delegate = self
        notesTableView.dataSource = self
        notesTableView.estimatedRowHeight = 66.0
        notesTableView.rowHeight = UITableViewAutomaticDimension
        notesTableView.register(ArticleInfoNotesTableViewCell.self, forCellReuseIdentifier: ArticleInfoNotesTableViewCell.Identifier)
        notesTableView.tableFooterView = UIView()
    }
    
    // MARK: - Update -
    
    func update(_ article: Article) {
        reset()
        
        var hasOutline = false
        var hasCitation = false
        var hasNotes = false
        
        var tableViewData: [Reference] = []
        if let references = article.references?.allObjects as? [Reference] {
            for reference in references {
                if reference.isThisSubSection == true {
                    tableViewData.append(reference)
                }
            }
            tableViewData = tableViewData.sorted(by: { (reference1: Reference, reference2: Reference) -> Bool in
                reference1.referenceId?.intValue < reference2.referenceId?.intValue
            })
        }
        references = tableViewData
        
        if references.count > 0 {
            hasOutline = true
        }
        
        if let citation = article.citationText {
            hasCitation = true
            let cssPath = article.journal.basePath + "css/style.css"
            outlineWebView.loadHTMLString(citation, baseURL: URL(string: cssPath)!)
        }
        
        
        
        notes = DatabaseManager.SharedInstance.getNotes(article)

        let dateDescriptor = NSSortDescriptor(key: "savedDate", ascending: false)
        let sortDescriptors = [dateDescriptor]
        let sortedArray = (notes as NSArray).sortedArray(using: sortDescriptors)

        guard let _sortedArray = sortedArray as? [Note] else { return }
        notes = _sortedArray

        if notes.count > 0 {
            hasNotes = true
        }
        
        notesTableView.reloadData()
        outlineTableView.reloadData()
        
        var _items: [String] = []
        
        switch article.fullTextDownloadStatus {
        case .downloaded:
            if hasCitation == true || hasOutline == true {
                outlineTabView.isHidden = false
                if hasOutline {
                    _items.append("Article Outline")
                }
                if hasCitation {
                    _items.append("Citation")
                }
            } else {
                outlineTabView.isHidden = true
            }
            notesTabView.isHidden = hasNotes ? false : true
        default:
            if hasCitation == true {
                _items.append("Citation")
                outlineTabView.isHidden = false
            } else {
                outlineTabView.isHidden = true
            }
            notesTabView.isHidden = true
        }

        self.items = _items
        
        outlineSegmentControl.removeAllSegments()
        
        var i = 0
        for _item in self.items {
            outlineSegmentControl.insertSegment(withTitle: _item, at: i, animated: false)
            i += 1
        }
        
        outlineSegmentControl.selectedSegmentIndex = 0
        updateOutline(0)
        
        self.article = article
    }
    
    // MARK: - Reset -
    
    func reset() {
        issue = nil
        article = nil
        notes = []
        references = []
    }
    
    // MARK: - Actions -
    
    func noteTabWasClicked(_ sender: UIButton) {
        
        if open == true {
            if type == .notes {
                delegate?.openDrawer(false)
                open = false
                return
            }
        } else {
            delegate?.openDrawer(true)
            open = true
        }
        
        notesTabView.layer.zPosition = 20
        outlineTabView.layer.zPosition = 10
        notesContainer.isHidden = false
        outlineContainer.isHidden = true
        
        parentVC?.analyticsTagSubScreen(Constants.ScreenType.Notes)
        
        type = .notes
    }
    
    func outlineTabWasClicked(_ sender: UIButton) {
        
        if open == true {
            if type == .outline {
                delegate?.openDrawer(false)
                open = false
                return
            }
        } else {
            delegate?.openDrawer(true)
            open = true
        }
        
        notesTabView.layer.zPosition = 10
        outlineTabView.layer.zPosition = 20
        notesContainer.isHidden = true
        outlineContainer.isHidden = false
        
        if let title = outlineSegmentControl.titleForSegment(at: 0) {
            if title == "Article Outline" {
                parentVC?.analyticsTagSubScreen(Constants.ScreenType.Outline)
            } else {
                parentVC?.analyticsTagSubScreen(Constants.ScreenType.Citation)
            }
        }
        
        type = .outline
    }
    
    func mailButtonWasClicked(_ sender: UIButton) {
        
        if (internet?.isReachable())! {
            performOnMainThread {
                guard MFMailComposeViewController.canSendMail() == true else {
                    
                    //  TODO: show alert as is done in prod
                    return;
                }
                let mailVC = MFMailComposeViewController()
                guard let mailDelegate = self.delegate as? MFMailComposeViewControllerDelegate else {
                    
                    return
                }
                mailVC.mailComposeDelegate = mailDelegate
                mailVC.setBccRecipients(nil)
                mailVC.setBccRecipients(nil)
                
                guard let article = self.article else {
                    
                    return
                }
                guard let articleTitle = article.articleTitle else {
                    
                    //  TODO: Figure out if this is the right behavior
                    return
                }
                //  Log articleTitle
                mailVC.setSubject("My notes from \(articleTitle)")
                mailVC.setMessageBody(article.emailBodyWithNotes(self.notes), isHTML: true)
                
                //  TODO: send delegate message to parentVC/delegate to present mailVC
                self.delegate?.presentMailVC(mailVC)
            }
        }
    }
    
    // MARK: - Table View -
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == outlineTableView {
            guard (indexPath as NSIndexPath).row < references.count else {
                return adCell()
            }
            let reference = references[(indexPath as NSIndexPath).row]
            let cell = UITableViewCell()
            cell.textLabel?.text = reference.sectionTitle
            cell.textLabel?.numberOfLines = 0
            cell.backgroundColor = UIColor.clear
            return cell

        }
        
        if tableView == notesTableView {
            guard (indexPath as NSIndexPath).row < notes.count else {
                return adCell()
            }
            let note = notes[(indexPath as NSIndexPath).row]
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleInfoNotesTableViewCell.Identifier) as! ArticleInfoNotesTableViewCell
            cell.update(note)
            cell.backgroundColor = UIColor.clear
            return cell
            
        }
        return UITableViewCell()
    }
    
    func adCell() -> UITableViewCell {
        
        guard let journal = article?.journal else { return UITableViewCell() }
        
        let cell = UITableViewCell()
        let adView = GADBannerView(adSize: GADAdSize(size: CGSize(width: 160, height: 600), flags: 0))
        cell.addSubview(adView)
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        adView.rootViewController = self
        adView.adUnitID = journal.adSkyscraperPortraitIPad
        let request = GADRequest()
        if Strings.IsTestAds { request.testDevices = [kGADSimulatorID] }
        adView.load(request)
        adView.accessibilityLabel = "Advertisement"
        
        constrain([cell, adView]) { (views) in
            
            let cell = views[0]
            let adView = views[1]
            
            adView.height  == 600
            adView.width   == 160
            adView.centerX == cell.centerX
            adView.top     == cell.top + Config.Padding.Default
            adView.bottom  == cell.bottom - Config.Padding.Default
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == outlineTableView {
            return references.count + 1
        } else if tableView == notesTableView {
            return notes.count + 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ((tableView == outlineTableView) && (indexPath.row <= (references.count - 1))){
            let reference = references[indexPath.row]
            delegate?.openReference(reference)
            delegate?.openDrawer(false)
            open = false
        } else if ((tableView == notesTableView) && (indexPath.row <= (notes.count - 1))){
            let note = notes[indexPath.row]
            delegate?.openNote(note)
            delegate?.openDrawer(false)
            open = false
        } else {
            tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        }
    }
    
    // MARK: - Segment -
    
    func outlineSegmentControlValueDidChange(_ sender: UISegmentedControl) {
        if sender.titleForSegment(at: sender.selectedSegmentIndex) == "Article Outline" {
            parentVC?.analyticsTagSubScreen(Constants.ScreenType.Outline)
        } else if sender.titleForSegment(at: sender.selectedSegmentIndex) == "Citation" {
            parentVC?.analyticsTagSubScreen(Constants.ScreenType.Citation)
        }
        updateOutline(sender.selectedSegmentIndex)
    }
    
    func updateOutline(_ index: Int) {
        if items[index] == "Article Outline" {
            showOutlineTableView()
        } else if items[index] == "Citation" {
            showOutlineCitation()
        }
    }
    
    func showOutlineCitation() {
        outlineWebView.isHidden = false
        outlineTableView.isHidden = true
    }
    
    func showOutlineTableView() {
        outlineWebView.isHidden = true
        outlineTableView.isHidden = false
    }
    
    // MARK: - Other -
    
    func hideSlideout(_ hide: Bool) {
        if hide == true {
            delegate?.openDrawer(false)
            open = false
        } else {
            delegate?.openDrawer(true)
            open = true
        }
    }
    
    func updateFontSize() {
        if let textSize = UserDefaults.standard.value(forKey: Strings.TextSize.UserDefaultsKey) as? Int {
            webViewShouldZoomToLevel(textSize)
        }
    }
    
    func webViewShouldZoomToLevel(_ level: Int) {
        performOnMainThread {
            
            let jsPath = Bundle.main.path(forResource: "stylescript", ofType: "js")!
            do {
                var jsString = try NSString(contentsOfFile: jsPath, encoding: String.Encoding.utf8.rawValue)
                jsString = jsString.appending("zoomIn(\(level))") as NSString
                self.outlineWebView.stringByEvaluatingJavaScript(from: jsString as String)
            } catch let error as NSError {
                log.error(error.localizedDescription)
            }
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        updateFontSize()
    }
}

class ArticleInfoNotesTableViewCell: UITableViewCell {
    
    static let Identifier = "ArticleInfoNotesTableViewCell"
    
    let noteLabel = UILabel()
    let savedDateLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        
        contentView.backgroundColor = UIColor.white
        
        noteLabel.font = UIFont.systemFontOfSize(16, weight: SystemFontWeight.Regular)
        noteLabel.numberOfLines = 0
        
        savedDateLabel.font = UIFont.systemFontOfSize(14, weight: SystemFontWeight.Regular)
    }
    
    func setupSubviews() {
        contentView.addSubview(noteLabel)
        contentView.addSubview(savedDateLabel)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            noteLabel,
            savedDateLabel
        ]
        
        constrain(subviews) { (views) in
            
            let noteL = views[0]
            let savedDateL = views[1]
            
            guard let superview = noteL.superview else {
                return
            }
            
            noteL.top == superview.top + Config.Padding.Default
            noteL.right == superview.right - Config.Padding.Default
            noteL.left == superview.left + Config.Padding.Double
            
            savedDateL.top == noteL.bottom + Config.Padding.Default
            savedDateL.right == superview.right - Config.Padding.Default
            savedDateL.bottom == superview.bottom - Config.Padding.Default
            savedDateL.left == superview.left + Config.Padding.Double
        }
    }
    
    func update(_ note: Note) {
        noteLabel.text = note.noteText
        let dateFormatter = DateFormatter(dateFormat: "dd MMM, YYYY")
        savedDateLabel.text = "Saved on \(dateFormatter.string(from: note.savedDate))"
    }
    
    override func prepareForReuse() {
        noteLabel.text = nil
        savedDateLabel.text = nil
    }
}
