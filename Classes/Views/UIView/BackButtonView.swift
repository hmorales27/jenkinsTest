//
//  BackButtonView.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 4/27/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class BackButtonView: UIView {
    
    let backImageView = UIImageView(image: UIImage(named: "Back")!)
    let titleLabel    = UILabel()
    
    let title: String
    
    init(title: String) {
        self.title = title
        super.init(frame: CGRect(x: 8, y: 27, width: 0, height: 0))
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupView()
        setupBackImageView()
        setupTitleLabel()
    }
    
    func setupSubviews() {
        addSubview(backImageView)
        addSubview(titleLabel)
    }
    
    func setupAutoLayout() {
        let subviews = [
            backImageView,
            titleLabel
        ]
        constrain(subviews) { (views) in
            
            let backIV = views[0]
            let titleL = views[1]
            
            guard let superview = backIV.superview else {
                return
            }
            
            backIV.top    == superview.top + Config.Padding.Small
            backIV.bottom == superview.bottom - Config.Padding.Small
            backIV.left   == superview.left + Config.Padding.Small
            backIV.width  == backIV.height
            
            titleL.left    == backIV.right + Config.Padding.Small
            titleL.right   == superview.right - Config.Padding.Small
            titleL.centerY == backIV.centerY
            titleL.height  == backIV.height
            
            superview.width >= 40
            superview.height == 40
            
        }
    }
    
    func setupView() {
        
    }
    
    func setupBackImageView() {
        
    }
    
    func setupTitleLabel() {
        titleLabel.text = title
    }
    
    
}
