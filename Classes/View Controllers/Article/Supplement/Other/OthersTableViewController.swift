//
//  OthersTableViewController.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/16/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography
import QuickLook
import CoreData


class OthersTableViewController: JBSMViewController, UITableViewDelegate, UITableViewDataSource, QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    
    let tableView = UITableView()
    
    var medias: [Media]
    
    weak var selectedMedia: Media?
    
    init(medias: [Media]) {
        self.medias = medias.sorted(by: {
            $0.sequence.int32Value < $1.sequence.int32Value
        })
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setup() {
        setupView()
        setupSubviews()
        setupAutoLayout()
        setupTableView()
    }
    
    func setupView() {
        view.backgroundColor = UIColor.white
    }
    
    func setupSubviews() {
        view.addSubview(tableView)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            tableView
        ]
        
        constrain(subviews) { (views) in
            
            let tableV = views[0]
            
            guard let superview = tableV.superview else {
                return
            }
            
            tableV.top    == superview.top
            tableV.right  == superview.right
            tableV.bottom == superview.bottom
            tableV.left   == superview.left
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
        tableView.estimatedRowHeight = 66.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor.clear
        tableView.register(OtherTableViewCell.self, forCellReuseIdentifier: OtherTableViewCell.Identifier)
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        navigationItem.leftBarButtonItem = closeBarButtonItem
        title = "Other Files"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medias.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OtherTableViewCell.Identifier) as! OtherTableViewCell
        let media = medias[(indexPath as NSIndexPath).row]
        cell.tableViewController = self
        cell.indexPath = indexPath
        
        if media.expandAuthorList == true {
            cell.authorsLabel.numberOfLines = 0
            cell.authorsPlusButton.setTitle("-", for: UIControlState())
        }else {
            cell.authorsLabel.numberOfLines = 2
            cell.authorsPlusButton.setTitle("+", for: UIControlState())
        }
        cell.update(media: media, width: self.view.frame.width)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedMedia = medias[(indexPath as NSIndexPath).row]
        
        let previewer = OtherFilePreviewControl(media: medias[(indexPath as NSIndexPath).row])
        previewer.navigationItem.rightBarButtonItem = nil
        
        previewer.dataSource = self
        previewer.currentPreviewItemIndex = 0
        previewer.navigationItem.setRightBarButtonItems(nil, animated: true)
        navigationController?.pushViewController(previewer, animated: true)
        previewer.navigationController?.navigationItem.rightBarButtonItem = nil
    }
    
    func toggleAuthorList(indexPath: IndexPath) {

        let media = medias[(indexPath as NSIndexPath).row]
        if media.expandAuthorList == true {
            media.expandAuthorList = false
        } else {
            media.expandAuthorList = true
        }
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.endUpdates()
    }
    
    // MARK: QL Preview
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return selectedMedia!.pathURL as QLPreviewItem
    }
    
    override func updateViewsForScreenChange(_ type: ScreenType) {
        performOnMainThread { 
            self.tableView.reloadData()
        }
    }
}

class OtherTableViewCell: UITableViewCell {
    
    static let Identifier = "OtherTableViewCell"
    
    weak var tableViewController: OthersTableViewController?
    
    let fileTypeImageView      : UIImageView = UIImageView()
    let mediaInfoContainerView : UIView      = UIView()
    let fileNameLabel          : UILabel     = UILabel()
    let authorsLabel           : UILabel     = UILabel()
    let authorsPlusButton      : UIButton =  UIButton(type: .custom)

    let infoLabel              : UILabel     = UILabel()
    let separatorView          : UIView      = UIView()
    
    var indexPath: IndexPath?
    
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
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        
        separatorView.backgroundColor = Config.Colors.TableViewSeparatorColor
        
        fileNameLabel.numberOfLines = 0
        authorsLabel.numberOfLines = 0
        infoLabel.numberOfLines = 0
        
        authorsPlusButton.setTitle("+", for: UIControlState())
        authorsPlusButton.backgroundColor = UIColor.veryLightGray()
        authorsPlusButton.layer.borderColor = UIColor.gray.cgColor
        authorsPlusButton.layer.borderWidth = 1
        authorsPlusButton.layer.cornerRadius = 4
        authorsPlusButton.setTitleColor(UIColor.gray, for: UIControlState())
        
        authorsPlusButton.isHidden = false
        authorsPlusButton.addTarget(self, action: #selector(userClickedPlusButton), for: .touchUpInside)
        
        fileNameLabel.font = UIFont.systemFontOfSize(14, weight: SystemFontWeight.Bold)
        authorsLabel.font = UIFont.systemFontOfSize(14, weight: SystemFontWeight.Regular)
        infoLabel.font = UIFont.systemFontOfSize(14, weight: SystemFontWeight.Regular)
    }
    
    func setupSubviews() {
        contentView.addSubview(fileTypeImageView)
        contentView.addSubview(mediaInfoContainerView)
        mediaInfoContainerView.addSubview(fileNameLabel)
        mediaInfoContainerView.addSubview(authorsLabel)
        mediaInfoContainerView.addSubview(authorsPlusButton)
        mediaInfoContainerView.addSubview(infoLabel)
        addSubview(separatorView)
    }
    
