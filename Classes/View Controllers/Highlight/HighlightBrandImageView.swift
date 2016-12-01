//
//  HighlightBrandImageView.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 4/2/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class JournalBrandImageView: UIImageView {
    
    // MARK: - Properties -
    
    var heightConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?
    
    fileprivate var isPortrait: Bool {
        switch UIApplication.shared.statusBarOrientation {
        case .portrait, .portraitUpsideDown:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Initializers -
    
    init() {
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        setup()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup -
    
    func setup() {
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0
        setupAutoLayout()
    }
    
    fileprivate func setupAutoLayout() {
        constrain(self) { (view) in
            heightConstraint = (view.height == 0)
            widthConstraint = (view.width == 0)
        }
    }
    
    // MARK: - Update -
    
    func update(_ journal: Journal) {
        loadTempImage()
        if !loadBrandImage(journal) {
//            APIManager.sharedInstance.getBrandImagesForJournal(journal) { (success) -> Void in
//                if success {
//                    self.loadBrandImage(journal)
//                }
//            }
        }
    }
    
    func update(_ journal: Journal, isPortrait: Bool) {
        loadTempImage()
        if !loadBrandImage(journal, isPortrait: isPortrait) {
            APIManager.sharedInstance.getBrandImagesForJournal(journal) { (success) -> Void in
                if success {
                    self.loadBrandImage(journal)
                }
            }
        }
    }
    
    // MARK: - Load -
    
    @discardableResult fileprivate func loadBrandImage(_ journal: Journal) -> Bool {
        if let brandImagePath = FileSystemManager.sharedInstance.journalBrandImagePath(journal, isPortrait: isPortrait) {
            if let image = UIImage(contentsOfFile: brandImagePath) {
                loadImage(image)
                return true
            }
        }
        return false
    }
    
    fileprivate func loadBrandImage(_ journal: Journal, isPortrait: Bool) -> Bool {
        if let brandImagePath = FileSystemManager.sharedInstance.journalBrandImagePath(journal, isPortrait: isPortrait) {
            if let image = UIImage(contentsOfFile: brandImagePath) {
                loadImage(image)
                return true
            }
        }
        return false
    }
    
    fileprivate func loadTempImage() {
        var image: UIImage
        if isPortrait {
            image = UIImage(named: "DefaultBrandLogo-Portrait")!
        } else {
            image = UIImage(named: "DefaultBrandLogo-Landscape")!
        }
        loadImage(image)
    }
    
    fileprivate func loadImage(_ image: UIImage) {
        guard self.isHidden == false else {
            performOnMainThread({ 
                self.heightConstraint?.constant = 0
            })
            return
        }
        DispatchQueue.main.async {
            self.image = image
            self.heightConstraint?.constant = image.size.height
            self.widthConstraint?.constant = image.size.width
            
            //self.setNeedsDisplay()
            //self.updateConstraintsIfNeeded()
        }
    }
}

