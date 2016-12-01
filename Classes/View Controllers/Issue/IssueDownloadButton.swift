//
//  IssueDeleteButton.swift
//  Lancet
//
//  Created by Sharkey, Justin (ELS-CON) on 6/3/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import Cartography

protocol IssueDownloadButtonDelegate: class {
    func issueDownloadButtonClicked(_ button: UIButton)
    func issueDeletebuttonClicked(_ button: UIButton)
}

class IssueDownloadButton: UIButton {
    
    weak var heightConstraint: NSLayoutConstraint?
    
    var delegate: IssueDownloadButtonDelegate?
    
    var download: Bool?
    
    init() {
        super.init(frame: CGRect.zero)
        
        let backgroundView = UIImage(named: "Navigation Bar")
        setBackgroundImage(backgroundView, for: UIControlState())
        
        clipsToBounds = true
        
        titleLabel?.font = UIFont.systemFontOfSize(14, weight: SystemFontWeight.Bold)
        
        accessibilityLabel = "Download this Issue"
        isAccessibilityElement = true
        
        addTarget(self, action: #selector(buttonWasClicked), for: .touchUpInside)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        layer.cornerRadius = 4.0
        setTitleColor(UIColor.white, for: UIControlState())
        updateForDownload()
    }
    
    func updateForDownload() {
        isHidden = false
        download = true
        setTitle("Download this Issue", for: UIControlState())
        backgroundColor = UIColor.black
    }
    
    func updateForDelete() {
        isHidden = false
        download = false
        setTitle("Delete This Issue", for: UIControlState())
        backgroundColor = UIColor.colorWithHexString("7F0000")
    }
    
    func downloadButtonWasClicked() {
        if let _download = download {
            if _download == true {
                delegate?.issueDownloadButtonClicked(self)
            } else {
                delegate?.issueDeletebuttonClicked(self)
            }
        }
    }
    
    func buttonWasClicked() {
        if let _downloaded = download {
            if _downloaded == true {
                delegate?.issueDownloadButtonClicked(self)
            } else {
                delegate?.issueDeletebuttonClicked(self)
            }
        }
    }
    
}
