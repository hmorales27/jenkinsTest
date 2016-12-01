//
//  ArticleListSectionView.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/13/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class ArticleListSectionView: UIView {
    
    let topLineView       = UIView()
    let bottomLineView    = UIView()
    let sectionTitleLabel = SectionTitleLabel()
    
    init() {
        super.init(frame: CGRectZero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        translatesAutoresizingMaskIntoConstraints = true
        
        backgroundColor = UIColor.colorWithHexString("D8D8D8")
        
        addSubview(topLineView)
        addSubview(bottomLineView)
        addSubview(sectionTitleLabel)
        
        topLineView.backgroundColor = UIColor.grayColor()
        bottomLineView.backgroundColor = UIColor.grayColor()
        
        constrain(topLineView, bottomLineView) { (top, bottom) -> () in
            let superview = top.superview!
            
            top.left == superview.left
            top.top == superview.top
            top.right == superview.right
            top.height == 1
            
            bottom.left == superview.left
            bottom.bottom == superview.bottom
            bottom.right == superview.right
            bottom.height == 1
        }
        
        constrain(sectionTitleLabel) { (section) -> () in
            let superview = section.superview!
            
            section.left == superview.left + 8
            section.top == superview.top + 8
            section.right == superview.right - 8
            section.bottom == superview.bottom - 8
        }
    }
}
