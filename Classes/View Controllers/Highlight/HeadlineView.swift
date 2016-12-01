//
//  HeadlineView.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/6/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class HeadlineView: JBSMView {
    
    let titleLabel = UILabel()
    
    
    // MARK: - Initializers -
    
    override init() {
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup -
    
    override func setup() {
        super.setup()
        
        setupSubviews()
        setupAutoLayout()
        setupView()
        setupTitleLabel()
    }
    
    func setupSubviews() {
        addSubview(titleLabel)
    }
    
    func setupAutoLayout() {
        constrain(titleLabel) { (titleLabel) -> () in
            guard let superview = titleLabel.superview else {
                return
            }
            
            self.layoutConstraints.height = (superview.height == 44)
            
            titleLabel.left == superview.left + 8
            titleLabel.top == superview.top + 8
            titleLabel.right == superview.right - 8
            titleLabel.bottom == superview.bottom - 8
        }
    }
    
    func setupView() {
        backgroundColor = UIColor.gray
    }
    
    func setupTitleLabel() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor.white
    }
    
    // MARK: - Update -
    
    func update(_ title: String) {
        titleLabel.text = title
    }
    
}