    func setupAutoLayout() {
        let subviews = [
            fileTypeImageView,
            fileNameLabel,
            authorsLabel,
            mediaInfoContainerView,
            separatorView,
            infoLabel,
            authorsPlusButton
        ]
        
        constrain(subviews) { (views) in
            let fileTypeIV  = views[0]
            let fileNameL   = views[1]
            let authorsL    = views[2]
            let mediaInfoCV = views[3]
            let separatorV  = views[4]
            let infoL       = views[5]
            let authorsPB   = views[6]
            
            guard let superview = fileTypeIV.superview else {
                return
            }
            
            superview.height    >= fileTypeIV.height  + (Config.Padding.Default * 2)
            superview.height    >= mediaInfoCV.height + (Config.Padding.Default * 2)
            
            fileTypeIV.left     == superview.left     + Config.Padding.Double
            fileTypeIV.height   == 66
            fileTypeIV.width    == 58
            fileTypeIV.centerY  == superview.centerY
            
            mediaInfoCV.right   == superview.right
            mediaInfoCV.left    == fileTypeIV.right   + Config.Padding.Double
            mediaInfoCV.centerY == superview.centerY
            mediaInfoCV.width   <= superview.superview!.width - 90
            
            fileNameL.top       == mediaInfoCV.top
            fileNameL.right     == mediaInfoCV.right ~ 750
            fileNameL.left      == mediaInfoCV.left
            
            authorsL.top        == fileNameL.bottom + Config.Padding.Default
            authorsL.right      == mediaInfoCV.right ~ 750
            authorsL.right      == authorsPB.left - Config.Padding.Default
            authorsL.left       == mediaInfoCV.left
            
            authorsPB.right     == superview.right - Config.Padding.Default
            authorsPB.centerY   == authorsL.centerY
            authorsPB.width     == 22
            authorsPB.height    == 22
            
            infoL.top           == authorsL.bottom + Config.Padding.Default
            infoL.right         == mediaInfoCV.right
            infoL.bottom        == mediaInfoCV.bottom
            infoL.left          == mediaInfoCV.left
            
            separatorV.right    == superview.right + 1000
            separatorV.bottom   == superview.bottom
            separatorV.left     == superview.left
            separatorV.height   == 1
        }
    }
    
    func update(media: Media) {
        updateFileTypeImageView(media: media)
        updateFileNameLabel(media: media)
        updateAuthorsLabel(media: media)
        updateAuthorsPlusButton(media: media)
        updateInfoLabel(media: media)
    }
    
    func update(media: Media, width: CGFloat) {
        updateFileTypeImageView(media: media)
        updateFileNameLabel(media: media)
        updateAuthorsLabel(media: media)
        updateAuthorsPlusButton(media: media, width: width)
        updateInfoLabel(media: media)
    }
    
    func updateFileTypeImageView(media: Media) {
        let path = CachesDirectoryPath + "appimages/"
        var image: UIImage!
        if media.type == MediaFileType.Document.rawValue {
            image = UIImage(contentsOfFile: path + "ic_word.png")!
        } else if media.type == MediaFileType.PDF.rawValue {
            image = UIImage(contentsOfFile: path + "ic_pdf.png")!
        } else if media.type == MediaFileType.Presentation.rawValue {
            image = UIImage(contentsOfFile: path + "ic_ppt.png")!
        } else if media.type == MediaFileType.Spreadsheet.rawValue {
            image = UIImage(contentsOfFile: path + "ic_excel.png")!
        } else {
            image = UIImage(contentsOfFile: path + "ic_other.png")!
        }
        fileTypeImageView.image = image
    }
    
    func updateFileNameLabel(media: Media) {
        fileNameLabel.text = media.fileName
    }
    
    func updateAuthorsLabel(media: Media) {
        authorsLabel.text = media.article.author
    }
    
    func updateAuthorsPlusButton(media: Media) {
        let font = authorsLabel.font
        let size = CGSize(width: mediaInfoContainerView.frame.width, height: 200)
        let attributes = [NSFontAttributeName: font]
        if let text = media.article.author {
            let rect = text.boundingRect(with: size, options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), context: nil).size
            if rect.height > 15 {
                authorsPlusButton.isHidden = false
            }
        }
    }
    
    func updateAuthorsPlusButton(media: Media, width: CGFloat) {
        
        let _width = width - (Config.Padding.Default * 4) - 58 - 22
        
        let font = authorsLabel.font
        let size = CGSize(width: _width, height: 200)
        let attributes = [NSFontAttributeName: font]
        if let text = media.article.author {
            let rect = text.boundingRect(with: size, options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), context: nil).size
            if rect.height > 34 {
                authorsPlusButton.isHidden = false
                authorsLabel.isUserInteractionEnabled = true
                authorsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userClickedPlusButton)))
            } else {
                authorsPlusButton.isHidden = true
            }
        }
    }
    
    func updateInfoLabel(media: Media) {
        infoLabel.text = media.article.cleanArticleTitle
    }
    
    
    func userClickedPlusButton() {
        if UIAccessibilityIsVoiceOverRunning() {
            tableViewController?.tableView((tableViewController?.tableView)!, didSelectRowAt: indexPath!)
        }
        if let indexPath = self.indexPath {
            tableViewController?.toggleAuthorList(indexPath: indexPath)
        }
    }
    
    override func prepareForReuse() {
        fileTypeImageView.image = nil
        fileNameLabel.text = nil
        authorsLabel.text = nil
        authorsPlusButton.isHidden = true
    }
}


