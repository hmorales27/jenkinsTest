//
//  NumberOfDownloadsIcon.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/23/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class NumberOfDownloadsIcon: UIView {
    
    let countLabel = UILabel()
    
    fileprivate let size: CGFloat = 24
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupView()
        update(1)
    }
    
    func setupSubviews() {
        addSubview(countLabel)
    }
    
    func setupAutoLayout() {
        constrain(countLabel) { (countL) in
            guard let superview = countL.superview else {
                return
            }
            
            superview.height == size
            superview.width == size
            
            countL.top == superview.top
            countL.right == superview.right
            countL.bottom == superview.bottom
            countL.left == superview.left
        }
    }
    
    func setupView() {
        layer.cornerRadius = size / 2
        backgroundColor = UIColor.blue
        countLabel.textAlignment = NSTextAlignment.center
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        countLabel.textColor = UIColor.white
    }
    
    func update(_ count: Int) {
        countLabel.text = String(count)
    }
    
}
