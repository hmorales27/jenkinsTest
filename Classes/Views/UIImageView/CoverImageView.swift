//
//  CoverImageView.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/14/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class CoverImageView: UIImageView {
    
    var screenType: ScreenType?
    
    let constraint = JBSMLayoutConstraints()
    
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    var topConstraint: NSLayoutConstraint?
    var rightConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?
    var leftConstraint: NSLayoutConstraint?
    
    weak var issue: Issue?
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    init(screenType: ScreenType) {
        super.init(frame: CGRect.zero)
        self.screenType = screenType
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1.0
        
        constrain(self) { (view) in
            if screenType == .mobile {
                heightConstraint = (view.height == 150)
                widthConstraint  = (view.width == 113)
            } else {
                heightConstraint = (view.height == 200)
                widthConstraint  = (view.width == 150)
            }
        }
    }
    
    func setScreenType(_ screenType: ScreenType) {
        if screenType == .mobile {
            heightConstraint?.constant = 150
            widthConstraint?.constant  = 113
        } else {
            heightConstraint?.constant = 200
            widthConstraint?.constant  = 150
        }
    }
    
    func update(_ issue: Issue) {
        self.issue = issue
        guard let imagePath = issue.coverImagePath else {
            setPlaceholderImage()
            return
        }
        switch issue.coverImageDownloadStatus {
        case .downloaded:
            setCoverImage(imagePath)
        case .notAvailable:
            setPlaceholderImage()
        default:
            self.setPlaceholderImage()
            guard NETWORKING_ENABLED else { return }
            APIManager.sharedInstance.coverImage(issue: issue, success: { (success) -> Void in
                guard issue == self.issue else { return }
                guard success else { return }
                self.setCoverImage(imagePath)
            })
            
        }
    }
    
    fileprivate func widthForImage(_ image: UIImage) -> CGFloat {
       return self.frame.size.height / (image.size.height / image.size.width)
    }
    
    fileprivate func setCoverImage(_ path: String) {
        if let image = UIImage(contentsOfFile: path) {
            updateImage(image)
        } else {
            setPlaceholderImage()
        }
        leftConstraint?.constant = Config.Padding.Default
    }
    
    fileprivate func setPlaceholderImage() {
        if let image = UIImage(named: "DefaultcoverImage-iPhone") {
            updateImage(image)
        } else {
            log.error("Unable to set Placeholder Image")
        }
        leftConstraint?.constant = Config.Padding.Default
    }
    
    fileprivate func updateImage(_ image: UIImage) {
        DispatchQueue.main.async { () -> Void in
            self.image = image
            //self.widthConstraint?.constant = self.widthForImage(image)
            //self.leftConstraint?.constant = 8
        }
    }
    
    func hide() {
        //widthConstraint?.constant = 0
    }
}
