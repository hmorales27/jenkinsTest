//
//  ArticleTitleLabel.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/13/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit

class ArticleTitleLabel: JBSMLabel {
    
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        
        numberOfLines = 0
        font = USE_NEW_UI ? UIFont.systemFontOfSize(18, weight: .Bold) : UIFont.systemFontOfSize(16, weight: .Bold)
        
        textColor = UIColor.colorWithHexString("344890")
    }
    
    func update(_ title:String?) {
        if let text = title {
            self.text = text
        } else {
            text = ""
        }
    }
    
    func reset() {
        text = nil
    }
}
