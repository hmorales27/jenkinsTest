//
//  ArticleInfoViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/1/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography
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


private let ArticleOutline = "Article Outline"
private let Citation = "Citation"
private let Notes = "Notes"

class ArticleInfoViewController: JBSMViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, UIPopoverPresentationControllerDelegate {
    
    let segmentControl: UISegmentedControl
    
    let tableView = UITableView()
    let webView = UIWebView()
    
    let notesTableView = UITableView()
    
    let article: Article
    let articleVC: ArticleViewController
    
    weak var parentVC: ArticlePagerController?
    
    var items: [String]

    var tableViewData: [Reference] = []
    var notes: [Note] = []
    
    init(article: Article, webView: ArticleViewController) {
        self.article = article
        self.articleVC = webView
        
        items = []
        if article.downloadInfo.fullTextDownloadStatus == .downloaded {
            items.append(ArticleOutline)
            parentVC?.analyticsTagSubScreen(Constants.ScreenType.Outline)
        } else {
            parentVC?.analyticsTagSubScreen(Constants.ScreenType.Citation)
        }
        items.append(Citation)
        if article.allNotes.count > 0 {
            notes = article.allNotes
            
            let dateDescriptor = NSSortDescriptor(key: "savedDate", ascending: false)
            let sortDescriptors = [dateDescriptor]
            let sortedArray = (notes as NSArray).sortedArray(using: sortDescriptors)
            
            if let _sortedArray = sortedArray as? [Note] {
                notes = _sortedArray
            }
            
            items.append(Notes)
        }
        
        segmentControl = UISegmentedControl(items: items)
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let citation = article.citationText {
            let cssPath = article.journal.basePath + "css/style.css"
            webView.loadHTMLString(citation, baseURL: URL(string: cssPath))
        }
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
        self.view.backgroundColor = AppConfiguration.BackgroundColor
        NotificationCenter.default.addObserver(self, selector: #selector(updateFontSize), name: NSNotification.Name(rawValue: Notification.Font.DidChange), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segmentControlValueDidChange(segmentControl)
    }
    
    func setup() {
        setupSegmentControl()
        setupTableView()
        setupWebView()
        setupNavigationBar()
        setupNotesTableView()
        setupAutoLayout()
    }
    
    func setupSegmentControl() {
        view.addSubview(segmentControl)
        segmentControl.backgroundColor = UIColor.white
        segmentControl.layer.cornerRadius = 4
        segmentControl.selectedSegmentIndex = 0
        segmentControl.clipsToBounds = true
        segmentControl.addTarget(self, action: #selector(segmentControlValueDidChange(_:)), for: UIControlEvents.valueChanged)
        segmentControl.tintColor = AppConfiguration.NavigationBarColor
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.layer.cornerRadius = 4
        tableView.clipsToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 66.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setupWebView() {
        view.addSubview(webView)
        webView.layer.cornerRadius = 4
        webView.clipsToBounds = true
        webView.backgroundColor = UIColor.white
        webView.delegate = self
    }
    
    func setupNotesTableView() {
        view.addSubview(notesTableView)
        notesTableView.layer.cornerRadius = 4
        notesTableView.clipsToBounds = true
        notesTableView.delegate = self
        notesTableView.dataSource = self
        notesTableView.estimatedRowHeight = 66.0
        notesTableView.rowHeight = UITableViewAutomaticDimension
        notesTableView.register(ArticleInfoMobileNotesTableViewCell.self, forCellReuseIdentifier: ArticleInfoMobileNotesTableViewCell.Identifier)
        notesTableView.separatorColor = UIColor.clear
    }
    
    func setupAutoLayout() {
        constrain(segmentControl, tableView, webView, notesTableView) { (segmentControl, tableView, webView, notesTV) -> () in
            guard let superview = segmentControl.superview else {
                return
            }
            segmentControl.left == superview.left + 8
            segmentControl.top == superview.top + 8
            segmentControl.right == superview.right - 8
            
            webView.top == segmentControl.bottom + 8
            webView.right == superview.right - 8
            webView.bottom == superview.bottom - 8
            webView.left == superview.left + 8
            
            tableView.top == segmentControl.bottom + 8
            tableView.right == superview.right - 8
            tableView.bottom == superview.bottom - 8
            tableView.left == superview.left + 8
            
            notesTV.top == segmentControl.bottom + 8
            notesTV.right == superview.right - 8
            notesTV.bottom == superview.bottom - 8
            notesTV.left == superview.left + 8
        }
    }
    
    override func setupNavigationBar() {
        let closeBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .plain, target: self, action: #selector(closeBarButtonItemClicked(_:)))
        navigationItem.leftBarButtonItem = closeBarButtonItem
        
        let fontBarButtonItem = UIBarButtonItem(image: UIImage(named: "Change Text"), style: .plain, target: self, action: #selector(userDidClickFontBarButtonItem(_:)))
        fontBarButtonItem.accessibilityLabel = "Change font size"
        navigationItem.rightBarButtonItem = fontBarButtonItem
    }
    
    func userDidClickFontBarButtonItem(_ sender: UIBarButtonItem) {
        let textSizeVC = TextSizeViewController()
        textSizeVC.delegate = articleVC
        let navigationVC = UINavigationController(rootViewController: textSizeVC)
        navigationVC.modalPresentationStyle = UIModalPresentationStyle.popover
        navigationVC.popoverPresentationController?.barButtonItem = sender
        navigationVC.popoverPresentationController?.backgroundColor = AppConfiguration.NavigationBarColor
        navigationVC.popoverPresentationController?.delegate = self
        navigationVC.preferredContentSize = CGSize(width: 200, height: 40)
        present(navigationVC, animated: true, completion: nil)
    }
    
    func closeBarButtonItemClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func segmentControlValueDidChange(_ sender: UISegmentedControl) {
        var index = 0
        if sender.selectedSegmentIndex >= 0 {
            index = sender.selectedSegmentIndex
        }
        let item = items[index]
        
        if item == ArticleOutline {
            title = ArticleOutline
            webView.isHidden = true
            tableView.isHidden = false
            notesTableView.isHidden = true
            parentVC?.analyticsTagSubScreen(Constants.ScreenType.Outline)
        } else if item == Citation {
            title = Citation
            webView.isHidden = false
            tableView.isHidden = true
            notesTableView.isHidden = true
            parentVC?.analyticsTagSubScreen(Constants.ScreenType.Citation)
        } else if item == Notes {
            title = Notes
            webView.isHidden = true
            tableView.isHidden = true
            notesTableView.isHidden = false
            parentVC?.analyticsTagSubScreen(Constants.ScreenType.Notes)
        }
    }
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell = UITableViewCell()
            let reference = tableViewData[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = reference.sectionTitle
            cell.textLabel?.numberOfLines = 0
            return cell
        } else if tableView == self.notesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleInfoMobileNotesTableViewCell.Identifier) as! ArticleInfoMobileNotesTableViewCell
            let note = notes[(indexPath as NSIndexPath).row]
            cell.update(note)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return tableViewData.count
        } else if tableView == self.notesTableView {
            return notes.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == self.tableView {
            let reference = tableViewData[(indexPath as NSIndexPath).row]
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                self.articleVC.webView.stringByEvaluatingJavaScript(from: "window.location.hash = ''")
                self.articleVC.webView.stringByEvaluatingJavaScript(from: "window.location.hash = '\(reference.sectionId!)';")
            }
        } else if tableView == self.notesTableView {
            let note = notes[(indexPath as NSIndexPath).row]
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                self.articleVC.webView.stringByEvaluatingJavaScript(from: "window.location.hash = ''")
                self.articleVC.webView.stringByEvaluatingJavaScript(from: "window.location.hash = '\(note.highlightId)';")
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Web View -
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let jsPath = Bundle.main.path(forResource: "stylescript", ofType: "js")!
        do {
            let jsString = try NSString(contentsOfFile: jsPath, encoding: String.Encoding.utf8.rawValue)
            webView.stringByEvaluatingJavaScript(from: jsString as String)
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        
        updateFontSize()
    }
    
    func updateFontSize() {
        if let textSize = UserDefaults.standard.value(forKey: Strings.TextSize.UserDefaultsKey) as? Int {
            webViewShouldZoomToLevel(textSize)
        }
    }
    
    func webViewShouldZoomToLevel(_ level: Int) {
        performOnMainThread {
            self.webView.stringByEvaluatingJavaScript(from: "zoomIn(\(level))")
        }
    }
    
    func adaptivePresentationStyle (for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

class ArticleInfoMobileNotesTableViewCell: UITableViewCell {
    
    static let Identifier = "ArticleInfoMobileNotesTableViewCell"
    
    let noteLabel = UILabel()
    let savedDateLabel = UILabel()
    let highlightTextLabel = UILabel()
    
    let bottomSeparator = UIView()
    
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
        
        bottomSeparator.backgroundColor = Config.Colors.TableViewSeparatorColor
    }
    
    func setupSubviews() {
        contentView.addSubview(noteLabel)
        contentView.addSubview(savedDateLabel)
        contentView.addSubview(highlightTextLabel)
        contentView.addSubview(bottomSeparator)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            noteLabel,
            savedDateLabel,
            highlightTextLabel,
            bottomSeparator
        ]
        
        constrain(subviews) { (views) in
            
            let noteL = views[0]
            let savedDateL = views[1]
            let highlightTextL = views[2]
            let bottomS = views[3]
            
            guard let superview = noteL.superview else {
                return
            }
            
            noteL.top == superview.top + Config.Padding.Default
            noteL.right == superview.right - Config.Padding.Default
            noteL.left == superview.left + Config.Padding.Default
            
            highlightTextL.top == noteL.bottom + Config.Padding.Default
            highlightTextL.right == superview.right - Config.Padding.Default
            highlightTextL.left == superview.left + Config.Padding.Default
            
            savedDateL.top == highlightTextL.bottom + Config.Padding.Default
            savedDateL.right == superview.right - Config.Padding.Default
            savedDateL.bottom == superview.bottom - Config.Padding.Default
            savedDateL.left == superview.left + Config.Padding.Default
            
            bottomS.right == superview.right
            bottomS.bottom == superview.bottom
            bottomS.left == superview.left
            bottomS.height == 1
        }
    }
    
    func update(_ note: Note) {
        noteLabel.text = "Notes: \(note.noteText)"
        
        highlightTextLabel.text = "Highlighted Text: \(note.selectedText)"
        
        let dateFormatter = DateFormatter(dateFormat: "dd MMM, YYYY")
        savedDateLabel.text = "Saved on \(dateFormatter.string(from: note.savedDate))"
    }
    
    override func prepareForReuse() {
        noteLabel.text = nil
        savedDateLabel.text = nil
    }
    

    
}
