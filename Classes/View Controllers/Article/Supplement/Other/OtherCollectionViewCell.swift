//
//  OtherCollectionViewCell.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 1/31/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography
import SafariServices
import QuickLook

class OtherCollectionViewCell: UICollectionViewCell {
    
    let fileTypeImageView = UIImageView()
    let fileName = UILabel()
    
    weak var viewController: OthersViewController!
    weak var media: Media!
    
    // MARK: Initializers
    
    init(audio: Media) {
        super.init(frame: CGRectZero)
        setup(audio: audio)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    func setup(audio audio: Media) {
        
        self.media = audio
        
        contentView.backgroundColor = UIColor.grayColor()
        contentView.layer.borderColor = UIColor.grayColor().CGColor
        contentView.layer.borderWidth = 1.0
        
        setupFileTypeImageView()
        setupFileName()

        setupAutoLayout()
    }
    
    func setupFileTypeImageView() {
        contentView.addSubview(fileTypeImageView)
        
        fileTypeImageView.contentMode = UIViewContentMode.Center
        fileTypeImageView.backgroundColor = UIColor.whiteColor()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openMedia(_:)))
        self.contentView.addGestureRecognizer(tapGestureRecognizer)
        
        let path = CachesDirectoryPath + "appimages/"
        
        var image: UIImage!
        if media.type == "document" {
            image = UIImage(contentsOfFile: path + "ic_word.png")!
        } else if media.type == "PDF" {
            image = UIImage(contentsOfFile: path + "ic_pdf.png")!
        } else if media.type == "Presentation" {
            image = UIImage(contentsOfFile: path + "ic_ppt.png")!
        } else if media.type == "Spreadsheet" {
            image = UIImage(contentsOfFile: path + "ic_excel.png")!
        } else if media.type == "Other" {
            image = UIImage(contentsOfFile: path + "ic_other.png")!
        }
        
        fileTypeImageView.image = image
    }
    
    func setupFileName() {
        contentView.addSubview(fileName)
        fileName.textColor = UIColor.whiteColor()
        fileName.text = media.fileName
    }
    
    func setupAutoLayout() {
        constrain(fileTypeImageView, fileName) { (fileTypeImageView, fileName) -> () in
            guard let superview = fileTypeImageView.superview else {
                return
            }
            
            fileTypeImageView.left == superview.left
            fileTypeImageView.top == superview.top
            fileTypeImageView.right == superview.right
            fileTypeImageView.height == (fileTypeImageView.width * (2/3))
            
            fileName.left == superview.left + 8
            fileName.top == fileTypeImageView.bottom
            fileName.right == superview.right - 8
            fileName.bottom == superview.bottom
            fileName.height == 30
        }
    }
    
    // MARK: Reset
    
    override func prepareForReuse() {
        reset()
    }
    
    private func reset() {
        
    }
    
    func openMedia(sender: AnyObject) {
        switch media.article.downloadInfo.fullTextDownloadStatus {
        case .Downloaded:
            playButtonWasClicked()
        default:
            switch media.downloadStatus {
            case .Downloaded:
                playButtonWasClicked()
            default:
                downloadButtonClicked()
            }
        }
    }
    
    func playButtonWasClicked() {
        if media.downloadStatus != .Downloaded {
            downloadButtonClicked()
        } else {
            let ql = QLPreviewController()
            ql.dataSource = viewController
            ql.dataSource = viewController
            viewController.navigationController?.pushViewController(ql, animated: true)
        }
    }
    
    func downloadButtonClicked() {
        let alert = UIAlertController(title: "Download", message: "*Video, Audio and Other Files for this Article", preferredStyle: UIAlertControllerStyle.Alert)
        let fullSize = media.article.downloadInfo.fullTextSupplFileSize
        alert.addAction(UIAlertAction(title: "All Multimedia* - \(Int(fullSize).convertToFileSize())", style: .Default, handler: { (alert) -> Void in
            DMManager.sharedInstance.downloadFullTextSupplement(article: self.media.article)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
}
