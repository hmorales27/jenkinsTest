//
//  TwitterButton.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/14/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class TwitterButton: SocialView {
    
    let imageView = UIImageView.init(image: UIImage(named: "Twitter"))
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init() {
        super.init()
        setup()
    }
    
    override func setup() {
        backgroundColor = UIColor.colorWithHexString("55acee")
        isHidden = true
        
        isAccessibilityElement = true
        accessibilityLabel = "Twitter link"

        
        addSubview(imageView)
        imageView.isUserInteractionEnabled = false
        
        setupAutoLayout()
    }
    
    func setupAutoLayout() {
        constrain(self, imageView) { (view, imageV) in
            view.width == 44
            view.height == 44
            
            imageV.top == view.top
            imageV.bottom == view.bottom
            imageV.left == view.left
            imageV.right == view.right
        }
    }
}
