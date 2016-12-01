//
//  NumberOfNotesView.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/23/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class NumberOfNotesView: JBSMView {
    
    let videoImageView = UIImageView(image: UIImage(named: "NoteIcon")!)
    let titleLabel = UILabel()
    
    fileprivate var width: CGFloat = 70
    
    fileprivate var _count: Int = 0
    var count: Int {
        get {
            return _count
        }
        set(_int) {
            _count = _int
            updatWithCount(_count)
        }
    }
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        setupSubviews()
        setupAutoLayout()
        setupView()
        
        titleLabel.font = UIFont.systemFontOfSize(12, weight: SystemFontWeight.Regular)
        titleLabel.textColor = UIColor.gray
        
        isAccessibilityElement = true        
        videoImageView.tintColor = UIColor.gray
    }
    
    func setupSubviews() {
        addSubview(videoImageView)
        addSubview(titleLabel)
    }
    
    func setupAutoLayout() {
        let subviews = [
            videoImageView,
            titleLabel
        ]
        constrain(subviews) { (views) in
            
            let videoIV = views[0]
            let titleL = views[1]
            
            guard let superview = videoIV.superview else {
                return
            }
            
            layoutConstraints.width = (superview.width == width)
            
            videoIV.top == superview.top + Config.Padding.Small
            videoIV.bottom == superview.bottom - Config.Padding.Small
            videoIV.left == superview.left + Config.Padding.Small
            videoIV.width == 24
            videoIV.height == 24
            
            titleL.top == superview.top + Config.Padding.Small
            titleL.left == videoIV.right
            titleL.bottom == superview.bottom - Config.Padding.Small
        }
    }
    
    fileprivate func updatWithCount(_ count: Int) {
        if count == 0 {
            isHidden = true
            layoutConstraints.width?.constant = 0
        } else {
            isHidden = false
            
            if count == 1 {
                titleLabel.text = "1 Note"
                layoutConstraints.width?.constant = width
            } else {
                titleLabel.text = "\(count) Notes"
                layoutConstraints.width?.constant = width
            }
        }
    }
    
    func setupView() {
        
    }
}
