/**
 FreeImageView.swift
 
 Created by Sharkey, Justin (ELS-CON) on 12/14/15.
 Copyright © 2015 Elsevier, Inc. All rights reserved.
*/

import UIKit
import Cartography

class FreeImageView: JBSMImageView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init() {
        super.init()
        setup()
    }

    override func setup() {
        image = UIImage(named: "FreeIssue")
        isHidden = true
        setupAutoLayout()
    }
    
    func setupAutoLayout() {
        constrain(self) { (view) in
            view.width == 40
            view.height == 40
        }
    }
}
