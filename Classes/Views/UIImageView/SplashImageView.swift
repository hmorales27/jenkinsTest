//
//  SplashImageView.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 9/27/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit

class SplashImageView: UIImageView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        print("Hello World")
    }
}