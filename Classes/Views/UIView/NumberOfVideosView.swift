//
//  NumberOfVideosView.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 4/29/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Cartography

class NumberOfVideosView: JBSMView {
    
    let videoImageView = UIImageView(image: UIImage(named: "Video")!)
    let titleLabel = UILabel()
    
    fileprivate var width: CGFloat = 80
    
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
            videoIV.width == 16
            videoIV.height == 16
            
            titleL.top == superview.top + Config.Padding.Small
            titleL.left == videoIV.right + Config.Padding.Small
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
                titleLabel.text = "1 Video"
                layoutConstraints.width?.constant = width
            } else {
                titleLabel.text = "\(count) Videos"
                layoutConstraints.width?.constant = width
            }
        }
    }
    
    func setupView() {
        
    }
}
